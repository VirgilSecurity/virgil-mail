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

#import "VirgilSignInViewController.h"
#import "NSViewController+VirgilView.h"
#import "VirgilKeyManager.h"
#import "VirgilErrorViewController.h"
#import "VirgilValidator.h"
#import "VirgilGui.h"
#import "VirgilProcessingManager.h"
#import "VirgilLog.h"

@implementation VirgilSignInViewController

- (IBAction)onSignInClicked:(id)sender {
    NSSecureTextField * passwordField = [self.view viewWithTag : 2001];
    
    if (!passwordField) return;
    
    NSString * email = [self selectedAccount];
    NSString * password = [passwordField stringValue];
    
    if (NO == [VirgilValidator simplePassword : password]) {
        [self showCompactErrorView : @"Password can't be empty, can't contains not latin letters."
                            atView : passwordField];
        return;
    }
    
    [self setProgressVisible:YES];
    [self preventUserActivity:YES];

    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            VirgilPrivateKey * res = [VirgilKeyManager getPrivateKey : email
                                                   containerPassword : password];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self externalActionDone];
                if (nil == res) {
                    [self showErrorView : [VirgilKeyManager lastError]];
                } else {
                    [VirgilGui setUserActivityPrivateKey : res];
                    [self onCloseClicked:nil];
                }
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (NSString *) selectedAccount {
    NSPopUpButton * popUpButton = [self.view viewWithTag : 5000];
    if (!popUpButton) return nil;
    
    return [popUpButton titleOfSelectedItem];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSPopUpButton * popUpButton = [self.view viewWithTag : 5000];
    if (!popUpButton) return;
    
    [popUpButton removeAllItems];
    NSArray * accounts = [VirgilProcessingManager accountsList];
    if ([accounts count]) {
        [popUpButton addItemsWithTitles : accounts];
        BOOL accountPresent = NO;
        for (NSString * el in accounts) {
            if ([el isEqualToString : [VirgilGui currentAccount]]) {
                accountPresent = YES;
                break;
            }
        }
        
        if (YES == accountPresent) {
            [popUpButton selectItemWithTitle : [VirgilGui currentAccount]];
        }
    }
}

- (IBAction)onCloseClicked:(id)sender {
    [self closeWindow];
}

- (IBAction)onForgotClicked:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://virgilsecurity.com/reset"];
    [[NSWorkspace sharedWorkspace] openURL : url];
}

- (IBAction)onSignUpClicked:(id)sender {
    [self changeView : @"viewRegister"];
}

- (IBAction)onResendConfirm:(id)sender {
    NSTextField * emailField = [self.view viewWithTag : 2000];
    
    if (!emailField) return;
    
    NSString * email = [emailField stringValue];

    BOOL res = [VirgilKeyManager resendConfirmEMail : email];
    
    if (NO == res) {
        [self showErrorView : [VirgilKeyManager lastError]];
    } else {
        [VirgilGui setUserActivityPrivateKey : nil];
        [self onCloseClicked:nil];
    }
}

@end
