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
#import "HTMLConverter.h"
#import "VirgilEncryptedContent.h"
#import "VirgilDecryptedContent.h"
#import "VirgilKeyManager.h"
#import "VirgilClassNameResolver.h"
#import "VirgilPrivateKey.h"
#import "VirgilGui.h"
#import "VirgilPreferencesContainer.h"
#import "VirgilKeyChainContainer.h"
#import "VirgilKeyChain.h"
#import "VirgilLog.h"

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
    _decryptedMailContainer = [[VirgilDecryptedMailContainer alloc] init];
    return [super init];
}

- (BOOL) isEncryptedByVirgil : (MimePart *)topMimePart {
    return [self partWithVirgilSignature:topMimePart] != nil;
}

- (BOOL) isEncryptedByVirgilByAnyPart : (MimePart *)mimePart {
    MimePart * topMimePart = [self topLevelPartByAnyPart : mimePart];
    return [self isEncryptedByVirgil:topMimePart];
}

- (NSSet *) allMimeParts : (MimePart *)topMimePart {
    NSMutableSet * mimeParts = [[NSMutableSet alloc] init];
    
    if (nil != topMimePart) {
        [mimeParts addObject:topMimePart];
        
        for(MimePart *part in [topMimePart subparts]) {
            // Recursive search
            NSSet * subSet = [self allMimeParts:part];
            [mimeParts addObjectsFromArray:[subSet allObjects]];
        }
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
        
        if ([[part disposition] isEqualToString : @"attachment"] &&
            [part.attachmentFilename isEqualToString : VIRGIL_MAIL_INFO_ATTACH]) {
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
        VLogError(@"Error: %@", error);
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
    
    if (NO == [strBody localizedCaseInsensitiveContainsString : @"html"] ) {
        // Get virgil data from VirgilSecurity.mailinfo attachment
        return [NSData dataFromBase64String : strBody];
    } else {
        // Get virgil data from html body
        HTMLParser *parser = [[HTMLParser alloc] initWithString:strBody error:&error];
        
        if (error) {
            VLogError(@"Error: %@", error);
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
    }
    
    return nil;
}

// Get EmailData and signature
- (VirgilEncryptedContent *) getMainEncryptedData : (NSData *)data {
    if (nil == data) return nil;
    
    // Parse json email body, get EmailData and Signature
    // result in emailDictionary
    NSError *error = nil;
    id mailJSON = [NSJSONSerialization
                   JSONObjectWithData:data
                   options:0
                   error:&error];
    
    if(error) {
        VLogError(@"Can't read e-mail JSON");
        return nil;
    }
    
    NSDictionary * emailDictionary = nil;
    if([mailJSON isKindOfClass:[NSDictionary class]]) {
        emailDictionary = mailJSON;
    } else {
        VLogError(@"Can't read e-mail JSON (not a dictionary)");
        return nil;
    }
    
    // Prepare NSData for EmailData
    NSData * emailData =
            [NSData dataFromBase64String:[emailDictionary objectForKey : kEmailData]];
    // Prepare NSData for signature
    NSData * signatureData =
            [NSData dataFromBase64String:[emailDictionary objectForKey : kEmailSignature]];
    // Prepare Sender info
    NSString * sender = [emailDictionary objectForKey : kEmailSender];
    
    // Prepare Version
    NSString * version = [emailDictionary objectForKey : kEmailVersion];
    
    return [[VirgilEncryptedContent alloc] initWithEmailData : emailData
                                                   signature : signatureData
                                                      sender : sender
                                                     version : version];
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
        VLogError(@"Can't read e-mail JSON");
        return nil;
    }

    NSDictionary * emailDictionary = nil;
    if([mailJSON isKindOfClass:[NSDictionary class]]) {
        emailDictionary = mailJSON;
    } else {
        VLogError(@"Can't read e-mail JSON (not a dictionary)");
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
    if (YES == [part.attachmentFilename isEqualToString:VIRGIL_MAIL_INFO_ATTACH]) return nil;
    NSData *bodyData = [part bodyData];
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

- (NSTimeInterval) curTime {
    return [[NSDate date] timeIntervalSince1970];
}

- (BOOL) canDecrypt {
    static BOOL _lastAnswer = NO;
    static NSTimeInterval _lastAnswerTime = 0;
    
    //@synchronized(self) {
        if ([VirgilPreferencesContainer isNeedAskToDecrypt]) {
            
            NSTimeInterval _saveAnswerTime = 2.0;
            
            if (YES == _lastAnswer && YES == [VirgilPreferencesContainer isSaveDecryptionAccept]) {
                _saveAnswerTime = 60.0 * [VirgilPreferencesContainer acceptSaveTimeMin];
            }
            
            if (([self curTime] - _lastAnswerTime) > _saveAnswerTime) {
                _lastAnswer = [VirgilGui askForCanDecrypt];
                _lastAnswerTime = [self curTime];
            }
        } else {
            _lastAnswer = YES;
        }
    //}
    
    VLogInfo(@"canDecrypt %hhd", _lastAnswer);
    return _lastAnswer;
}

- (BOOL) isVirgilDataInAttach : (MimePart *) virgilPart {
    return [[virgilPart disposition] isEqualToString:@"attachment"];
}

- (MimePart *) partForReplacement : (MimePart *)topMimePart {
    NSSet * allMimeParts = [self allMimeParts : topMimePart];
    for (MimePart * part in allMimeParts) {
        if ([part.subtype isEqualTo:@"html"] || [part.subtype isEqualTo:@"plain"]) {
            NSData * bodyData = [part bodyData];
            NSString * strBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
            if ([strBody containsString : @"https://virgilsecurity.com"]) {
                return part;
            }
        }
    }
    return nil;
}

- (BOOL) isPlainTextPart : (MimePart *)part {
    if (nil == part) return NO;
    return [part.subtype isEqualTo:@"plain"];
}

- (BOOL) decryptWholeMessage : (MimePart *)topMimePart {
    if (NO == [self canDecrypt]) return NO;
    
    MimePart * mainVirgilPart = [self partWithVirgilSignature:topMimePart];
    BOOL virgilDataInAttach = [self isVirgilDataInAttach : mainVirgilPart];
    if (nil == mainVirgilPart) return NO;
    Message * message = [(MimeBody *)[topMimePart mimeBody] message];
    NSSet * allMimeParts = [self allMimeParts:topMimePart];
    
    VirgilEncryptedContent * encryptedContent = [self getMainEncryptedData:
                                                 [self getEncryptedContent : mainVirgilPart]];
    // Get sender info
    NSString * sender = nil;
    if (nil != encryptedContent.sender) {
        sender = encryptedContent.sender;
    } else {
        sender = [self getEmailFromFullName:[message sender]];
    }

    VirgilKeyChainContainer * senderContainer = [self getKeysContainer : sender
                                                    forcePrivateKeyGet : NO
                                                    forceActiveAccount : YES];
    if (nil == senderContainer || nil == senderContainer.publicKey) return NO;
    NSString * senderPublicKey = senderContainer.publicKey.publicKey;
    
    // Get receiver (me) info
    NSString * receiver = [self getMyAccountFromMessage : message];
    VirgilKeyChainContainer * receiverContainer = [self getKeysContainer : receiver
                                                      forcePrivateKeyGet : YES
                                                      forceActiveAccount : YES];
    if (nil == receiverContainer ||
        nil == receiverContainer.privateKey ||
        nil == receiverContainer.publicKey) {
        return NO;
    }
    NSString * publicId = receiverContainer.publicKey.publicKeyID;
    VirgilPrivateKey * privateKey = receiverContainer.privateKey;
    
    if (nil == sender ||
        nil == senderPublicKey ||
        nil == receiver ||
        nil == publicId ||
        nil == privateKey ||
        nil == encryptedContent) {
        VLogInfo(@"sender : %@", sender);
        VLogInfo(@"senderPublicKey : %@", senderPublicKey);
        VLogInfo(@"receiver : %@", receiver);
        VLogInfo(@"publicId : %@", publicId);
        VLogError(@"ERROR : Can't decrypt message !");
        return NO;
    }
    
    BOOL signatureCorrect = [VirgilCryptoLibWrapper isSignatureCorrect : encryptedContent.signature
                                                                  data : encryptedContent.emailData
                                                             publicKey : senderPublicKey];
    if (NO == signatureCorrect) {
        VLogError(@"Wrong signature !");
        [_decryptedMailContainer setStatus:decryptError forEmail:message];
        return NO;
    }
    
    VirgilDecryptedContent * decryptedContent = [self decryptContent:encryptedContent
                                                         publicKeyId:publicId
                                                          privateKey:privateKey.key
                                                  privateKeyPassword:privateKey.keyPassword];
    
    // Prepare decrypted mail data
    // and set decrypted mail part
    [_decryptedMailContainer setStatus:decryptOk forEmail:message];
    
    if (YES == virgilDataInAttach) {
        MimePart * partForReplacement = [self partForReplacement : topMimePart];
        if (YES == [self isPlainTextPart : partForReplacement]) {
            // Change mime type to text/html to workaround of text encoding bugs
            [partForReplacement setSubtype : @"html"];
        }
        
        [_decryptedMailContainer addPart : decryptedContent.htmlBody
                                partHash : partForReplacement
                                forEmail : message];
    } else {
        [_decryptedMailContainer addPart : decryptedContent.htmlBody
                                partHash : mainVirgilPart
                                forEmail : message];
    }
        
    for (MimePart * part in allMimeParts) {
        if (part == mainVirgilPart) continue;
        NSData * encryptedAttachement = [self getEncryptedAttachement:part];
        if (nil == encryptedAttachement) continue;
        NSData * decryptedAttachement = [VirgilCryptoLibWrapper decryptData:encryptedAttachement
                                                                publicKeyId:publicId
                                                                 privateKey:privateKey.key
                                                         privateKeyPassword:privateKey.keyPassword];
        if (nil == decryptedAttachement) continue;
        [_decryptedMailContainer addAttachement : decryptedAttachement
                                     attachHash : [part attachmentFilename]
                                       forEmail : message];
    }
    
    return YES;
}

- (DecryptStatus) getDecriptionStatusForMessage : (Message *)message {
    return [_decryptedMailContainer statusForEmail:message];
}

- (id) decryptMessagePart:(MimePart *)mimePart {
    if (nil == mimePart) return nil;
    MimePart * topMimePart = [self topLevelPartByAnyPart:mimePart];
    
    if (![self isEncryptedByVirgil:topMimePart]) {
        // Current email isn't decrypted by Virgil
        return nil;
    }
    
    Message * currentMessage = [(MimeBody *)[mimePart mimeBody] message];

    id res = nil;
    @synchronized (self) {
        if (NO == [_decryptedMailContainer isMailPresent:currentMessage]) {
            [self decryptWholeMessage:topMimePart];
        }
        res = [_decryptedMailContainer partByHash:mimePart forEmail:currentMessage];
    }
    
    return res;
}

- (NSString *) confirmationCodeFromEmail : (Message *) message {
    if (nil == message) return nil;
    MimePart * topMimePart = ((MimeBody *)message.messageBody).topLevelPart;
    if (nil == topMimePart) return nil;
    
    NSString * receiver = [self getMyAccountFromMessage:message];
    if (nil == message || nil == receiver) return nil;
    VLogInfo(@"isRead = %hhd", [message isRead]);
    
    if (![topMimePart.subtype isEqualTo:@"html"]) return nil;
    
    NSData *bodyData = [topMimePart bodyData];
    NSString* strBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    
    if (nil == strBody) return NO;
    if (![strBody containsString : @"confirmation code is"]) return nil;
    
    NSRange range = [strBody rangeOfString:@"font-weight: bold;\">"];
    if (NSNotFound == range.location) return nil;
    NSString * rightPart = [strBody substringFromIndex : range.location + 20];
    range = [rightPart rangeOfString:@"</b>"];
    if (NSNotFound == range.location) return nil;
    return [rightPart substringToIndex:range.location];
}

- (BOOL) accountNeedsConfirmation : (NSString *)account {
    if (nil == account) return  NO;
    
    VirgilKeyChainContainer * container = [VirgilKeyChain loadContainer : account];
    if (nil == container) return NO;
    if (nil == container.privateKey) return NO;
    if (YES == container.isActive) return NO;
    
    return YES;
}

- (MimePart *) topLevelPartByAnyPart : (MimePart *)part {
    MimePart * res = (MimePart *)part;
    while ([res parentPart] != nil) {
        res = [res parentPart];
    }
    return res;
}

- (NSData *) decryptedAttachementByName : (NSString *) name forEmail : (id)message {
    if (nil == name) return nil;
    return [_decryptedMailContainer attachementByHash:name forEmail:message];
}

+ (NSArray *) accountsList {
    NSMutableSet * set = [[NSMutableSet alloc] init];
    for (LocalAccount * account in [[VirgilClassNameResolver resolveClassFromName:@"MailAccount"] mailAccounts]) {
        for (NSString * email in account.emailAddresses) {
            [set addObject : email];
        }
    }
    return [set allObjects];
}

- (VirgilAccountInfo *) accountInfo : (NSString *)account
                       checkInCloud : (BOOL)checkInCloud {
    VirgilAccountInfo * res = [VirgilAccountInfo new];
    res.account = account;
    
    // Get name by account
    for (LocalAccount * elem in [[VirgilClassNameResolver resolveClassFromName:@"MailAccount"] mailAccounts]) {
        for (NSString * emailAccount in elem.emailAddresses) {
            if ([emailAccount isEqualToString:account]) {
                res.name = elem.fullUserName;
                break;
            }
        }
        if (nil != res.name) break;
    }
    
    VirgilKeyChainContainer * container = [VirgilKeyChain loadContainer : account];
    if (container) {
        if (nil != container.privateKey) {
            res.status = container.isActive ? statusAllDone : statusWaitActivation;
        } else {
            res.status = statusPublicKeyPresent;
        }
    } else {
        if (YES == checkInCloud) {
            VirgilPublicKey * publicKey = [VirgilKeyManager getPublicKey : account];
            res.status = (nil == publicKey) ? statusPublicKeyNotPresent : statusPublicKeyPresent;
        } else {
            res.status = statusPublicKeyNotPresent;
        }
    }
    
    return res;
}

- (NSString *) getMyAccountFromMessage : (Message *)message {
    if (nil == message) return nil;
    
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

- (VirgilKeyChainContainer *) getKeysContainer : (NSString *) account
                            forcePrivateKeyGet : (BOOL) forcePrivateKey
                            forceActiveAccount : (BOOL) forceActiveAccount {
    VLogInfo(@"getKeysContainer  account : %@  NeedPrivateKey : %hhd", account, forcePrivateKey);
    if (nil == account) return nil;
    VirgilKeyChainContainer * container = [VirgilKeyChain loadContainer : account];
    
    if (nil != container &&
        nil != container.publicKey &&
        nil != container.privateKey &&
        (!forceActiveAccount || (YES == container.isActive))) {
        VLogInfo(@"Container present in KeyChain");
        return container;
    }
    
    if (nil != container) {
        VLogInfo(@"Container in KeyChain : %@", container);
    }
    
    VirgilPrivateKey * privateKey = container.privateKey;
    if ((nil == container || nil == privateKey) && forcePrivateKey) {
        VLogInfo(@"GUI request for account login");
        //privateKey = [VirgilGui getPrivateKey : account];
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
    if (!jsonData) {
        VLogError(@"JSON creation error: %@", error.localizedDescription);
        return nil;
    }
    
    NSString * fixedSender = [self getEmailFromFullName : sender];
    VirgilKeyChainContainer * container = [self getKeysContainer : fixedSender
                                              forcePrivateKeyGet : YES
                                              forceActiveAccount : YES];
    if (nil == container || nil == container.privateKey) return nil;

    // Get all public keys
    NSMutableArray * publicKeys = [[NSMutableArray alloc] init];
    
    VirgilPublicKey * publicKeyForSender = [VirgilKeyManager getPublicKey : fixedSender];
    if (nil == publicKeyForSender) return nil;
    [publicKeys addObject : publicKeyForSender];
    
    VLogInfo(@"sender : %@", sender);
    VLogInfo(@"receivers : %@", receivers);
    
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
                                                    signature : signature
                                                       sender : fixedSender
                                                      version : @"stub_ver"];

    // Prepare base64 result data
    NSData *jsonEncryptedData = [NSJSONSerialization dataWithJSONObject : [encryptedContent toDictionary]
                                                                options : 0
                                                                  error : &error];
    if (!jsonEncryptedData) {
        VLogError(@"JSON creation error: %@", error.localizedDescription);
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
        NSString * container = @"<!DOCTYPE html><html lang='en-US'><head><meta charset='utf-8'></head><body><p>%@</p></body></html>";
        HTMLConverter * htmlCreator = [[HTMLConverter alloc] init];
        htmlBody = [NSString stringWithFormat : container, [htmlCreator toHTML : body]] ;
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

- (NSString *) baseMailPlain {
    return @"The message has been encrypted with Virgil Security Plugin.\n"
    "Download Virgil Security Plugin. <https://virgilsecurity.com/downloads/>";
}

- (NSString *) baseMailHTML {
    return @"<!DOCTYPE html>\n"
    "<html lang='en-US'>\n"
    "<head>\n"
    "<meta charset='utf-8'>\n"
    "</head>\n"
    "<body style='background-color: #f2f2f2; padding: 30px;'>\n"
    "<table align='center' width='460' cellspacing='0' ce               яяllpadding='0'>\n"
    "<tr>\n"
    "<td style='padding: 0px; margin: 0px;' width='100&#37;'>\n"
    "<table align='center' width='100&#37;'cellspacing='0' cellpadding='0'>\n"
    "<tr>\n"
    "<td style='padding: 0px; margin: 0px; \nbackground-color: #be1d1d; border-top-left-radius: 6px;\n"
    "border-top-right-radius: 6px; text-align: center;' width='100&#37;' height='140'>\n"
    "<img src='https://api.virgilsecurity.com/img/logo_mail.png?1441111690'\n"
    "alt='Virgil Security, Inc' title='Virgil Security, Inc' />\n"
    "</td>\n"
    "</tr>\n"
    "<tr>\n"
    "<td style='padding: 0px; margin: 0px; \npadding: 40px 50px 20px 50px; background-color: #ffffff;\n"
    " border-bottom-left-radius: 6px; border-bottom-right-radius: 6px; \nfont-family: 'Arial'; color: #1e2834;' width='100&#37;'>\n"
    "<h1 style='padding: 0px; margin: 0px; font-size: 24px; color: #1e2834;'>Welcome</h1>\n"
    "<h2 style='padding: 0px; margin: 0px; font-weight: normal; font-size: 18px; padding-top: 15px; color: #1e2834;'>\n"
    "The message has been encrypted with Virgil Mail Plugin.\n"
    "</h2>\n"
    "<h2 style='padding: 0px; margin: 0px; font-weight: normal; font-size: 18px; color: #1e2834;'>\n"
    "<a href='https://virgilsecurity.com/downloads/'>Download Virgil Mail Plugin.</a>\n"
    "</h2>\n"
    "<h3 style='padding: 0px; margin: 0px; \ncolor: #999999; padding-top: 70px; font-size: 14px; font-weight: normal;'>\n"
    "&copy; 2015 Virgil Security, Inc\n"
    "</h3>\n"
    "<input id='virgil-info' type='hidden' value='%@' />\n"
    "</td></tr></table></td></tr></table></body></html>";
}

@end
