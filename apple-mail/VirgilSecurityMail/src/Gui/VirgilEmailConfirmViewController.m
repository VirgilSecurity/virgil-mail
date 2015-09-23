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

#import "VirgilEmailConfirmViewController.h"
#import "VirgilKeyManager.h"
#import "NSViewController+VirgilView.h"
#import "VirgilValidator.h"
#import "VirgilGui.h"
#import "VirgilProcessingManager.h"

@interface VirgilEmailConfirmViewController ()

@end

@implementation VirgilEmailConfirmViewController

- (IBAction)onAcceptClicked : (id)sender {
    NSTextField * codeField = [self.view viewWithTag : 1000];
    if (!codeField) return;
    NSString * code = [codeField stringValue];
    if (![VirgilValidator emailCode : code]) {
        [self showCompactErrorView : @"Confirmation code should contains 6 letters and digits."
                            atView : codeField];
        return;
    }
    NSString * account = [self selectedAccount];
    if (YES == [VirgilKeyManager confirmAccountCreation : account
                                                   code : code]) {
        [VirgilGui setUserActivityPrivateKey : [VirgilKeyManager getPrivateKey : account
                                                             containerPassword : @""]];
        [self closeWindow];
    } else {
        NSLog(@"%@", [VirgilKeyManager lastError]);
        [self showErrorView : @"Wrong confirmation code."];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSPopUpButton * popUpButton = [self.view viewWithTag : 5000];
    if (!popUpButton) return;
    
    [popUpButton removeAllItems];
    [popUpButton addItemsWithTitles : [VirgilProcessingManager accountsList]];
}

- (NSString *) selectedAccount {
    NSPopUpButton * popUpButton = [self.view viewWithTag : 5000];
    if (!popUpButton) return nil;
    
    return [popUpButton titleOfSelectedItem];
}

- (void) setConfirmationCode : (NSString *) confirmationCode
                  forAccount : (NSString *) account {
#if 0
    _account = account;
    NSTextField * codeField = [self.view viewWithTag : 1000];
    if (!codeField) return;
    if (nil == confirmationCode) {
        [codeField setStringValue : @""];
    } else {
        [codeField setStringValue : confirmationCode];
    }
#endif
}

- (IBAction)onCancel:(id)sender {
    [self closeWindow];
}

@end
