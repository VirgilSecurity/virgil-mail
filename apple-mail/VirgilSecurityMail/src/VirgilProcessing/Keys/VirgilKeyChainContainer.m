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

#import "VirgilKeyChainContainer.h"

#define kPrivateKey         @"PrivateKey"
#define kPublicKey          @"PublicKey"
#define kIsActive           @"IsActive"
#define kIsWaitPrivateKey   @"IsWaitPrivateKey"
#define kIsWaitForDeletion  @"IsWaitForDeletion"

@implementation VirgilKeyChainContainer

+ (id) alloc {
    return [super alloc];
}

- (id) init {
    if ([super init]) {
        _privateKey = nil;
        _publicKey = nil;
        _isActive = YES;
        _isWaitPrivateKey = NO;
        _isWaitForDeletion = NO;
    }
    return self;
}

- (id) initWithPrivateKey : (VirgilPrivateKey *)privateKey
             andPublicKey : (VirgilPublicKey *)publicKey
                 isActive : (BOOL)isActive
         isWaitPrivateKey : (BOOL)isWaitPrivateKey
        isWaitForDeletion : (BOOL)isWaitForDeletion {
    if ([super init]) {
        _privateKey = privateKey;
        _publicKey = publicKey;
        _isActive = isActive;
        _isWaitPrivateKey = isWaitPrivateKey;
        _isWaitForDeletion = isWaitForDeletion;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject : _privateKey forKey : kPrivateKey];
    [encoder encodeObject : _publicKey forKey : kPublicKey];
    [encoder encodeBool : _isActive forKey : kIsActive];
    [encoder encodeBool : _isWaitPrivateKey forKey : kIsWaitPrivateKey];
    [encoder encodeBool : _isWaitForDeletion forKey : kIsWaitForDeletion];
}

- (id)initWithCoder:(NSCoder *)decoder {
    VirgilPrivateKey * privateKey = [decoder decodeObjectForKey : kPrivateKey];
    VirgilPublicKey * publicKey = [decoder decodeObjectForKey : kPublicKey];
    BOOL active = [decoder decodeBoolForKey : kIsActive];
    BOOL waitPrivateKey = [decoder decodeBoolForKey : kIsWaitPrivateKey];
    BOOL waitForDeletion = [decoder decodeBoolForKey : kIsWaitForDeletion];
    return [self initWithPrivateKey : privateKey
                       andPublicKey : publicKey
                           isActive : active
                   isWaitPrivateKey : waitPrivateKey
                  isWaitForDeletion : waitForDeletion];
}

- (NSString *) description {
    NSMutableString * res = [[NSMutableString alloc] init];
    [res appendString:@"VirgilKeyChainContainer : \n"];
    [res appendString:@"{ \n"];
    [res appendFormat:@"privateKey : %@\n", [_privateKey description]];
    [res appendFormat:@"publicKey : %@\n", [_publicKey description]];
    [res appendFormat:@"isActive : %hhd\n", _isActive];
    [res appendFormat:@"isWaitPrivateKey : %hhd\n", _isWaitPrivateKey];
    [res appendFormat:@"isWaitForDeletion : %hhd\n", _isWaitForDeletion];
    [res appendString:@"} \n"];
    return res;
}

@end
