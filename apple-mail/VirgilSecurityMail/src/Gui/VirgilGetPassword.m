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

#import "VirgilGetPassword.h"
#import "VirgilKeyManager.h"
#import "VirgilGui.h"
#import "NSViewController+VirgilView.h"

static NSString * _password = nil;

@implementation VirgilGetPassword

NSString * _publicKey = nil;
NSString * _privateKey = nil;

- (IBAction)onOkClicked:(id)sender {
    _password = _passwordField.stringValue;
    if ([VirgilKeyManager isCorrectKeys : _publicKey
                             privateKey : _privateKey
                               password : _password]) {
        [self closeWindow];
    } else {
        [VirgilGui showError:@"Wrong password for key"];
        _passwordField.stringValue = @"";
    }
}

- (IBAction)onCancelClicked:(id)sender {
    _password = nil;
    [self closeWindow];
}

- (void) setKeyPair : (NSString *)publicKey
         privateKey : (NSString *)privateKey {
    _publicKey = publicKey;
    _privateKey = privateKey;
}

+ (NSString *) password {
    return _password;
}

@end
