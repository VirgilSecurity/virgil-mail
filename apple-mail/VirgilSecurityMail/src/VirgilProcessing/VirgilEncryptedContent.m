//
//  VirgilEncryptedContent.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 01.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilEncryptedContent.h"
#import <NSData+Base64.h>

@implementation VirgilEncryptedContent

+ (id) alloc {
    return [super alloc];
}

- (id) init {
    if ([super init]) {
        self.emailData = [[NSData alloc] init];
        self.signature = [[NSData alloc] init];
    }
    return self;
}

- (id) initWithEmailData : (NSData *)a_emailData
            andSignature : (NSData *)a_signature {
    if ([super init]) {
        self.emailData = [[NSData alloc] initWithData:a_emailData];
        self.signature = [[NSData alloc] initWithData:a_signature];
    }
    return self;
}

- (NSDictionary *) toDictionary {
    NSDictionary * res = @{@"EmailData" : [self.emailData base64EncodedString],
                           @"Sign" : [self.signature base64EncodedString]};
    return res;
}

- (NSString *) description {
    NSMutableString * res = [[NSMutableString alloc] init];
    [res appendString:@"VirgilEncryptedContent : \n"];
    [res appendString:@"{ \n"];
    [res appendFormat:@"EmailData : %@\n", [self.emailData base64EncodedString]];
    [res appendFormat:@"Sign : %@\n", [self.signature base64EncodedString]];
    [res appendString:@"} \n"];
    return res;
}

@end
