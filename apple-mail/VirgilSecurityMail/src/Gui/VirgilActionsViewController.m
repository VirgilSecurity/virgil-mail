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
#import "VirgilProcessingManager.h"
#import "VirgilValidator.h"
#import "VirgilGui.h"
#import "NSViewController+VirgilView.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "VirgilLog.h"

#define VIRGILKEY_EXTENTION @"vcard"

#define kCheckInterval      2
#define kCheckTimesLimit    15

static NSLock * accessLock;
static VirgilActionsViewController * currentController = nil;

@implementation VirgilActionsViewController

BOOL _cloudSelection = YES;
NSTimer * _periodicMailChecker = nil;
NSInteger _checkCounter = 0;

+ (void) startMailCheck {
    [VirgilActionsViewController stopMailCheck];
    _periodicMailChecker = [NSTimer scheduledTimerWithTimeInterval : kCheckInterval
                                                            target : NSClassFromString(@"VirgilActionsViewController")
                                                          selector : @selector(mailCheckAction)
                                                          userInfo : nil
                                                           repeats : YES];
}

+ (void) stopMailCheck {
    if (_periodicMailChecker != nil) {
        [_periodicMailChecker invalidate];
    }
    _checkCounter = 0;
}

+ (void) mailCheckAction {
    _checkCounter++;
    if (_checkCounter < (kCheckTimesLimit / kCheckInterval)) {
        [[VirgilProcessingManager sharedInstance] checkNewMail];
    } else {
        [VirgilActionsViewController stopMailCheck];
        [VirgilActionsViewController actionDone];
    }
}

- (void) reset {
    [self setVisibleExportControls:NO];
    [self externalActionDone];
}

- (IBAction)onExportKeyClicked:(id)sender {
    [self setVisibleExportControls:YES];
}

- (IBAction)onCancelExportClicked:(id)sender {
    [self setVisibleExportControls:NO];
}

- (void) setVisibleExportControls : (BOOL) visible {
    if (nil == _btnCancel) return;
    
    _btnCancel.hidden = !visible;
    _btnCancel.enabled = visible;
    
    _btnContinue.hidden = !visible;
    _btnContinue.enabled = visible;
    
    _prograssExplain.hidden = !visible;
    
    _keyPassword.hidden = !visible;
    _keyPassword.enabled = visible;
    
    _keyPasswordConfirm.hidden = !visible;
    _keyPasswordConfirm.enabled = visible;
    
    _btnRemoveFromCloud.enabled = !visible;
    _btnRemoveFromKeyChain.enabled = !visible;
    _btnExport.enabled = !visible;
}

- (void) noteOfWarningToUser : (NSString *) warningMessage
           completionHandler : (void(^)(BOOL isOkButtonClicked))completionHandler {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:warningMessage];
    [alert setInformativeText:@"Be carefull with current operation."];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow : self.view.window
                  completionHandler : ^(NSModalResponse returnCode) {
                      if (NSAlertFirstButtonReturn == returnCode) {
                          if (completionHandler != nil) {
                              completionHandler(NSAlertFirstButtonReturn == returnCode);
                          }
                      }
                  }];
}

- (IBAction)onAccountRemove:(id)sender {
    if (nil == _account) return;
    
    [self noteOfWarningToUser : @"Delete Virgil Keys completely ?"
            completionHandler : ^(BOOL isOkButtonClicked) {
                [self externalActionStart];
                
                @try {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        __block BOOL res = [[VirgilKeyManager sharedInstance] requestAccountDeletion:_account];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (res) {
                                [VirgilActionsViewController startMailCheck];
                            } else {
                                [self externalActionDone];
                                [self showErrorView : [[VirgilKeyManager sharedInstance] lastError]];
                            }
                        });
                    });
                    
                }
                @catch (NSException *exception) {
                    [self externalActionDone];
                }
            }];
}

- (IBAction)onRemoveKeyFromKeyChain:(id)sender {
    if (nil == _account) return;
    
    [self noteOfWarningToUser :  @"Delete Virgil Key from KeyChain ?"
            completionHandler : ^(BOOL isOkButtonClicked) {
                [VirgilKeyChain removeContainer : _account];
                [[VirgilProcessingManager sharedInstance] clearDecryptionCache];
                [self delegateRefresh];
            }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_matrixField) {
        [[_matrixField cellAtRow:0 column:0] setState:(_cloudSelection ? NSOnState : NSOffState)];
        [[_matrixField cellAtRow:1 column:0] setState:(_cloudSelection ? NSOffState : NSOnState)];
        if (_keyPassword && !_keyPasswordConfirm) {
            _keyPassword.hidden = YES;
            _keyPassword.enabled = NO;
        }
    }
    
    [self setVisibleExportControls:NO];
    
    [VirgilActionsViewController safeAction:^{
        currentController = self;
    }];
}

- (void) dealloc {
    [VirgilActionsViewController safeAction:^{
        currentController = nil;
    }];
}

- (IBAction)onFocusToConfirmField:(id)sender {
    [self.view.window makeFirstResponder:_keyPasswordConfirm];
}

- (IBAction)onCreateKeysClicked:(id)sender {
    if (nil == _account) return;
    BOOL useCloudStorage = [_saveToCloudCheckBox state] == NSOnState;
    BOOL useKeyPassword = (_keyPassword.stringValue && _keyPassword.stringValue.length) ||
                            (_keyPasswordConfirm.stringValue && _keyPasswordConfirm.stringValue.length);
    
    _cloudSelection = useCloudStorage;
    
    NSString * keyPass = nil;
    NSString * keyPassConfirm = nil;
    
    if (useKeyPassword) {
        keyPass = _keyPassword.stringValue;
        keyPassConfirm = _keyPasswordConfirm.stringValue;
        
        if (NO == [VirgilValidator simplePassword : keyPass]) {
            [self showCompactErrorView : @"Passwords shoud match in both fields."
                                atView : _keyPassword];
            return;
        }
        
        if (NO == [keyPassConfirm isEqualToString : keyPass]) {
            [self showCompactErrorView : @"Passwords shoud match in both fields."
                                atView : _keyPasswordConfirm];
            return;
        }
    }
    
    
    [self externalActionStart];
    
    @try {
        VirgilContainerType containerType = useCloudStorage ? VirgilContainerNormal : VirgilContainerParanoic;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL res = [[VirgilKeyManager sharedInstance] createAccount : _account
                                           keyPassword : keyPass
                                         containerType : containerType];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (res) {
                    [VirgilActionsViewController startMailCheck];
                } else {
                    [self externalActionDone];
                    [self showErrorView : [[VirgilKeyManager sharedInstance] lastError]];
                }
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (IBAction)onExportContinueClicked:(id)sender {
    if (nil == _account) return;
    
    NSString * keyPass = nil;
    NSString * keyPassConfirm = nil;
    
    //keyPass = _keyPassword.stringValue;
    //keyPassConfirm = _keyPasswordConfirm.stringValue;
    
    if (keyPass.length || keyPassConfirm.length) {
        if (NO == [VirgilValidator simplePassword : keyPass]) {
            [self showCompactErrorView : @"Password can't be empty, can't contain not latin letters."
                                atView : _keyPassword];
            return;
        }
        
        if (NO == [keyPassConfirm isEqualToString : keyPass]) {
            [self showCompactErrorView : @"Passwords shoud match in both fields."
                                atView : _keyPasswordConfirm];
            return;
        }
    }
    
    [self externalActionStart];
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * fileName = [self exportFileName];
            if (!fileName) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self externalActionDone];
                    [self setVisibleExportControls:NO];
                });
                return;
            }
            
            BOOL res = [[VirgilKeyManager sharedInstance] exportAccountData : _account
                                                                     toFile : fileName
                                                               withPassword : keyPass];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self externalActionDone];
                if (res) {
                    [self setVisibleExportControls:NO];
                } else {
                    [self showErrorView : [[VirgilKeyManager sharedInstance] lastError]];
                }
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (NSString *) exportFileName {
    __block NSString * fileName = nil;
    @try {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSSavePanel * saveDlg = [NSSavePanel savePanel];
            [saveDlg setAllowedFileTypes:[NSArray arrayWithObjects:VIRGILKEY_EXTENTION, nil]];
            
            [saveDlg beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
                if (NSFileHandlingPanelOKButton == result) {
                    fileName = [[saveDlg URL] path];
                }
                dispatch_semaphore_signal(semaphore);
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {}
    @finally {}
    
    return fileName;
}

- (IBAction)onSourceChanged:(id)sender {
    NSButtonCell *selCell = [sender selectedCell];
    BOOL isCloudStorage = 1000 == [selCell tag];
    _keyPassword.hidden = isCloudStorage;
    _keyPassword.enabled = !isCloudStorage;
}

- (IBAction)onCreationDestChanged:(id)sender {
}

- (NSDictionary*) loadKeyFromFileWithPassword:(NSString *)password {
    NSString * errorStr = @"";
    VirgilPrivateKey * encryptedKey = nil;
    BOOL loadDone = NO;
    BOOL loadStoppedByUser = NO;
    BOOL loadStoppedByError = NO;
    // Load key from file
    NSDictionary * resDict = [self importKeyWithPassword:password];
    
    loadStoppedByUser = [[resDict objectForKey:@"stoppedByUser"] boolValue];
    
    if (!loadStoppedByUser) {
        VirgilKeyChainContainer * container = nil;
        if ([[resDict objectForKey:@"resBool"] boolValue]) {
            container = [resDict objectForKey:@"resContainer"];
        }
        
        if (container) {
            encryptedKey = container.privateKey;
        } else {
            errorStr = [resDict objectForKey:@"errorStr"];
            loadStoppedByError = YES;
        }
        
        if (NO == loadStoppedByUser && NO == loadStoppedByError) {
            if (nil == encryptedKey) {
                errorStr = @"Can't find need key or wrong password";
            } else {
                NSString * normalizedKeyString = [container.privateKey.key stripBase64];
                loadDone =
                [[VirgilKeyManager sharedInstance] prepareAndSaveLoadedPrivateKey : normalizedKeyString
                                                                           containerType : VirgilContainerParanoic
                                                                                 account : container.privateKey.account];
            }
        }
    }
    
    return @{@"loadDoneBool" : [NSNumber numberWithBool:loadDone],
             @"errorString" : errorStr};
}

- (IBAction)onLoadKeyClicked:(id)sender {
    
    // Get params from GUI
    BOOL useCloudStorage = NSOnState == [[_matrixField cellAtRow:0 column:0] state];
    
    NSString * password = /*_keyPassword.stringValue.length ? _keyPassword.stringValue :*/ nil;
    BOOL passwordValid = (password == nil) ? YES : [VirgilValidator simplePassword : password];
    
    if (!useCloudStorage && !passwordValid) {
        [self showCompactErrorView : @"Password can't contain not latin letters."
                            atView : _keyPassword];
        return;
    }
    
    [self externalActionStart];
    
    // Do long term manipulation asynchronously
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * errorStr = nil;
            BOOL successfull = NO;
            
            if (useCloudStorage) { // Load private key from cloud
                successfull = [[VirgilKeyManager sharedInstance] requestPrivateKeyFromCloud:_account];
                errorStr = successfull ? nil : @"Can't request private key.";
            
            } else { // Load private key from file
                NSDictionary * resDict = [self loadKeyFromFileWithPassword:password];
                successfull = [[resDict objectForKey:@"loadDoneBool"] boolValue];
                errorStr = [resDict objectForKey:@"errorString"];
            }
            
            // Update GUI
            dispatch_async(dispatch_get_main_queue(), ^{
                if (useCloudStorage) {
                    if (successfull) {
                        [VirgilActionsViewController startMailCheck];
                    } else {
                        [self externalActionDone];
                        [self showErrorView : [[VirgilKeyManager sharedInstance] lastError]];
                    }
                } else {
                    [self externalActionDone];
                    if (NO == successfull) {
                        if (nil != errorStr && [errorStr length]) {
                            [self showErrorView : errorStr];
                        }
                    } else {
                        [self delegateRefresh];
                    }
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
        VirgilKeyChainContainer * container = [[VirgilKeyManager sharedInstance] importAccountData : _account
                                                                                          fromFile : fileName
                                                                                      withPassword : password];
        if (container) {
            boolRes = YES;
            [res setObject:container forKey:@"resContainer"];
        }
    }
    
    [res setObject:[NSNumber numberWithBool:boolRes] forKey:@"resBool"];
    [res setObject:[NSNumber numberWithBool:stoppedByUser] forKey:@"stoppedByUser"];
    if ([[VirgilKeyManager sharedInstance] lastError]) {
        [res setObject:[[VirgilKeyManager sharedInstance] lastError] forKey:@"errorStr"];
    }
    
    return [res copy];
}

- (IBAction)onResendConfirmationClicked:(id)sender {
    [self externalActionStart];
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL res = [[VirgilKeyManager sharedInstance] resendConfirmEMail : _account];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (res) {
                    [VirgilActionsViewController startMailCheck];
                } else {
                    [self externalActionDone];
                    [self showErrorView : [[VirgilKeyManager sharedInstance] lastError]];
                }
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (IBAction)onResendConfirmationForPrivateKey:(id)sender {
    [self externalActionStart];
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL res = [[VirgilKeyManager sharedInstance] requestPrivateKeyFromCloud:_account];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (res) {
                    [VirgilActionsViewController startMailCheck];
                } else {
                    [self externalActionDone];
                    [self showErrorView : [[VirgilKeyManager sharedInstance] lastError]];
                }
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (IBAction)onResendDeleteRequest:(id)sender {
    [self externalActionStart];
    
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL res = [[VirgilKeyManager sharedInstance] requestAccountDeletion:_account];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (res) {
                    [VirgilActionsViewController startMailCheck];
                } else {
                    [self externalActionDone];
                    [self showErrorView : [[VirgilKeyManager sharedInstance] lastError]];
                }
            });
        });
        
    }
    @catch (NSException *exception) {
        [self externalActionDone];
    }
    @finally {}
}

- (IBAction)onStopDeletion:(id)sender {
    [[VirgilKeyManager sharedInstance] terminateAccountDeletion:_account];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self delegateRefresh];
    });
}

- (IBAction)onStopPrivateKeyRequest:(id)sender {
    [[VirgilKeyManager sharedInstance] terminatePrivateKeyRequest:_account];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self delegateRefresh];
    });
}

- (void) delegateRefresh {
    if (_delegate) {
        [_delegate askRefresh];
    }
}

- (IBAction)onShowHelp_InProgress:(id)sender {
    NSString * helpString = @"";
    [self showCompactErrorView : helpString
                        atView : sender];
}

- (IBAction)onShowHelp_CreateAccount:(id)sender {
    NSString * helpString;
    
    BOOL useCloudStorage = NSOnState == [[_matrixField cellAtRow:0 column:0] state];
    
    if (useCloudStorage) {
        helpString = @"Your private key will be safely stored in your Virgil account and can easily be restored.\n\n1. Create a password for your Virgil account.\n\n2. Create a password for your private key encryption. It will be used to decrypt secure messages sent to you by Virgil users.";
    } else {
        helpString = @"Save your private key in a secure local storage. It can’t be restored in case you lose or forget it.\n\nCreate a password for your private key encryption. It will be used to decrypt secure messages sent to you by Virgil users.";
    }
    
    [self showCompactErrorView : helpString
                        atView : sender];
}

- (IBAction)onShowHelp_LoadKey:(id)sender {
    NSString * helpString = @"There is a Virgil account for this email but the private key is missing. Please select a storage type of your private key in order to finish your account configuration.";
    [self showCompactErrorView : helpString
                        atView : sender];
}

- (IBAction)onShowHelp_WaitConfirmation:(id)sender {
    NSString * helpString = @"An email with a confirmation code has been sent. Please confirm the code from the email or resend confirmation if there is no email from VirgilSecurity.";
    [self showCompactErrorView : helpString
                        atView : sender];
}

- (IBAction)onShowHelp_KeysPresent:(id)sender {
    NSString * helpString = @"A public and private key-pair has been generated for this account. Now you can:\n\n1. Send and receive encrypted emails from Virgil users.\n\n2. Export your private key to a file and save it locally on your machine.\n\n3. Remove your private key from Keychain if you need to clear your machine from personal data.\n\n";
    [self showCompactErrorView : helpString
                        atView : sender];
}

+ (void) safeAction : (void(^)())action {
    [accessLock lock];
    action();
    [accessLock unlock];
}

+ (void) actionDone {
    [VirgilActionsViewController stopMailCheck];
    [VirgilActionsViewController safeAction:^{
        if (currentController != nil) {
            [currentController performSelectorOnMainThread : @selector(externalActionDone)
                                                withObject : currentController
                                             waitUntilDone : YES];
            
            [currentController performSelectorOnMainThread : @selector(delegateRefresh)
                                                withObject : currentController
                                             waitUntilDone : NO];
        }
    }];
}

@end
