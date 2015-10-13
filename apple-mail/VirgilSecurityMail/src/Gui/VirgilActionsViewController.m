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
#import "VirgilKeyManager.h"
#import "VirgilKeyChain.h"
#import "VirgilPrivateKeyManager.h"
#import "VirgilValidator.h"
#import "VirgilGui.h"
#import "NSViewController+VirgilView.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "VirgilLog.h"

#define VIRGILKEY_EXTENTION @"virgilkey"

static BOOL _cloudSelection = YES;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_matrixField) {
        [[_matrixField cellAtRow:0 column:0] setState:(_cloudSelection ? NSOnState : NSOffState)];
        [[_matrixField cellAtRow:1 column:0] setState:(_cloudSelection ? NSOffState : NSOnState)];
    }
}

- (IBAction)onCreateKeysClicked:(id)sender {
    if (nil == _account) return;
    BOOL useCloudStorage = NSOnState == [[_matrixField cellAtRow:0 column:0] state];
    BOOL useKeyPassword = YES;
    
    _cloudSelection = useCloudStorage;
    
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
                    [self delegateRefresh];
                } else {
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

- (IBAction)onCreationDestChanged:(id)sender {
    NSButtonCell *selCell = [sender selectedCell];
    BOOL isCloudStorage = 1000 == [selCell tag];
    _cloudPassword.hidden = !isCloudStorage;
    _cloudPasswordConfirm.hidden = !isCloudStorage;
}

- (IBAction)onLoadKeyClicked:(id)sender {
    
    // Get params from GUI
    BOOL useCloudStorage = NSOnState == [[_matrixField cellAtRow:0 column:0] state];
    
    NSString * password = _cloudPassword.stringValue.length ? _cloudPassword.stringValue : nil;
    BOOL passwordValid = [VirgilValidator simplePassword : password];
    
    if ((useCloudStorage && !passwordValid) || (!useCloudStorage && password && !passwordValid)) {
        [self showCompactErrorView : @"Password can't be empty, can't contains not latin letters."
                            atView : _cloudPassword];
        return;
    }
    
    [self setProgressVisible:YES];
    [self preventUserActivity:YES];
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * errorStr = nil;
            VirgilPrivateKey * encryptedKey = nil;
            BOOL loadStoppedByUser = NO;
            BOOL loadStoppedByError = NO;
            if (useCloudStorage) {
                
                // Load key from cloud
                encryptedKey = [VirgilKeyManager getEncryptedPrivateKeyFromCloud:_account containerPassword:password];
            } else {
                
                // Load key from file
                NSDictionary * resDict = [self importKeyWithPassword:password];
                loadStoppedByUser = [[resDict objectForKey:@"stoppedByUser"] boolValue];
                
                if (!loadStoppedByUser) {
                    VirgilKeyChainContainer * container = nil;
                    if ([[resDict objectForKey:@"resBool"] boolValue]) {
                        [resDict objectForKey:@"resContainer"];
                    }
                    
                    if (container) {
                        errorStr = @"Should load file ...";
                    } else {
                        errorStr = [resDict objectForKey:@"errorStr"];
                        loadStoppedByError = YES;
                    }
                }
            }
            
            VirgilPrivateKey * decryptedKey = nil;
            
            if (NO == loadStoppedByUser && NO == loadStoppedByError) {
                if (nil == encryptedKey) {
                    errorStr = @"Can't find need key or wrong password";
                } else {
                    
                    // Check is need to ask for private key password
                    NSString * normalizedKeyString = [encryptedKey.key stripBase64];
                    if ([VirgilPrivateKeyManager isCorrectEncryptedPrivateKey : normalizedKeyString]) {
                        NSString * userPassword = [VirgilGui getUserPassword];
                    
                        if (nil != userPassword) {
                            decryptedKey = [[VirgilPrivateKey alloc] initAccount : _account
                                                                   containerType : (useCloudStorage ? VirgilContainerNormal : VirgilContainerParanoic)
                                                                      privateKey : normalizedKeyString
                                                                     keyPassword : userPassword
                                                               containerPassword : password];
                            [VirgilKeyManager setPrivateKey : decryptedKey
                                                 forAccount : _account];
                        }
                    } else {
                        // Decrypt private key with account password
                        decryptedKey = [VirgilKeyManager decryptedPrivateKey:encryptedKey keyPassword:password];
                        if (nil == decryptedKey) {
                            errorStr = @"Can't decrypt private key";
                        }
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self externalActionDone];
                if (nil == decryptedKey && nil != errorStr) {
                    [self showErrorView : errorStr];
                }
                if (NO == loadStoppedByUser) {
                    [self delegateRefresh];
                }
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (NSDictionary *) importKeyWithPassword : (NSString *)password {
    NSMutableDictionary * res = [NSMutableDictionary new];
    __block BOOL loadDone = NO;
    __block BOOL stoppedByUser = NO;
    __block NSString * fileName;
    @try {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSOpenPanel* openDlg = [NSOpenPanel openPanel];
            [openDlg setCanChooseFiles:YES];
            [openDlg setAllowsMultipleSelection:NO];
            [openDlg setCanChooseDirectories:NO];
            [openDlg setAllowedFileTypes:[NSArray arrayWithObjects:VIRGILKEY_EXTENTION, nil]];
            NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
            if (nil == containerWindow) return;
            
            [openDlg beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
                                if (NSFileHandlingPanelOKButton == result) {
                                    NSArray* urls = [openDlg URLs];
                                    loadDone = YES;
                                    fileName = [[urls objectAtIndex:0] path];
                                } else {
                                    stoppedByUser = YES;
                                }
                                dispatch_semaphore_signal(semaphore);
                            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {}
    @finally {}
    
    BOOL boolRes = NO;
    
    if (loadDone) {
        VirgilKeyChainContainer * container = [VirgilKeyManager importAccountData : _account
                                                                         fromFile : fileName
                                                                     withPassword : password];
        if (container) {
            loadDone = YES;
            [res setObject:container forKey:@"resContainer"];
        }
    }
    
    [res setObject:[NSNumber numberWithBool:boolRes] forKey:@"resBool"];
    [res setObject:[NSNumber numberWithBool:stoppedByUser] forKey:@"stoppedByUser"];
    if ([VirgilKeyManager lastError]) {
        [res setObject:[VirgilKeyManager lastError] forKey:@"errorStr"];
    }
    
    return [res copy];
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
