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
#import "NSViewController+VirgilView.h"
#import "VirgilLog.h"

#define VIRGILKEY_EXTENTION @"virgilkey"

@implementation VirgilActionsViewController

- (IBAction)onExportKeyClicked:(id)sender {
}

- (IBAction)onRemoveKeyFromCloud:(id)sender {
}

- (IBAction)onRemoveKeyFromKeyChain:(id)sender {
}

- (IBAction)onCreateKeysClicked:(id)sender {
    if (nil == _account) return;
    VirgilStorageSetViewController * controller = (VirgilStorageSetViewController *)[self showSheetView:@"viewKeyStorage"];
    if (controller) {
        controller.account = _account;
        controller.delegate = _delegate;
    }
}

- (IBAction)onGetKeyFromCloudClicked:(id)sender {
}

- (IBAction)onImportKeyClicked:(id)sender {
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
