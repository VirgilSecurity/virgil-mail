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
#import "MimePart.h"
#import "VirgilClassNameResolver.h"
#import "VirgilLog.h"

@implementation VirgilDecryptedMail

+(id)alloc{
    return [super alloc];
}

-(id)init{
    _decryptStatus = decryptUnknown;
    _mailParts = [[NSMutableDictionary alloc] init];
    return [super init];
}

- (void) addPart:(id)part partHash:(id)partHash {
    [_mailParts setValue:part forKey:[self mimeHash:partHash]];
}

- (void) addAttachement:(id)attach attachHash:(id)attachHash {
    [_mailParts setValue:attach forKey:attachHash];
}

- (NSString *) mimeHash : (MimePart *)part {
    struct _NSRange range = [part range];
    return [NSString stringWithFormat:@"%lu_%lu", range.length, range.location];
}

- (id) partByHash:(id)partHash {
    id res = [_mailParts valueForKey:[self mimeHash:partHash]];
    if (nil == res) {
        VLogError(@"PART NOT PRESENT");
    }
    return res;
}

- (id) attachementByHash:(id)attachHash {
    id res = [_mailParts valueForKey:attachHash];
    if (nil == res) {
        VLogError(@"Error: ATTACHEMENT PART NOT PRESENT");
    }
    return res;
}

@end
