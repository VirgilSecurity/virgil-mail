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

#import "VirgilRegisterViewController.h"
#import "VirgilKeyManager.h"
#import "NSViewController+VirgilView.h"
#import "VirgilValidator.h"
#import "VirgilKeysGui.h"
#import "VirgilKeyChain.h"

@implementation VirgilRegisterViewController

- (IBAction)onSignUpClicked:(id)sender {
    NSTextField * emailField = [self.view viewWithTag : 1000];
    NSSecureTextField * passwordField = [self.view viewWithTag : 1001];
    NSSecureTextField * passwordRetypeField = [self.view viewWithTag : 1002];
    
    if (!emailField || !passwordField || !passwordRetypeField) return;
    
    NSString * email = [emailField stringValue];
    NSString * password = [passwordField stringValue];
    NSString * passwordRetype = [passwordRetypeField stringValue];
    
    // Verify input data
    if (NO == [VirgilValidator email : email]) {
        [self showCompactErrorView : @"Check email address input please."
                            atView : emailField];
        return;
    }
    
    if (NO == [VirgilValidator simplePassword : password]) {
        [self showCompactErrorView : @"Password can't be empty, can't contains not latin letters."
                            atView : passwordField];
        return;
    }
    
    if (NO == [passwordRetype isEqualToString : password]) {
        [self showCompactErrorView : @"Passwords shoud be equal in both fields."
                            atView : passwordRetypeField];
        return;
    }
    
    if ([VirgilKeyManager createAccount : email
                            keyPassword : nil
                          containerType : VirgilContainerEasy
                      containerPassword : password]) {
        VirgilKeyChainContainer * container =
            [[VirgilKeyChainContainer alloc] initWithPrivateKey : [VirgilKeyManager newAccountPrivateKey]
                                                   andPublicKey : [VirgilKeyManager newAccountPublicKey]
                                                       isActive : NO];
        [VirgilKeyChain saveContainer : container
                           forAccount : email];
        [self closeWindow];
    } else {
        [self showErrorView : [VirgilKeyManager lastError]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSTextField * emailField = [self.view viewWithTag : 1000];
    if (!emailField) return;
    NSString * currentAccount = [VirgilKeysGui currentAccount];
    if (nil == currentAccount) return;
    [emailField setStringValue : currentAccount];
}

@end
