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

#import "VirgilErrorCodesParser.h"

@implementation VirgilErrorCodesParser

NSDictionary * _errorCodes = nil;

+ (void) initCodes {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _errorCodes = @{
                        // Authentication Errors
                        @"20001" : @"Password validation failed",
                        @"20002" : @"User data validation failed",
                        @"20003" : @"Container was not found",
                        @"20004" : @"Token validation failed",
                        @"20005" : @"Token not found",
                        @"20006" : @"Token has expired",
                        
                        // Request Sign Errors
                        @"30001" : @"Request Sign validation failed",
                        
                        // Private Keys Errors
                        @"50001" : @"Public Key ID validation failed",
                        @"50002" : @"Public Key ID was not found",
                        @"50003" : @"Public Key ID already exists",
                        @"50004" : @"Private key validation failed",
                        @"50005" : @"Private key base64 validation failed",
                        
                        // UUID errors
                        @"80001" : @"UUID(`request_sign_uuid`) request parameter validation failed",
                        @"80002" : @"UUID(`request_sign_uuid`) has already used in another call. Please generate another one."
                        };
    });
}

+ (NSString *) readableErrorFromJSON : (NSData *) jsonData {
    if (nil == jsonData) return nil;
    
    NSError * error;
    id resultJSON = [NSJSONSerialization JSONObjectWithData : jsonData
                                                    options : 0
                                                      error : &error];
    if(nil != error) return nil;
    
    if([resultJSON isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dictError = [resultJSON objectForKey : @"error"];
        if (nil == dictError) return nil;
        NSString * errorCode =
            [[NSString alloc] initWithFormat : @"%@", [dictError objectForKey : @"code"]];
        if (nil == errorCode) return nil;
        [VirgilErrorCodesParser initCodes];
        NSString * decryptedCode = [_errorCodes objectForKey : errorCode];
        return decryptedCode ?  decryptedCode : errorCode;
    }
    return nil;
}

@end
