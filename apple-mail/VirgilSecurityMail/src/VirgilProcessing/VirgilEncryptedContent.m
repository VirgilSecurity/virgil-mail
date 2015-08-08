//
//  VirgilEncryptedContent.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 01.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilEncryptedContent.h"

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

- (id) initWithEmailData:(NSData *)emailData andSignature:(NSData *)signature {
    if ([super init]) {
        self.emailData = [[NSData alloc] initWithData:emailData];
        self.signature = [[NSData alloc] initWithData:signature];
    }
    return self;
}

@end
