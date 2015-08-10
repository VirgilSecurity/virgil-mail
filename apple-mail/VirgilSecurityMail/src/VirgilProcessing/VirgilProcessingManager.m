//
//  VirgilProcessingManager.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 31.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilProcessingManager.h"
#import <string.h>
#import "HTMLParser.h"
#import "VirgilCryptoLibWrapper.h"
#import "VirgilDecryptedMail.h"
#import "NSData+Base64.h"
#import "VirgilEncryptedContent.h"
#import "VirgilDecryptedContent.h"
#import "VirgilPKIManager.h"
#import "VirgilClassNameResolver.h"

#import "MessageStore.h"
#import "MailAccount.h"
#import "LocalAccount.h"
#import "MFMessageAddressee.h"

@implementation VirgilProcessingManager

+ (VirgilProcessingManager *) sharedInstance {
    static VirgilProcessingManager * singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    
    return singletonObject;
}

+(id)alloc{
    return [super alloc];
}

-(id)init{
    _decryptedMail = [[VirgilDecryptedMail alloc] init];
    return [super init];
}

- (BOOL) isNeedToDecrypt {
    //TODO: 1. Check for manual selection
    //      2. Check for open purpose. Decrypt on reading only.
    //      3. Check for preview disabled.
    return YES;
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
- (NSData *) getEncryptedContent : (MimePart *) mimePart {
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

- (NSString * ) getPrivateKeyForAccount:(NSString *)account {
    // Use constant value for this time
    return @"MIGfAgEAMIGZBgkqhkiG9w0BBwOggYswgYgCAQMxV6NVMFMCAQAwJAYKKoZIhvcNAQwBAzAWBBAMKuoeF3fDHXJ5qAeaK4NTAgIIAAQosVGG15kw52JBtZ07I/QX08Sfb1A3snrkClkR2Y8uYAJU/pKmDv3y2jAqBgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBBvH7Oitl+lSt2Gpg/YQ3/Wsr6q5KhXokHSQQcUyBQ3raTUY5pR7vY/BC534ItgPJygpvVS1Z6yFukzePXordVYvJ748CN+qtCTHmIFx41c64mXgH80XBLBuWiiDpeAwSKuXVjAte9ZtM2cksiRFXzUFm7l3cx3RUG6hC3J2CMDI61bHTc95MqBCrLX6sNi5NVvwCfxaEasUqwVxlPjkfHX1wwXNJbcKVVaubEXw1IoM2ZywjOwkQHm3okBFbfiqWEptv25r5h2pTrvwS/xuRZSeYcGAIVxn5BpEXrX+wKyA1LL0/nn4JHFa1Zsx5mM/PjUisK4SfArJVHRFhpTc8WxMBXV/i0k5FAczP5vF2uBerYxyjdpHF8mTA9aafXOGXJNmrZKCc5EhwfQeYGagzS5HexLprFB6ZGnCllQOrkajg8p45CTNCtuMsjv82TcJniwT7DtFBMhYmVOUHHgzVZpwKBKa52v3w5kpZ3XFCrR7duwHS4kkltFC8kRn6O7WPI=";
}

- (NSString * ) getPublicIdForAccount:(NSString *)account {
    VirgilPublicKey * publicKey = [VirgilPKIManager getPublicKey:account];
    if (nil == publicKey) return nil;
    return publicKey.publicKeyID;
}

- (NSString * ) getPrivateKeyPasswordForAccount:(NSString *)account {
    // Use constant value for this time
    return @"ram12345";
}

// Get EmailData and signature
- (VirgilEncryptedContent *) getMainEncryptedData:(NSData *)data {
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
    NSData * signatureData = [[NSData alloc] init];

    return [[VirgilEncryptedContent alloc] initWithEmailData:emailData
                                                andSignature:signatureData];
}

- (VirgilDecryptedContent *) decryptContent:(VirgilEncryptedContent *) content
                                publicKeyId:(NSString *) publicKeyId
                                 privateKey:(NSString *) privateKey
                         privateKeyPassword:(NSString *) privateKeyPassword {
    
    NSData * decryptedJsonData = [VirgilCryptoLibWrapper decryptData:content.emailData
                                                         publicKeyId:publicKeyId
                                                          privateKey:privateKey
                                                  privateKeyPassword:privateKeyPassword];
    
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

- (NSData *) getEncryptedAttachement:(MimePart *)part {
    if (![[part disposition] isEqualToString:@"attachment"]) return nil;
    if (![part.contentTransferEncoding isEqualToString:@"base64"]) return nil;
    NSData *bodyData = [part bodyData];
    NSString* strBody = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    return bodyData;
}

- (BOOL) decryptWholeMessage:(MimePart *)topMimePart {
    MimePart * mainVirgilPart = [self partWithVirgilSignature:topMimePart];
    if (nil == mainVirgilPart) return NO;
    Message * message = [(MimeBody *)[topMimePart mimeBody] message];
    NSSet * allMimeParts = [self allMimeParts:topMimePart];
    NSString * sender = [message sender];
    NSString * receiver = [self getMyAccountFromMessage:message];
    NSString * publicId = [self getPublicIdForAccount:receiver];
    NSString * privateKey = [self getPrivateKeyForAccount:receiver];
    NSString * privateKeyPassword = [self getPrivateKeyPasswordForAccount:receiver];
    VirgilEncryptedContent * encryptedContent = [self getMainEncryptedData:
                                                 [self getEncryptedContent:mainVirgilPart]];
    
    if (nil == receiver ||
        nil == publicId ||
        nil == privateKey) {
        NSLog(@"ERROR : Can't decrypt message !");
        return NO;
    }
    VirgilDecryptedContent * decryptedContent = [self decryptContent:encryptedContent
                                                         publicKeyId:publicId
                                                          privateKey:privateKey
                                                  privateKeyPassword:privateKeyPassword];
    
    
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
                                                                 privateKey:privateKey
                                                         privateKeyPassword:privateKeyPassword];
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
        // Current email isn't decripted by Virgil
        return nil;
    }
    
    Message * currentMessage = [(MimeBody *)[mimePart mimeBody] message];

    if (![_decryptedMail isCurrentMail:currentMessage]) {
        [self decryptWholeMessage:topMimePart];
    }
    
    return [_decryptedMail partByHash:mimePart];
}

- (MimePart *) topLevelPartByAnyPart:(MimePart *)part {
    MimePart * res = (MimePart *)part;
    while ([res parentPart] != nil) {
        res = [res parentPart];
    }
    return res;
}

- (NSData *) decryptedAttachementByName:(NSString *) name {
    if (nil == name) return nil;
    return [_decryptedMail attachementByHash:name];
}

- (NSString * ) getMyAccountFromMessage:(Message *)message {
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
    
    return nil;
}

@end
