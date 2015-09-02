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

#import "VirgilDecryptedMail.h"
#import "MessageBody.h"
#import "Message.h"
#import "VirgilClassNameResolver.h"

@implementation VirgilDecryptedMail

+(id)alloc{
    return [super alloc];
}

-(id)init{
    _curMailHash = 0;
    _mailParts = [[NSMutableDictionary alloc] init];
    return [super init];
}

- (void) clear {
    _curMailHash = 0;
    [_mailParts removeAllObjects];
}

- (BOOL) isEmpty {
    return !_curMailHash;
}

- (NSString *) hashVal:(id)someId {
    return [NSString stringWithFormat:@"%lu", (NSUInteger)someId];
}

- (NSString *) invalidHashVal {
    return [NSString stringWithFormat:@"%lu", (NSUInteger)0];
}

- (void) setCurrentMailHash:(id)hash {
    if ([self isCurrentMail:hash]) {
        [self clear];
    }
    _curMailHash = [self hashVal:hash];
}

- (BOOL) isCurrentMail:(id)someMail {
    return _curMailHash == [self hashVal:someMail];
}

- (void) addPart:(id)part partHash:(id)partHash {
    if ([self isEmpty]) return;
    [_mailParts setValue:part forKey:[self hashVal:partHash]];
}

- (void) addAttachement:(id)attach attachHash:(id)attachHash {
    if ([self isEmpty]) return;
    [_mailParts setValue:attach forKey:attachHash];
}

- (id) partByHash:(id)partHash {
    if ([self isEmpty]) {
        NSLog(@"Error: PART NOT PRESENT");
        return nil;
    }
    return [_mailParts	valueForKey:[self hashVal:partHash]];
}

- (id) attachementByHash:(id)attachHash {
    if ([self isEmpty]) {
        NSLog(@"Error: PART NOT PRESENT");
        return nil;
    }
    return [_mailParts	valueForKey:attachHash];
}

@end
