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
#import "VirgilLog.h"

#define TAG_BTN_CANCEL 8000
#define TAG_BTN_OK 8001
#define TAG_BTN_RESEND 8002

#define TAG_TEXT_INFO 8003

static NSString * curAccount = nil;

@interface VirgilEmailConfirmViewController ()

@end

@implementation VirgilEmailConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCurrentState:confirmInAction];
}

- (void) setConfirmationCode : (NSString *) confirmationCode
                  forAccount : (NSString *) account
                resultObject : (id)resultObject
                 resultBlock : (void (^)(id arg1, BOOL isOk))resultBlock {
    [self setCurrentState:confirmInAction];
    curAccount = account;
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL res =  [VirgilKeyManager confirmAccountCreation : account
                                                            code : confirmationCode];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (res) {
                    [self setCurrentState:confirmDone];
                } else {
                    [self setCurrentState:confirmError];
                }
                resultBlock(resultObject, res);
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (IBAction)onCancel:(id)sender {
    [self closeWindow];
}

- (IBAction)onOk:(id)sender {
    [self closeWindow];
}

- (IBAction)onResendConfirmation:(id)sender {
    [self setCurrentState:confirmResend];
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [VirgilKeyManager resendConfirmEMail : curAccount];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self closeWindow];
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (void) setButtonVisible : (BOOL)visible
                   forTag : (NSInteger)tag {
    NSButton * btn = [self.view viewWithTag : tag];
    if (btn) {
        btn.hidden = !visible;
    }
}

- (void) setCurrentState : (ConfirmationState)state {
    _state = state;
    NSTextField * infoField = [self.view viewWithTag : 8003];
    
    if (confirmInAction == _state) {
        [self setProgressVisible:YES];
        [self preventUserActivity:YES];
        if (nil != infoField) {
            infoField.stringValue = @"In progress ...";
        }
        [self setButtonVisible:NO forTag:TAG_BTN_OK];
        [self setButtonVisible:NO forTag:TAG_BTN_CANCEL];
        [self setButtonVisible:NO forTag:TAG_BTN_RESEND];
        
    } else if (confirmDone == _state) {
        [self setProgressVisible:NO];
        [self preventUserActivity:NO];
        if (nil != infoField) {
            infoField.stringValue = @"Account confirmation was finished successfuly.";
        }
        [self setButtonVisible:YES forTag:TAG_BTN_OK];
        [self setButtonVisible:NO forTag:TAG_BTN_CANCEL];
        [self setButtonVisible:NO forTag:TAG_BTN_RESEND];
        
    } else if (confirmResend == _state) {
        [self setProgressVisible:YES];
        [self preventUserActivity:YES];
        if (nil != infoField) {
            infoField.stringValue = @"Sending request for resend confirmation code ...";
        }
    } else if (confirmResendDone == _state) {
        [self setProgressVisible:NO];
        [self preventUserActivity:NO];
        if (nil != infoField) {
            infoField.stringValue = @"Request was sent.";
        }
        [self setButtonVisible:YES forTag:TAG_BTN_OK];
        [self setButtonVisible:NO forTag:TAG_BTN_CANCEL];
        [self setButtonVisible:NO forTag:TAG_BTN_RESEND];
    } else /*error*/ {
        [self setProgressVisible:NO];
        [self preventUserActivity:NO];
        if (nil != infoField) {
            infoField.stringValue = @"Account confirmation error!";
        }
        [self setButtonVisible:NO forTag:TAG_BTN_OK];
        [self setButtonVisible:YES forTag:TAG_BTN_CANCEL];
        [self setButtonVisible:YES forTag:TAG_BTN_RESEND];
    }
}

@end
