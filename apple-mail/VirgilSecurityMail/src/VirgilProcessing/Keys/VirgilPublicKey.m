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

#import "VirgilPublicKey.h"

#define kAccountID      @"AccountID"
#define kPublicKeyID    @"PublicKeyID"
#define kPublicKey      @"PublicKey"

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

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject : self.accountID forKey : kAccountID];
    [encoder encodeObject : self.publicKeyID forKey : kPublicKeyID];
    [encoder encodeObject : self.publicKey forKey : kPublicKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString * a_accountID = [decoder decodeObjectForKey : kAccountID];
    NSString * a_publicKeyID = [decoder decodeObjectForKey : kPublicKeyID];
    NSString * a_publicKey = [decoder decodeObjectForKey : kPublicKey];
    return [self initAccountID : a_accountID
                   publicKeyID : a_publicKeyID
                     publicKey : a_publicKey];
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
