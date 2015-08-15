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

- (id) initAccountID:(NSString *)a_accountID
         publicKeyID:(NSString *)a_publicKeyID
           publicKey:(NSString *)a_publicKey {
    if ([super init]) {
        self.accountID = [[NSString alloc] initWithString:a_accountID];
        self.publicKeyID = [[NSString alloc] initWithString:a_publicKeyID];
        self.publicKey = [[NSString alloc] initWithString:a_publicKey];
    }
    return self;
}

- (NSString *) description {
    NSMutableString * res = [[NSMutableString alloc] init];
    [res appendString:@"VirgilPublicKey : \n"];
    [res appendString:@"{ \n"];
    [res appendFormat:@"accountID : %@\n", self.accountID];
    [res appendFormat:@"publicKeyID : %@\n", self.publicKeyID];
    [res appendFormat:@"publicKey : %@\n", self.publicKey];
    [res appendString:@"} \n"];
    return res;
}

@end
