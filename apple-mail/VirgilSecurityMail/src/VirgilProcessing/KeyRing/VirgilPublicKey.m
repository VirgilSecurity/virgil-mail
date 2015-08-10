//
//  VirgilPublicKey.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 10.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilPublicKey.h"

@implementation VirgilPublicKey : NSObject 

+ (id) alloc {
    return [super alloc];
}

- (id) init {
    if ([super init]) {
        self.accountID = @"";
        self.publicKeyID = @"";
        self.publicKey = @"";
    }
    return self;
}

- (id) initAccountID:(NSString *)_accountID
         publicKeyID:(NSString *)_publicKeyID
           publicKey:(NSString *)_publicKey {
    if ([super init]) {
        self.accountID = [[NSString alloc] initWithString:_accountID];
        self.publicKeyID = [[NSString alloc] initWithString:_publicKeyID];
        self.publicKey = [[NSString alloc] initWithString:_publicKey];
    }
    return self;
}

@end
