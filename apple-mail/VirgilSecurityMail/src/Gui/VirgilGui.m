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

#import "VirgilGui.h"
#import "VirgilEmailConfirmViewController.h"
#import "VirgilEmailSendConfigureViewContainer.h"
#import "VirgilErrorViewController.h"
#import "VirgilUserMessageViewController.h"
#import "VirgilAccountsViewController.h"
#import "VirgilGetPassword.h"
#import "VirgilKeyManager.h"
#import "VirgilKeyChainContainer.h"
#import "VirgilKeyChain.h"
#import "VirgilLog.h"
#import "VirgilProcessingManager.h"
#import "VirgilActionsViewController.h"

static BOOL _accountsVisible = NO;
static BOOL _configureForSendVisible = NO;

@implementation VirgilGui

+ (NSBundle *) getVirgilBundle {
    NSBundle * bundle = nil;
    for (NSBundle * b in [NSBundle allBundles]) {
        if ([b isLoaded] &&
            [[b bundlePath] containsString : @"VirgilSecurityMail"]) {
            bundle = b;
            break;
        }
    }
    return bundle;
}

+ (void) showWellcome {
    NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
    if (nil == containerWindow) return;
    
    NSBundle * bundle = [VirgilGui getVirgilBundle];
    if (nil == bundle) return;
    
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSStoryboard * storyBoard =
            [NSStoryboard storyboardWithName : @"Main"
                                      bundle : bundle];
            if (nil == storyBoard) return;
            
            NSWindowController * windowControler = [storyBoard instantiateInitialController];
            if (nil == windowControler) return;
            
            id controller = [storyBoard instantiateControllerWithIdentifier : @"viewWellcome"];
            
            [windowControler setContentViewController:controller];
            
            if (nil == controller) return;
            
            NSWindow * controllerWindow = [windowControler window];
            if (nil == controllerWindow) return;
            
            [controllerWindow setStyleMask:[controllerWindow styleMask] & ~NSResizableWindowMask];
            
            [containerWindow beginSheet : controllerWindow
                      completionHandler : ^(NSModalResponse returnCode) {
                      }];
            
        });
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

+ (void) showAccountsFor : (NSString *) account {
    NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
    if (nil == containerWindow) return;
    
    NSBundle * bundle = [VirgilGui getVirgilBundle];
    if (nil == bundle) return;
    
    if (YES == _accountsVisible) return;
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSStoryboard * storyBoard =
            [NSStoryboard storyboardWithName : @"Main"
                                      bundle : bundle];
            if (nil == storyBoard) return;
            
            NSWindowController * windowControler = [storyBoard instantiateInitialController];
            if (nil == windowControler) return;
            
            VirgilAccountsViewController * controller = (VirgilAccountsViewController *)[storyBoard instantiateControllerWithIdentifier : @"viewAccounts"];
            
            controller.selectedAccount = account;
            
            [windowControler setContentViewController:controller];
            
            if (nil == controller) return;
            
            NSWindow * controllerWindow = [windowControler window];
            if (nil == controllerWindow) return;
            
            [controllerWindow setStyleMask:[controllerWindow styleMask] & ~NSResizableWindowMask];
            
            _accountsVisible = YES;
            [containerWindow beginSheet : controllerWindow
                      completionHandler : ^(NSModalResponse returnCode) {
                          _accountsVisible = NO;
                      }];

        });
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

+ (void) showError : (NSString *) error {
    NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
    if (nil == containerWindow) return;
    
    NSBundle * bundle = [VirgilGui getVirgilBundle];
    if (nil == bundle) return;
    
    @try {
        NSStoryboard * storyBoard =
        [NSStoryboard storyboardWithName : @"Main"
                                  bundle : bundle];
        if (nil == storyBoard) return;
        
        NSWindowController * windowControler = [storyBoard instantiateInitialController];
        if (nil == windowControler) return;
        
        VirgilErrorViewController * controller =
        (VirgilErrorViewController*)[storyBoard instantiateControllerWithIdentifier : @"viewError"];
        
        controller.singleWindow = YES;
        [controller setErrorText:error];
        
        [windowControler setContentViewController:controller];
        
        if (nil == controller) return;
        
        NSWindow * controllerWindow = [windowControler window];
        
        if (nil == controllerWindow) return;
        
        [controllerWindow setStyleMask:[controllerWindow styleMask] & ~NSResizableWindowMask];
        
        [containerWindow beginCriticalSheet : controllerWindow
                          completionHandler : ^(NSModalResponse returnCode) {
                  }];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

+ (void) showMessage : (NSString *) message {
    NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
    if (nil == containerWindow) return;
    
    NSBundle * bundle = [VirgilGui getVirgilBundle];
    if (nil == bundle) return;
    
    @try {
        NSStoryboard * storyBoard =
        [NSStoryboard storyboardWithName : @"Main"
                                  bundle : bundle];
        if (nil == storyBoard) return;
        
        NSWindowController * windowControler = [storyBoard instantiateInitialController];
        if (nil == windowControler) return;
        
        VirgilUserMessageViewController * controller =
        (VirgilUserMessageViewController*)[storyBoard instantiateControllerWithIdentifier : @"viewMessage"];
        
        controller.singleWindow = YES;
        [controller setMessageText:message];
        
        [windowControler setContentViewController:controller];
        
        if (nil == controller) return;
        
        NSWindow * controllerWindow = [windowControler window];
        
        if (nil == controllerWindow) return;
        
        [controllerWindow setStyleMask:[controllerWindow styleMask] & ~NSResizableWindowMask];
        
        [containerWindow beginSheet : controllerWindow
                  completionHandler : ^(NSModalResponse returnCode) {
                  }];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

+ (void) confirmAction : (NSString *)account
      confirmationCode : (NSString *)code
                action : (NSString *)action
      confirmationGUID : (NSString *)confirmationGUID
 checkConfirmationGUID : (BOOL) checkConfirmationGUID
          resultObject : (id)resultObject
           resultBlock : (void (^)(id arg1, BOOL isOk))resultBlock {
    
    NSException * e = [NSException exceptionWithName : @"CantUseUI"
                                              reason : @"Can't Use UI"
                                            userInfo : nil];
    @try {
        NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
        if (nil == containerWindow) @throw e;
            
        NSBundle * bundle = [VirgilGui getVirgilBundle];
        if (nil == bundle) @throw e;
    
        NSStoryboard * storyBoard = [NSStoryboard storyboardWithName : @"Main"
                                                              bundle : bundle];
        if (nil == storyBoard) @throw e;
        
        NSWindowController * windowControler = [storyBoard instantiateInitialController];
        if (nil == windowControler) @throw e;
        
        BOOL needAccountCreateConfirmation = [[VirgilProcessingManager sharedInstance] accountNeedsConfirmation:account];
        BOOL needPrivKeyRequestConfirmation = [[VirgilProcessingManager sharedInstance] accountNeedsPrivateKey:account];
        BOOL needDeletionConfirmation = [[VirgilProcessingManager sharedInstance] accountNeedsDeletion:account];
        if (!needAccountCreateConfirmation &&
            !needPrivKeyRequestConfirmation &&
            !needDeletionConfirmation) {
            resultBlock(resultObject, NO);
            return;
        }
        
        VirgilEmailConfirmViewController * controller =
        (VirgilEmailConfirmViewController*)[storyBoard instantiateControllerWithIdentifier : @"viewEmailConfirm"];
        if (nil == controller) @throw e;
        
        NSString * title;
        
        if (needAccountCreateConfirmation) {
            title = @"Virgil Security Sign Up processing";
        } else if (needDeletionConfirmation) {
            title = @"Virgil Security Delete processing";
        } else {
            title = @"Virgil Private Key request processing";
        }
        
        [controller setTitle : title];
        
        [windowControler setContentViewController:controller];
        NSWindow * controllerWindow = [windowControler window];
        
        if (nil == controllerWindow) @throw e;
        
        
        if (![controller setConfirmationCode : code
                                  forAccount : account
                            confirmationGUID : confirmationGUID
                       checkConfirmationGUID : checkConfirmationGUID
                                resultObject : resultObject
                                 resultBlock : ^(id arg1, BOOL isOk) {
                                     [VirgilActionsViewController actionDone];
                                     resultBlock(arg1, isOk);
                                 }]) {
                                     resultBlock(resultObject, NO);
                                 }
        
        
        
        [controllerWindow setStyleMask:[controllerWindow styleMask] & ~NSResizableWindowMask];
        
        [containerWindow beginCriticalSheet : controllerWindow
                          completionHandler : ^(NSModalResponse returnCode) {
                          }];
    }
    @catch (NSException *exception) {
        if ([exception.name isEqualToString:e.name]) {
            if (![VirgilEmailConfirmViewController setConfirmationCodeNoUI : code
                                                                forAccount : account
                                                          confirmationGUID : confirmationGUID
                                                              resultObject : resultObject
                                                               resultBlock : ^(id arg1, BOOL isOk) {
                                                                   [VirgilActionsViewController actionDone];
                                                                   resultBlock(arg1, isOk);
                                                               }]) {
                                                                   resultBlock(resultObject, NO);
                                                               }
        } else {
            resultBlock(resultObject, NO);
        }
    }
    @finally {
    }
}

+ (NSString *) getUserPasswordForKeyPair : (NSString *)publicKey
                              privateKey : (NSString *)privateKey {
    NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
    if (nil == containerWindow) return nil;
    
    NSBundle * bundle = [VirgilGui getVirgilBundle];
    if (nil == bundle) return nil;
    
    @try {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSStoryboard * storyBoard =
            [NSStoryboard storyboardWithName : @"Main"
                                      bundle : bundle];
            if (nil == storyBoard) return;
            
            NSWindowController * windowControler = [storyBoard instantiateInitialController];
            if (nil == windowControler) return;
            
            VirgilGetPassword * controller =
            (VirgilGetPassword*)[storyBoard instantiateControllerWithIdentifier : @"viewGetPassword"];
            if (nil == controller) return;
            
            [controller setKeyPair : publicKey
                        privateKey : privateKey];
            
            [windowControler setContentViewController:controller];
            
            NSWindow * controllerWindow = [windowControler window];
            if (nil == controllerWindow) return;
            
            [controllerWindow setStyleMask:[controllerWindow styleMask] & ~NSResizableWindowMask];
            
            [containerWindow beginCriticalSheet : controllerWindow
                              completionHandler : ^(NSModalResponse returnCode) {
                          dispatch_semaphore_signal(semaphore);
                      }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {}
    @finally {}
    
    return [VirgilGetPassword password];
}

+ (void) configureAccountForSend : (NSString *)account {
    NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
    if (nil == containerWindow) return;
    
    NSBundle * bundle = [VirgilGui getVirgilBundle];
    if (nil == bundle) return;
    
    if (YES == _accountsVisible || YES == _configureForSendVisible) return;
    @try {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSStoryboard * storyBoard =
            [NSStoryboard storyboardWithName : @"Main"
                                      bundle : bundle];
            if (nil == storyBoard) return;
            
            NSWindowController * windowControler = [storyBoard instantiateInitialController];
            if (nil == windowControler) return;
            
            VirgilEmailSendConfigureViewContainer * controller =
            (VirgilEmailSendConfigureViewContainer*)[storyBoard instantiateControllerWithIdentifier : @"viewEmailSendConfigure"];
            
            controller.account = account;
            
            [windowControler setContentViewController:controller];
            if (nil == controller) return;
            
            NSWindow * controllerWindow = [windowControler window];
            if (nil == controllerWindow) return;
            
            [controllerWindow setStyleMask:[controllerWindow styleMask] & ~NSResizableWindowMask];
            
            _configureForSendVisible = YES;
            [containerWindow beginCriticalSheet : controllerWindow
                              completionHandler : ^(NSModalResponse returnCode) {
                                  dispatch_semaphore_signal(semaphore);
                                  _configureForSendVisible = NO;
                              }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {}
    @finally {}
}

@end
