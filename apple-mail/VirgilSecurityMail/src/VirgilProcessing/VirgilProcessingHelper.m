//
//  VirgilChecker.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 31.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilProcessingHelper.h"
#import <string.h>
#import "HTMLParser.h"

@implementation VirgilProcessingHelper

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
        NSLog(@"isPartContainsVirgilSignature mime is : %@/%@", [mimePart type], [mimePart subtype]);
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
    NSLog(@"???");
    return NO;
}

+ (NSDictionary *) prepareDataForDecryptor:(Message *)message topMimePart:(MimePart *)topMimePart {
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    NSLog(@"Subject : %@", [message subject]);
    NSLog(@"Sender : %@", [message sender]);
    //TODO: Fill it
    return res;
}


@end
