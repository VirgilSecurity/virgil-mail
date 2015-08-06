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
#import "NSData+Base64.h"

@implementation VirgilProcessingManager

+ (BOOL) isNeedToDecrypt {
    //TODO: 1. Check for manual selection
    //      2. Check for open purpose. Decrypt on reading only.
    //      3. Check for preview disabled.
    return YES;
}

+ (BOOL) isEncryptedByVirgil : (MimePart *)topMimePart {
    return [self partWithVirgilSignature:topMimePart] != nil;
}

+ (MimePart *) partWithVirgilSignature : (MimePart *)topMimePart {
    // Iterate throw all MimePart to find part with virgil marker
    
    if ([self isPartContainsVirgilSignature:topMimePart]) {
        return topMimePart;
    }
   
    for(MimePart *part in [topMimePart subparts]) {
        if ([self isPartContainsVirgilSignature:part]) {
            return part;
        } else {
            // Recursive search
            MimePart * res = [self partWithVirgilSignature:part];
            if (res != nil) {
                return res;
            }
        }
    }
    
    return nil;
}

+ (BOOL) isPartContainsVirgilSignature : (MimePart *)mimePart {
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

+ (NSData *) encryptedContent : (MimePart *) mimePart {
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
    return nil;
}

+ (id) decryptMessage:(Message *)message topMimePart:(MimePart *)topMimePart {
    if ([VirgilProcessingManager isEncryptedByVirgil:topMimePart]) {
        NSLog(@"Virgil e-mail !");
        
        
        VirgilEncryptorContainer * encryptorContainer =
            [VirgilProcessingManager prepareDataForDecryptor:message
                                                 topMimePart:topMimePart];
        
        if (nil == encryptorContainer) return nil;
        if (NO == [VirgilProcessingManager getKeysToContainer:&encryptorContainer]) return nil;
        if (NO == [VirgilCryptoLibWrapper decryptContainer:&encryptorContainer]) return nil;
        
        //TODO: Return decrypted email
    }
    
    return nil;
}

+ (BOOL) getKeysToContainer:(VirgilEncryptorContainer **) container {
    // Use constant values for this time
    (*container)->privateKey = [NSString stringWithFormat:@"-----BEGIN PRIVATE KEY-----\n"
    "MIHsAgEAMBQGByqGSM49AgEGCSskAwMCCAEBDQSB0DCBzQIBAQRAYfsONejc+RyL\n"
    "LS0tLS1CRUdJTiBFQyBQUklWQVRFIEtFWS0tLS0tCk1JSGFBZ0VCQkVCRkVKSzRD\n"
    "cUlWUVN5UWN0SWZkTUZlemdhbkhvSkxLeTBUM2pnY2kwdGtLK3FoUHdiYXJhVHMK\n"
    "alB1OU1uNElORm9JQ0pZc0lmU1RMR3RSVzhsNC9ZendvQXNHQ1Nza0F3TUNDQUVC\n"
    "RGFHQmhRT0JnZ0FFSE5EdApRSklzSTRTaFp1V21BK0gxdkNuU1g2UmdiaTNDa0Vq\n"
    "aHA4VnVqTGI0WXJLZUVjeUh1blhyYlAyVXR4aE1Cb29oCjFSMG95MitpMTZrU29x\n"
    "T3huWDBxY0I4eUkyZ25xSDJpeVorY1ZTdTY1NVVtOE9IVUZLczU3OXdSRStmYWw3\n"
    "dm8KeUhnRlh4ZmF3aUlyYTZ3K1Bud0ZHREErSDhxUkFsWHJmMFFMSDdBPQotLS0t\n"
    "LUVORCBFQyBQUklWQVRFIEtFWS0tLS0tCg==\n"
    "-----END PRIVATE KEY-----"];
    
    (*container)->publicKeyID = @"57ce8392-92c9-4a05-14ad-cd4a1651cce4";
    return YES;
}

+ (VirgilEncryptorContainer *) prepareDataForDecryptor:(Message *)message topMimePart:(MimePart *)topMimePart {

    MimePart * encryptedContentPart = [self partWithVirgilSignature:topMimePart];
    
    if (encryptedContentPart != nil) {
        VirgilEncryptorContainer *res = [[VirgilEncryptorContainer alloc] init];
    
        res->content = [self encryptedContent:encryptedContentPart];
        res->sender = [message sender];
        // TODO: Get receivers.
        NSMutableArray * receivers = [[NSMutableArray alloc] init];
        res->receivers = receivers;
        res->isEncrypted = YES;
    
        return res;
    }
    return nil;
}

@end
