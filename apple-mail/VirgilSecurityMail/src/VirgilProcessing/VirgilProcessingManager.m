/**
 * Copyright (C) 2015 Virgil Security Inc.
 *
 * Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     (1) Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *     (2) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *     (3) Neither the name of the copyright holder nor the names of its
 *     contributors may be used to endorse or promote products derived from
 *     this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "VirgilProcessingManager.h"
#import <string.h>
#import "HTMLParser.h"
#import "VirgilCryptoLibWrapper.h"
#import "VirgilDecryptedMail.h"
#import "NSData+Base64.h"
#import "VirgilEncryptedContent.h"
#import "VirgilDecryptedContent.h"
#import "VirgilKeyManager.h"
#import "VirgilClassNameResolver.h"
#import "VirgilPrivateKey.h"
#import "VirgilGui.h"
#import "VirgilPreferencesContainer.h"
#import "VirgilKeyChainContainer.h"
#import "VirgilKeyChain.h"

#import <MessageStore.h>
#import <MailAccount.h>
#import <LocalAccount.h>
#import <MFMessageAddressee.h>
#import <_OutgoingMessageBody.h>
#import <MimePart.h>
#import <Subdata.h>
#import <MutableMessageHeaders.h>
#import <MessageWriter.h>
#import <MCAttachment.h>

@implementation VirgilProcessingManager

static BOOL _decryptionStart = YES;

+ (VirgilProcessingManager *) sharedInstance {
    static VirgilProcessingManager * singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    
    return singletonObject;
}

+ (id) alloc{
    return [super alloc];
}

- (id) init{
    _decryptedMail = [[VirgilDecryptedMail alloc] init];
    return [super init];
}

- (BOOL) resetDecryption {
    return _decryptionStart = YES;
}

- (BOOL) isEncryptedByVirgil : (MimePart *)topMimePart {
    return [self partWithVirgilSignature:topMimePart] != nil;
}

- (NSSet *) allMimeParts : (MimePart *)topMimePart {
    NSMutableSet * mimeParts = [[NSMutableSet alloc] init];
    
    [mimeParts addObject:topMimePart];
    
    for(MimePart *part in [topMimePart subparts]) {
        // Recursive search
        NSSet * subSet = [self allMimeParts:part];
        [mimeParts addObjectsFromArray:[subSet allObjects]];
    }
    
    return [mimeParts copy];
}

- (MimePart *) partWithVirgilSignature : (MimePart *)topMimePart {
    // Iterate throw all MimePart to find part with virgil marker
    NSSet * mimeParts = [self allMimeParts:topMimePart];
    
    for (MimePart * part in mimeParts) {
        if ([self isPartContainsVirgilSignature:part]) {
            return part;
        }
    }
    return nil;
}

- (BOOL) isPartContainsVirgilSignature : (MimePart *)mimePart {
    if(![mimePart isType:@"text" subtype:@"html"]) {
        // Exit.
        // Because our encrypted information places to test/html part.
        return NO;
    }
        
    NSData *bodyData = [mimePart bodyData];
    NSString* strBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:strBody error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    HTMLNode *bodyNode = [parser body];
    NSArray *inputNodes = [bodyNode findChildTags:@"input"];
    
    for (HTMLNode *inputNode in inputNodes) {
        if ([[inputNode getAttributeNamed:@"id"] isEqualToString:@"virgil-info"]) {
            if ([[inputNode getAttributeNamed:@"type"] isEqualToString:@"hidden"]) {
                return YES;
            }
        }
    }
    return NO;
}

// Get encrypted data for virgil-info part and for attachements
- (NSData *) getEncryptedContent : (MimePart *)mimePart {
    NSData *bodyData = [mimePart bodyData];
    NSString* strBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:strBody error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    HTMLNode *bodyNode = [parser body];
    NSArray *inputNodes = [bodyNode findChildTags:@"input"];
    
    for (HTMLNode *inputNode in inputNodes) {
        if ([[inputNode getAttributeNamed:@"id"] isEqualToString:@"virgil-info"]) {
            if ([[inputNode getAttributeNamed:@"type"] isEqualToString:@"hidden"]) {
                NSString * base64Data = [inputNode getAttributeNamed:@"value"];
                NSData* res = [NSData dataFromBase64String:base64Data];
                return res;
            }
        }
    }
    
    //TODO: Get base64 data for attachements
    
    return nil;
}

- (void) setCurrentConfirmationCode : (NSString *) confirmationCode {
    [VirgilGui setConfirmationCode : confirmationCode];
}

// Get EmailData and signature
- (VirgilEncryptedContent *) getMainEncryptedData : (NSData *)data {
    // Parse json email body, get EmailData and Signature
    // result in emailDictionary
    NSError *error = nil;
    id mailJSON = [NSJSONSerialization
                   JSONObjectWithData:data
                   options:0
                   error:&error];
    
    if(error) {
        NSLog(@"Can't read e-mail JSON");
        return nil;
    }
    
    NSDictionary * emailDictionary = nil;
    if([mailJSON isKindOfClass:[NSDictionary class]]) {
        emailDictionary = mailJSON;
    } else {
        NSLog(@"Can't read e-mail JSON (not a dictionary)");
        return nil;
    }
    
    // Prepare NSData for EmailData
    NSData * emailData = [NSData dataFromBase64String:[emailDictionary objectForKey:@"EmailData"]];
    
    // Prepare NSData for signature
    NSData * signatureData = [NSData dataFromBase64String:[emailDictionary objectForKey:@"Sign"]];

    return [[VirgilEncryptedContent alloc] initWithEmailData:emailData
                                                andSignature:signatureData];
}

- (VirgilDecryptedContent *) decryptContent : (VirgilEncryptedContent *) content
                                publicKeyId : (NSString *) publicKeyId
                                 privateKey : (NSString *) privateKey
                         privateKeyPassword : (NSString *) privateKeyPassword {
    
    NSData * decryptedJsonData = [VirgilCryptoLibWrapper decryptData:content.emailData
                                                         publicKeyId:publicKeyId
                                                          privateKey:privateKey
                                                  privateKeyPassword:privateKeyPassword];
    
    if (nil == decryptedJsonData) return nil;
    
    // Parse json data
    // result in emailDictionary
    NSError *error = nil;
    id mailJSON = [NSJSONSerialization
                   JSONObjectWithData:decryptedJsonData
                   options:0
                   error:&error];
    
    if(error) {
        NSLog(@"Can't read e-mail JSON");
        return nil;
    }

    NSDictionary * emailDictionary = nil;
    if([mailJSON isKindOfClass:[NSDictionary class]]) {
        emailDictionary = mailJSON;
    } else {
        NSLog(@"Can't read e-mail JSON (not a dictionary)");
        return NO;
    }

    NSString * subject = [emailDictionary objectForKey:@"Subject"];
    NSString * body = [emailDictionary objectForKey:@"Body"];
    NSString * htmlBody = [emailDictionary objectForKey:@"HtmlBody"];
    
    return [[VirgilDecryptedContent alloc] initWithSubject:subject
                                                      body:body
                                                  htmlBody:htmlBody];
}

- (NSData *) getEncryptedAttachement : (MimePart *)part {
    if (![[part disposition] isEqualToString:@"attachment"]) return nil;
    if (![part.contentTransferEncoding isEqualToString:@"base64"]) return nil;
    NSData *bodyData = [part bodyData];
    //NSString* strBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    return bodyData;
}

- (NSString *) getEmailFromFullName : (NSString *) name {
    if (nil == name) return nil;

    NSRange range = [name rangeOfString:@"<"];
    if (NSNotFound == range.location) return name;
    NSString * rightPart = [name substringFromIndex : range.location + 1];
    range = [rightPart rangeOfString:@">"];
    if (NSNotFound == range.location) return name;
    NSString * emailPart = [rightPart substringToIndex:range.location];
    return emailPart;
}

- (BOOL) canDecrypt {
    if ([VirgilPreferencesContainer isNeedAskToDecrypt]) {
        return [VirgilGui askForCanDecrypt];
    }
    
    return YES;
}

- (BOOL) decryptWholeMessage : (MimePart *)topMimePart {
    if (NO == [self canDecrypt]) return NO;
    
    MimePart * mainVirgilPart = [self partWithVirgilSignature:topMimePart];
    if (nil == mainVirgilPart) return NO;
    Message * message = [(MimeBody *)[topMimePart mimeBody] message];
    NSSet * allMimeParts = [self allMimeParts:topMimePart];
    
    // Get sender info
    NSString * sender = [self getEmailFromFullName:[message sender]];
    VirgilKeyChainContainer * senderContainer = [self getKeysContainer : sender
                                                    forcePrivateKeyGet : NO];
    if (nil == senderContainer || nil == senderContainer.publicKey) return NO;
    NSString * senderPublicKey = senderContainer.publicKey.publicKey;
    
    // Get receiver (me) info
    NSString * receiver = [self getMyAccountFromMessage : message];
    VirgilKeyChainContainer * receiverContainer = [self getKeysContainer : receiver
                                                      forcePrivateKeyGet : YES];
    if (nil == receiverContainer ||
        nil == receiverContainer.privateKey ||
        nil == receiverContainer.publicKey) {
        return NO;
    }
    NSString * publicId = receiverContainer.publicKey.publicKeyID;
    VirgilPrivateKey * privateKey = receiverContainer.privateKey;
    VirgilEncryptedContent * encryptedContent = [self getMainEncryptedData:
                                                 [self getEncryptedContent:mainVirgilPart]];
    if (nil == sender ||
        nil == senderPublicKey ||
        nil == receiver ||
        nil == publicId ||
        nil == privateKey ||
        nil == encryptedContent) {
        NSLog(@"sender : %@", sender);
        NSLog(@"senderPublicKey : %@", senderPublicKey);
        NSLog(@"receiver : %@", receiver);
        NSLog(@"publicId : %@", publicId);
        NSLog(@"ERROR : Can't decrypt message !");
        return NO;
    }
    
    if (![VirgilCryptoLibWrapper isSignatureCorrect:encryptedContent.signature
                                              data:encryptedContent.emailData
                                         publicKey:senderPublicKey]) {
        //TODO: Place to email information about invalid signature
        NSLog(@"ERROR : Wrong signature !");
    }
    
    VirgilDecryptedContent * decryptedContent = [self decryptContent:encryptedContent
                                                         publicKeyId:publicId
                                                          privateKey:privateKey.key
                                                  privateKeyPassword:privateKey.keyPassword];
    
    // Prepare decrypted mail data
    // and set decrypted mail part
    [_decryptedMail clear];
    [_decryptedMail setCurrentMailHash:message];
    [_decryptedMail addPart:decryptedContent.htmlBody
                   partHash:mainVirgilPart];
    
    for (MimePart * part in allMimeParts) {
        if (part == mainVirgilPart) continue;
        NSData * encryptedAttachement = [self getEncryptedAttachement:part];
        if (nil == encryptedAttachement) continue;
        NSData * decryptedAttachement = [VirgilCryptoLibWrapper decryptData:encryptedAttachement
                                                                publicKeyId:publicId
                                                                 privateKey:privateKey.key
                                                         privateKeyPassword:privateKey.keyPassword];
        if (nil == decryptedAttachement) continue;
        [_decryptedMail addAttachement:decryptedAttachement
                            attachHash:[part attachmentFilename]];
    }
    return YES;
}


- (id) decryptMessagePart:(MimePart *)mimePart {
    if (nil == mimePart) return nil;
    MimePart * topMimePart = [self topLevelPartByAnyPart:mimePart];
    
    if (![self isEncryptedByVirgil:topMimePart]) {
        // Current email isn't decrypted by Virgil
        return nil;
    }
    
    Message * currentMessage = [(MimeBody *)[mimePart mimeBody] message];

    if (YES == _decryptionStart && ![_decryptedMail isCurrentMail:currentMessage]) {
        [self decryptWholeMessage:topMimePart];
        _decryptionStart = NO;
    }
    
    return [_decryptedMail partByHash:mimePart];
}

- (BOOL) checkConfirmationEmail : (MimePart *) mimePart {
    if (nil == mimePart) return NO;
    MimePart * topMimePart = [self topLevelPartByAnyPart:mimePart];
    
    Message * message = [(MimeBody *)[topMimePart mimeBody] message];
    NSString * receiver = [self getMyAccountFromMessage:message];
    if (nil == message || nil == receiver) return NO;
    NSLog(@"isRead = %hhd", [message isRead]);
    
    if (![topMimePart.subtype isEqualTo:@"html"]) return NO;
    
    NSData *bodyData = [mimePart bodyData];
    NSString* strBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    
    if (nil == strBody) return NO;
    if (![strBody containsString : @"confirmation code is"]) return NO;
    
    NSRange range = [strBody rangeOfString:@"font-weight: bold;\">"];
    if (NSNotFound == range.location) return NO;
    NSString * rightPart = [strBody substringFromIndex : range.location + 20];
    range = [rightPart rangeOfString:@"</b>"];
    if (NSNotFound == range.location) return NO;
    NSString * strCode = [rightPart substringToIndex:range.location];
    if (YES == [message isRead]) return YES;
    
    VirgilKeyChainContainer * receiverContainer = [self getKeysContainer : receiver
                                                      forcePrivateKeyGet : YES];
    if (nil == receiverContainer) return NO;
    
    VirgilPrivateKey * privateKey = receiverContainer.privateKey;
    if (nil == privateKey) return NO;
    if (YES == receiverContainer.isActive) return YES;
    //TODO: Check is email registered
    [VirgilGui setConfirmationCode : strCode];
    [VirgilGui getPrivateKey : receiver];
    
    return YES;
}

- (MimePart *) topLevelPartByAnyPart : (MimePart *)part {
    MimePart * res = (MimePart *)part;
    while ([res parentPart] != nil) {
        res = [res parentPart];
    }
    return res;
}

- (NSData *) decryptedAttachementByName : (NSString *) name {
    if (nil == name) return nil;
    return [_decryptedMail attachementByHash:name];
}

- (void) getAllPrivateKeys {
    NSMutableSet * set = [[NSMutableSet alloc] init];
    for (LocalAccount * account in [[VirgilClassNameResolver resolveClassFromName:@"MailAccount"] mailAccounts]) {
        for (NSString * email in account.emailAddresses) {
            [set addObject : email];
        }
    }
    
    for (NSString * email in set) {
        NSLog(@"                        getAllPrivateKeys");
        [self getKeysContainer : email
            forcePrivateKeyGet : YES];
    }
}

- (NSString *) getMyAccountFromMessage : (Message *)message {
    if (nil == message) return nil;
    
    // TODO: Pay attention to [message account] (MFIMAPAccount)
    
    // Get my accounts
    NSMutableSet * myAccounts = [[NSMutableSet alloc] init];
    for (LocalAccount * account in [[VirgilClassNameResolver resolveClassFromName:@"MailAccount"] mailAccounts]) {
        for (NSString * email in account.emailAddresses) {
            [myAccounts addObject:email];
        }
    }
    
    // Iterate throw all email receivers
    for (MFMessageAddressee * addressee in message.toRecipients) {
        for (NSString * email in myAccounts) {
            if ([email isEqualTo:addressee.address]) {
                return email;
            }
        }
    }
    
    // Check for sender is me
    NSString * sender = [self getEmailFromFullName:[message sender]];
    
    for (NSString * email in myAccounts) {
        if ([email isEqualTo : sender]) {
            return email;
        }
    }
    
    return nil;
}

- (BOOL) isNeedToEncrypt {
    return [VirgilPreferencesContainer isUseEncryption];
}

- (NSString *) baseMailHTML {
    // TODO: Load from external source
    return @"<html>\n<body>"
    "<p>The message has been encrypted with Virgil Security Plugin.</p>"
    "<a href='https://virgilsecurity.com/downloads/' >Download Virgil Security Plugin.</a>"
    "<input id='virgil-info' type='hidden' value='%@' />"
    "</body></html>";
}

- (NSString *) baseMailPlain {
    return @"The message has been encrypted with Virgil Security Plugin.\n"
    "Download Virgil Security Plugin. <https://virgilsecurity.com/downloads/>";
}

- (VirgilKeyChainContainer *) getKeysContainer : (NSString *) account
                            forcePrivateKeyGet : (BOOL) forcePrivateKey {
    NSLog(@"                        getKeysContainer  account : %@  forcePrivateKey : %hhd", account, forcePrivateKey);
    if (nil == account) return nil;
    VirgilKeyChainContainer * container = [VirgilKeyChain loadContainer : account];
    
    if (nil != container && nil != container.publicKey && nil != container.privateKey) {
        return container;
    }
    
    VirgilPrivateKey * privateKey = container.privateKey;
    if ((nil == container || nil == privateKey) && forcePrivateKey) {
        privateKey = [VirgilGui getPrivateKey : account];
    }
    
    VirgilPublicKey * publicKey = container.publicKey;
    if (nil == container || nil == publicKey) {
        publicKey = [VirgilKeyManager getPublicKey : account];
    }
    
    if (nil == publicKey) return nil;
    if (nil == publicKey && YES == forcePrivateKey) return nil;
    
    BOOL isActive = (nil == container) ? NO : container.isActive;
    container =
        [[VirgilKeyChainContainer alloc] initWithPrivateKey : privateKey
                                               andPublicKey : publicKey
                                                   isActive : isActive];
    
    NSLog(@"                         saveContainer %@", container);
    [VirgilKeyChain saveContainer : container
                       forAccount : account];
    
    return container;
}

- (NSString *) encryptContent : (VirgilDecryptedContent *)content
                       sender : (NSString *) sender
                    receivers : (NSArray *) receivers {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject : [content toDictionary]
                                                       options : 0
                                                         error : &error];
    NSLog(@"jsonData    =  %@",
          [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    if (!jsonData) {
        NSLog(@"JSON creation error: %@", error.localizedDescription);
        return nil;
    }
    
    NSString * fixedSender = [self getEmailFromFullName : sender];
    VirgilKeyChainContainer * container = [self getKeysContainer : fixedSender
                                              forcePrivateKeyGet : YES];
    if (nil == container || nil == container.privateKey) return nil;

    // Get all public keys
    NSMutableArray * publicKeys = [[NSMutableArray alloc] init];
    
    VirgilPublicKey * publicKeyForSender = [VirgilKeyManager getPublicKey : fixedSender];
    if (nil == publicKeyForSender) return nil;
    [publicKeys addObject : publicKeyForSender];
    
    NSLog(@"sender : %@", sender);
    NSLog(@"receivers : %@", receivers);
    
    for (NSString * receiverEmail in receivers) {
        NSString * fixedReceiver = [self getEmailFromFullName : receiverEmail];
        VirgilPublicKey * publicKey = [VirgilKeyManager getPublicKey : fixedReceiver];
        if (nil != publicKey) {
            [publicKeys addObject : publicKey];
        }
    }
    
    // Encrypt email data
    NSData * encryptedEmailBody = [VirgilCryptoLibWrapper encryptData : jsonData
                                                           publicKeys : [publicKeys copy]];
    
    // Create signature
    NSData * signature = [VirgilCryptoLibWrapper signatureForData : encryptedEmailBody
                                                   withPrivateKey : container.privateKey.key
                                                privatKeyPassword : container.privateKey.keyPassword];
    
    
    VirgilEncryptedContent * encryptedContent =
            [[VirgilEncryptedContent alloc] initWithEmailData : encryptedEmailBody
                                                 andSignature : signature];

    // Prepare base64 result data
    NSData *jsonEncryptedData = [NSJSONSerialization dataWithJSONObject : [encryptedContent toDictionary]
                                                                options : 0
                                                                  error : &error];
    if (!jsonEncryptedData) {
        NSLog(@"JSON creation error: %@", error.localizedDescription);
        return nil;
    }

    return [jsonEncryptedData base64EncodedString];
}

- (NSArray *) encryptAttachments : (NSArray *) attachments
                          sender : (NSString *) sender
                       receivers : (NSArray *) receivers {
    if (nil == attachments || 0 == [attachments count]) return nil;
    
    NSString * fixedSender = [self getEmailFromFullName : sender];
    
    // Get all public keys
    NSMutableArray * publicKeys = [[NSMutableArray alloc] init];
    for (NSString * receiverEmail in receivers) {
        NSString * fixedReceiver = [self getEmailFromFullName : receiverEmail];
        VirgilPublicKey * publicKey = [VirgilKeyManager getPublicKey : fixedReceiver];
        [publicKeys addObject : publicKey];
    }
    
    VirgilPublicKey * publicKeyForSender = [VirgilKeyManager getPublicKey : fixedSender];
    [publicKeys addObject : publicKeyForSender];
    
    // Encrypt all attachments
    NSMutableArray * res = [[NSMutableArray alloc] init];
    for (MCAttachment * attach in attachments) {
        MCAttachment * encryptedAttach = [attach copy];
        NSData * encryptedContent = [VirgilCryptoLibWrapper encryptData : encryptedAttach.originalData
                                                             publicKeys : [publicKeys copy]];
        if (nil != encryptedContent) {
            NSString * base64Str = [encryptedContent base64EncodedString];
            encryptedAttach.originalData = [base64Str dataUsingEncoding : NSUTF8StringEncoding];
            [res addObject:encryptedAttach];
        }
    }
    return [res copy];
}

- (Subdata *) createMailBodyDataWithData : (NSData *) data
                    plainTextAlternative : (NSString *) plainText
                             attachments : (NSArray *) attachments
                                 headers : (MutableMessageHeaders *) headers {
    if (nil == data || nil == headers) {
        return nil;
    }
    
    Class MimeBody = [VirgilClassNameResolver resolveClassFromName:@"MimeBody"];
    
    MimePart * topPart = nil;
    NSData * topData = nil;
    
    MimePart * alternativePart = nil;
    NSData * alternativeData = nil;
    
    MimePart * textPart = nil;
    NSData * textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    MimePart * htmlPart = nil;
    NSData * htmlData = data;

    MimePart * attachPart = nil;
    
    Class MimePart = [VirgilClassNameResolver resolveClassFromName:@"MimePart"];
    
    // Create top part
    topPart = [[MimePart alloc] init];
    [topPart setType : @"multipart"];
    [topPart setSubtype : @"mixed"];
    [topPart setBodyParameter : [MimeBody newMimeBoundary]
                       forKey : @"boundary"];
    topPart.contentTransferEncoding = @"7bit";

    // Create alternative part
    alternativePart = [[MimePart alloc] init];
    [alternativePart setType : @"multipart"];
    [alternativePart setSubtype : @"alternative"];
    [alternativePart setBodyParameter : [MimeBody newMimeBoundary]
                               forKey : @"boundary"];
    
    // Create text part
    textPart = [[MimePart alloc] init];
    [textPart setType : @"text"];
    [textPart setSubtype : @"plain"];
    textPart.contentTransferEncoding = @"7bit";
    //[textPart setBodyParameter :@"\"us-ascii\""
    //                   forKey : @"charset"];
    
    
    // Create HTML part
    htmlPart = [[MimePart alloc] init];
    [htmlPart setType : @"text"];
    [htmlPart setSubtype : @"html"];
    htmlPart.contentTransferEncoding = @"7bit";
    
    
    // Create parts tree
    [alternativePart addSubpart : textPart];
    [alternativePart addSubpart : htmlPart];
    
    [topPart addSubpart : alternativePart];
    
    CFMutableDictionaryRef partBodyMapRef = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionaryAddValue(partBodyMapRef, (__bridge const void *)(topPart), (__bridge const void *)(topData));
    CFDictionaryAddValue(partBodyMapRef, (__bridge const void *)(alternativePart), (__bridge const void *)(alternativeData));
    CFDictionaryAddValue(partBodyMapRef, (__bridge const void *)(textPart), (__bridge const void *)(textData));
    CFDictionaryAddValue(partBodyMapRef, (__bridge const void *)(htmlPart), (__bridge const void *)(htmlData));
    
    
    // Create and add attachement parts
    for (MCAttachment * attach in attachments) {
        attachPart = [[MimePart alloc] init];
        [attachPart setType:@"text"];
        [attachPart setSubtype:@"plain"];
        [attachPart setBodyParameter : attach.filename
                              forKey : @"name"];
        attachPart.contentTransferEncoding = @"base64";
        [attachPart setDisposition : @"attachment"];
        [attachPart setDispositionParameter:attach.filename forKey:@"filename"];
        
        [topPart addSubpart : attachPart];
        CFDictionaryAddValue(partBodyMapRef,
                             (__bridge const void *)(attachPart),
                             (__bridge const void *)(attach.originalData));
    }
    
    NSMutableDictionary *partBodyMap = (__bridge NSMutableDictionary *)partBodyMapRef;
    
    NSMutableData *contentTypeData = [[NSMutableData alloc] initWithLength:0];
    [contentTypeData appendData : [[NSString stringWithFormat:@"%@/%@;",
                                  [topPart type],
                                  [topPart subtype]]
              dataUsingEncoding : NSASCIIStringEncoding]];
    
    for(id key in [topPart bodyParameterKeys]) {
        [contentTypeData appendData : [[NSString stringWithFormat:@"\n\t%@=\"%@\";",
                                        key,
                                        [topPart bodyParameterForKey:key]]
                  dataUsingEncoding : NSASCIIStringEncoding]];
    }
        
    [headers setHeader : contentTypeData
                forKey : @"content-type"];
    [headers setHeader : @"7bit"
                forKey : @"content-transfer-encoding"];
    [headers removeHeaderForKey:@"content-disposition"];
    [headers removeHeaderForKey:@"from "];
    [headers removeHeaderForKey:@"bcc"];
    
    // Create the actualy body data.
    NSData *headerData = [headers encodedHeadersIncludingFromSpace : NO];
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    [bodyData appendData : headerData];
    MessageWriter *messageWriter =
            [[[VirgilClassNameResolver resolveClassFromName:@"MessageWriter"] alloc] init];
    
    [messageWriter appendDataForMimePart : topPart
                                  toData : bodyData
                            withPartData : partBodyMap];
    
    CFRelease(partBodyMapRef);
    
    NSRange contentRange = NSMakeRange([headerData length],
                                       ([bodyData length] - [headerData length]));
    Subdata *contentSubdata =
            [[[VirgilClassNameResolver resolveClassFromName:@"Subdata"] alloc] initWithParent : bodyData
                                                                                        range : contentRange];
    return contentSubdata;
}

- (BOOL) encryptMessage : (WebComposeMessageContents *)message
            attachments : (NSArray *)attachments
                 result : (OutgoingMessage *)result {
    NSString * sender = [[NSString alloc] initWithString:[result.headers firstAddressForKey:@"from"]];
    NSMutableArray * receivers = [[NSMutableArray alloc] init];
    [receivers addObjectsFromArray : [result.headers addressListForKey:@"to"]];
    [receivers addObjectsFromArray : [result.headers addressListForKey:@"cc"]];
    [receivers addObjectsFromArray : [result.headers addressListForKey:@"bcc"]];
    
    NSString * subject = [result.headers firstHeaderForKey:@"subject"];
    if (nil == subject) subject = @"";
    
    NSString * body = [message.plainText string];
    if (nil == body) body = @"";
    
    NSString * htmlBody = message.topLevelHtmlString;
    if (nil == htmlBody) {
        htmlBody = [body stringByReplacingOccurrencesOfString : @"\n"
                                                   withString : @"</br>"];
    }
    
    VirgilDecryptedContent * decryptedContent =
            [[VirgilDecryptedContent alloc] initWithSubject : subject
                                                       body : body
                                                   htmlBody : htmlBody];
    
    NSString * encryptedData = [self encryptContent : decryptedContent
                                             sender : sender
                                          receivers : receivers];
    
    if (nil == encryptedData) return NO;
    
    NSString * mailBodyStr = [[NSString alloc] initWithFormat:[self baseMailHTML], encryptedData];
    
    NSArray * encryptedAttachments = [self encryptAttachments : attachments
                                                       sender : sender
                                                    receivers : receivers];
    
    Subdata * newBodyData = [self createMailBodyDataWithData : [mailBodyStr dataUsingEncoding:NSUTF8StringEncoding]
                                        plainTextAlternative : [self baseMailPlain]
                                                 attachments : encryptedAttachments
                                                     headers : [result headers]];
    
    [result setValue:[newBodyData valueForKey:@"_parentData"] forKey:@"_rawData"];
    return YES;
}

- (BOOL) inviteMessage : (WebComposeMessageContents *)message
                result : (OutgoingMessage *)result {
    return YES;
}

@end
