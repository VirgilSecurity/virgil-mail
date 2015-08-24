//
//  VirgilPrivateKey.m
//  TestGUI
//
//  Created by Роман Куташенко on 24.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilPrivateKey.h"

@implementation VirgilPrivateKey
+ (id) alloc {
    return [super alloc];
}

- (id) init {
    if ([super init]) {
        self.account = @"";
        self.password = @"";
        self.key = @"";
    }
    return self;
}

- (id) initAccount : (NSString *)a_account
          password : (NSString *)a_password
        privateKey : (NSString *)a_key {
    if ([super init]) {
        self.account = [[NSString alloc] initWithString : a_account];
        self.password = [[NSString alloc] initWithString : a_password];
        self.key = [[NSString alloc] initWithString : a_key];
    }
    return self;
}

// TODO: Remove it !
- (NSString *) description {
    NSMutableString * res = [[NSMutableString alloc] init];
    [res appendString:@"VirgilPrivateKey : \n"];
    [res appendString:@"{ \n"];
    [res appendFormat:@"account : %@\n", self.account];
    [res appendFormat:@"password : %@\n", self.password];
    [res appendFormat:@"key : %@\n", self.key];
    [res appendString:@"} \n"];
    return res;
}
@end
