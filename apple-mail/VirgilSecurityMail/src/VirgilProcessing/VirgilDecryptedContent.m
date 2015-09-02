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

#import "VirgilDecryptedContent.h"

@implementation VirgilDecryptedContent
+ (id) alloc {
    return [super alloc];
}

- (id) init {
    if ([super init]) {
        self.subject = @"";
        self.body = @"";
        self.htmlBody = @"";
    }
    return self;
}

- (id) initWithSubject:(NSString *)asubject
                  body:(NSString *)abody
              htmlBody:(NSString *)ahtmlBody {
    if ([super init]) {
        self.subject = [[NSString alloc] initWithString:asubject];
        self.body = [[NSString alloc] initWithString:abody];
        self.htmlBody = [[NSString alloc] initWithString:ahtmlBody];
    }
    return self;
}

- (NSDictionary *) toDictionary {
    NSDictionary * res = @{@"UniqueId" : @"replace me with GUID :)",
                           @"Body" : self.body,
                           @"HtmlBody" : self.htmlBody,
                           @"Subject" : self.subject};
    return res;
}

- (NSString *) description {
    NSMutableString * res = [[NSMutableString alloc] init];
    [res appendString:@"VirgilDecryptedContent : \n"];
    [res appendString:@"{ \n"];
    [res appendFormat:@"subject : %@\n", self.subject];
    [res appendFormat:@"body : %@\n", self.body];
    [res appendFormat:@"htmlBody : %@\n", self.htmlBody];
    [res appendString:@"} \n"];
    return res;
}

@end
