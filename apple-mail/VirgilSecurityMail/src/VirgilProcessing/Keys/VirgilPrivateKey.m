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

#import "VirgilPrivateKey.h"

@implementation VirgilPrivateKey
+ (id) alloc {
    return [super alloc];
}

- (id) init {
    if ([super init]) {
        self.account = @"";
        self.containerType = VirgilContainerUnknown;
        self.key = @"";
        self.keyPassword = @"";
        self.containerPassword = @"";
    }
    return self;
}

- (id) initAccount : (NSString *)a_account
     containerType : (VirgilContainerType)a_containerType
        privateKey : (NSString *)a_key
       keyPassword : (NSString *)a_keyPassword
 containerPassword : (NSString *)a_containerPassword {
    if ([super init]) {
        self.account = [[NSString alloc] initWithString : a_account];
        self.containerType = a_containerType;
        self.key = [[NSString alloc] initWithString : a_key];
        self.keyPassword = (nil == a_keyPassword) ? nil : [[NSString alloc] initWithString : a_keyPassword];
        self.containerPassword = [[NSString alloc] initWithString : a_containerPassword];
    }
    return self;
}

// TODO: Remove it !
- (NSString *) description {
    NSMutableString * res = [[NSMutableString alloc] init];
    [res appendString:@"VirgilPrivateKey : \n"];
    [res appendString:@"{ \n"];
    [res appendFormat:@"account : %@\n", self.account];
    [res appendFormat:@"containerType : %ld\n", (long)self.containerType];
    [res appendFormat:@"keyPassword : %@\n", self.keyPassword];
    [res appendFormat:@"containerPassword : %@\n", self.containerPassword];
    [res appendFormat:@"key : %@\n", self.key];
    [res appendString:@"} \n"];
    return res;
}
@end