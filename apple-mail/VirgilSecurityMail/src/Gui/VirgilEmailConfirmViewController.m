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
#import "VirgilKeyChain.h"

#define TAG_BTN_CANCEL 8000
#define TAG_BTN_OK 8001
#define TAG_BTN_RESEND 8002

#define TAG_TEXT_INFO 8003

static NSString * curAccount = nil;
NSString * windowTitle = @"";

@interface VirgilEmailConfirmViewController ()
@property (weak) IBOutlet NSTextField *titleField;
@end

@implementation VirgilEmailConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCurrentState:confirmInAction];
    _titleField.stringValue = windowTitle;
}

- (void) setTitle : (NSString *)title {
    windowTitle = title;
}

- (void) setConfirmationCode : (NSString *) confirmationCode
                  forAccount : (NSString *) account
                resultObject : (id)resultObject
                 resultBlock : (void (^)(id arg1, BOOL isOk))resultBlock {
    [self setCurrentState:confirmInAction];
    curAccount = account;
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Confirm account creation
            if ([[VirgilProcessingManager sharedInstance] accountNeedsConfirmation:account]) {
                BOOL res = [[VirgilKeyManager sharedInstance] confirmAccountCreation : account
                                                                                 code : confirmationCode];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (res) {
                        [self setCurrentState:confirmDone];
                    } else {
                        [self setCurrentState:confirmError];
                    }
                    resultBlock(resultObject, res);
                });
                
                
            // Confirm private key request
            } else if ([[VirgilProcessingManager sharedInstance] accountNeedsPrivateKey:account]) {
                
                // Request private key password
                BOOL res = [[VirgilKeyManager sharedInstance] confirmPrivateKeyRequest : account
                                                                                  code : confirmationCode];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (res) {
                        [self setCurrentState:confirmDone];
                    } else {
                        [self setCurrentState:confirmError];
                    }
                    resultBlock(resultObject, res);
                });
                
            // Confirm account deletion
            } else if ([[VirgilProcessingManager sharedInstance] accountNeedsDeletion:account]) {
                BOOL res = [[VirgilKeyManager sharedInstance] confirmAccountDeletion : account
                                                                                code : confirmationCode];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (res) {
                        [VirgilKeyChain removeContainer : account];
                        [self setCurrentState:confirmDone];
                    } else {
                        [self setCurrentState:confirmError];
                    }
                    resultBlock(resultObject, res);
                });
                
                
            // There is no need action for confirmation
            } else {
                resultBlock(resultObject, YES);
                [self performSelectorOnMainThread : @selector(closeWindow)
                                       withObject : nil
                                    waitUntilDone : NO];
            }
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
            if ([[VirgilProcessingManager sharedInstance] accountNeedsConfirmation:curAccount]) {
                [[VirgilKeyManager sharedInstance] resendConfirmEMail : curAccount];
            }
            
            if ([[VirgilProcessingManager sharedInstance] accountNeedsPrivateKey:curAccount]) {
                [[VirgilKeyManager sharedInstance] requestPrivateKeyFromCloud :curAccount];
            }
            
            if ([[VirgilProcessingManager sharedInstance] accountNeedsDeletion:curAccount]) {
                [[VirgilKeyManager sharedInstance] requestAccountDeletion:curAccount];
            }
            
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
            infoField.stringValue = @"Confirmation was finished successfuly.";
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
            infoField.stringValue = @"Confirmation error!";
        }
        [self setButtonVisible:NO forTag:TAG_BTN_OK];
        [self setButtonVisible:YES forTag:TAG_BTN_CANCEL];
        [self setButtonVisible:YES forTag:TAG_BTN_RESEND];
    }
}

@end
