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

#import "VirgilActionsViewController.h"
#import "VirgilStorageSetViewController.h"
#import "VirgilKeyManager.h"
#import "VirgilKeyChain.h"
#import "VirgilValidator.h"
#import "VirgilGui.h"
#import "NSViewController+VirgilView.h"
#import "VirgilLog.h"

#define VIRGILKEY_EXTENTION @"virgilkey"

@implementation VirgilActionsViewController

- (IBAction)onExportKeyClicked:(id)sender {
}

- (IBAction)onRemoveKeyFromCloud:(id)sender {
}

- (IBAction)onRemoveKeyFromKeyChain:(id)sender {
    if (nil == _account) return;
    [VirgilKeyChain removeContainer : _account];
    [self delegateRefresh];
}

- (IBAction)onCreateKeysClicked:(id)sender {
    if (nil == _account) return;
    VirgilStorageSetViewController * controller = (VirgilStorageSetViewController *)[self showSheetView:@"viewKeyStorage"];
    if (controller) {
        controller.account = _account;
        controller.delegate = _delegate;
    }
}

- (IBAction)onLoadKeyClicked:(id)sender {
    BOOL useCloudStorage = NSOnState == [[_matrixField cellAtRow:0 column:0] state];
    
    NSString * password = _cloudPassword.stringValue;
    
    if (NO == [VirgilValidator simplePassword : password]) {
        [self showCompactErrorView : @"Password can't be empty, can't contains not latin letters."
                            atView : _cloudPassword];
        return;
    }
    
    [self setProgressVisible:YES];
    [self preventUserActivity:YES];
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            VirgilPrivateKey * encryptedKey = nil;
            if (useCloudStorage) {
                encryptedKey = [VirgilKeyManager getEncryptedPrivateKeyFromCloud:_account containerPassword:password];
            } else {
                //TODO:
            }
            
            VirgilPrivateKey * decryptedKey = nil;
            NSString * errorStr = nil;
            if (nil == encryptedKey) {
                errorStr = @"Can't find need key or wrong password";
            } else {
                decryptedKey = [VirgilKeyManager decryptedPrivateKey:encryptedKey keyPassword:password];
                
                if (nil == decryptedKey) {
                    NSString * userPassword = [VirgilGui getUserPassword];
                    if (nil != userPassword) {
                        errorStr = @"Wrong key password";
                        decryptedKey = [VirgilKeyManager decryptedPrivateKey:encryptedKey keyPassword:userPassword];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (nil == decryptedKey && nil != errorStr) {
                    [self showErrorView : errorStr];
                }
                [self delegateRefresh];
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (BOOL) importKey {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowedFileTypes:[NSArray arrayWithObjects:VIRGILKEY_EXTENTION, nil]];
    
    [openDlg beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (NSModalResponseOK == result) {
            NSArray* urls = [openDlg URLs];
            for(int i = 0; i < [urls count]; i++ ) {
                NSString* url = [urls objectAtIndex:i];
                VLogInfo(@"Url: %@", url);
            }
        }
    }];
    
    return NO;
}

- (IBAction)onSourceChanged:(id)sender {
    BOOL useCloudStorage = NSOnState == [[_matrixField cellAtRow:0 column:0] state];
    NSString * palceHolder = useCloudStorage ? @"Cloud password" : @"Key file password";
    [_cloudPassword setPlaceholderString : palceHolder];
}

- (IBAction)onResendConfirmationClicked:(id)sender {
    [self setProgressVisible:YES];
    [self preventUserActivity:YES];
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL res = [VirgilKeyManager resendConfirmEMail : _account];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self externalActionDone];
                if (res) {
                    //[self delegateRefresh];
                    _infoTextField.stringValue = @"Please wait for email with confirmation code";
                } else {
                    [self showErrorView : [VirgilKeyManager lastError]];
                }
                [self setProgressVisible:NO];
                [self preventUserActivity:NO];
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

@end
