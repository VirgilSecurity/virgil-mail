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

#import "VirgilStorageSetViewController.h"
#import "VirgilValidator.h"
#import "VirgilKeyManager.h"
#import "NSViewController+VirgilView.h"
#import "VirgilLog.h"

@implementation VirgilStorageSetViewController

- (IBAction)onContinueClicked:(id)sender {
    
    BOOL useCloudStorage = NSOnState == [[_radioBtnMatrix cellAtRow:0 column:0] state];
    BOOL useKeyPassword = NSOnState == [_btnProtectWithPassword state];
    
    NSString * cloudPass = nil;
    NSString * cloudPassConfirm = nil;
    
    NSString * keyPass = nil;
    NSString * keyPassConfirm = nil;
    
    if (useCloudStorage) {
        cloudPass = _cloudPassword.stringValue;
        cloudPassConfirm = _cloudPasswordConfirm.stringValue;
        
        if (NO == [VirgilValidator simplePassword : cloudPass]) {
            [self showCompactErrorView : @"Password can't be empty, can't contains not latin letters."
                                atView : _cloudPassword];
            return;
        }
        
        if (NO == [cloudPassConfirm isEqualToString : cloudPass]) {
            [self showCompactErrorView : @"Passwords shoud be equal in both fields."
                                atView : _cloudPasswordConfirm];
            return;
        }
    }
    
    if (useKeyPassword) {
        keyPass = _keyPassword.stringValue;
        keyPassConfirm = _keyPasswordConfirm.stringValue;
        
        if (NO == [VirgilValidator simplePassword : keyPass]) {
            [self showCompactErrorView : @"Password can't be empty, can't contains not latin letters."
                                atView : _keyPassword];
            return;
        }
        
        if (NO == [keyPassConfirm isEqualToString : keyPass]) {
            [self showCompactErrorView : @"Passwords shoud be equal in both fields."
                                atView : _keyPasswordConfirm];
            return;
        }
    }
    
    
    [self setProgressVisible:YES];
    [self preventUserActivity:YES];
    
    @try {
        VirgilContainerType containerType = VirgilContainerUnknown;
        if (useCloudStorage) {
            containerType = useKeyPassword ? VirgilContainerNormal : VirgilContainerEasy;
        } else {
            containerType = VirgilContainerParanoic;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL res = [VirgilKeyManager createAccount : _account
                                           keyPassword : keyPass
                                         containerType : containerType
                                     containerPassword : cloudPass];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self externalActionDone];
                if (res) {
                    [self dismissController:self];
                    [self delegateRefresh];
                } else {
                    [self setProgressVisible:NO];
                    [self preventUserActivity:NO];
                    [self showErrorView : [VirgilKeyManager lastError]];
                }
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (void) delegateRefresh {
    if (_delegate) {
        [_delegate askRefresh];
    }
}

- (IBAction)onStorageChanged:(NSMatrix *)sender {
    NSButtonCell *selCell = [sender selectedCell];
    BOOL isCloudStorage = 1000 == [selCell tag];
    [[self passwordView] setHidden:!isCloudStorage];    
}

- (NSView *) passwordView {
    NSView * res = nil;
    for (id elem in self.view.subviews) {
        NSString * className = NSStringFromClass ([elem class]);
        if ([className isEqualTo:@"NSView"]) {
            res = (NSView *)elem;
            break;
        }
    }
    return res;
}

@end
