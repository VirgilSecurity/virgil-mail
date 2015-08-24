//
//  VirgilPrivateKeyEndpoints.m
//  TestGUI
//
//  Created by Роман Куташенко on 24.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilPrivateKeyEndpoints.h"

@implementation VirgilPrivateKeyEndpoints

+ (id) alloc {
    return [super alloc];
}

- (id) initWithBaseURL : (NSString *)a_baseURL {
    if ([super init]) {
        _baseURL = [[NSString alloc] initWithFormat : @"%@%@/", a_baseURL, @"v2"];
    }
    return self;
}

- (NSString *) getToken {
    return [_baseURL stringByAppendingString : @"authentication/get-token"];
}

- (NSString *) getPrivateKeyByPublicID : (NSString *) publicKeyID {
    return [[NSString alloc] initWithFormat : @"%@%@%@",
            _baseURL,
            @"private-key/public-key-id/",
            publicKeyID];
}

- (NSString *) getKeyPush {
    return [_baseURL stringByAppendingString : @"private-key"];
}

@end
