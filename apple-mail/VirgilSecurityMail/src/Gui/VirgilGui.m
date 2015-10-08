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
#import "VirgilSignInViewController.h"
#import "VirgilEmailConfirmViewController.h"
#import "VirgilErrorViewController.h"
#import "VirgilUserMessageViewController.h"
#import "VirgilAccountsViewController.h"
#import "VirgilKeyManager.h"
#import "VirgilDecryptAcceptViewController.h"
#import "VirgilKeyChainContainer.h"
#import "VirgilKeyChain.h"

static VirgilPrivateKey * _userActivityKey = nil;

@implementation VirgilGui

NSString * _currentAccount = @"";

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
    
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSStoryboard * storyBoard =
            [NSStoryboard storyboardWithName : @"Main"
                                      bundle : bundle];
            if (nil == storyBoard) return;
            
            NSWindowController * windowControler = [storyBoard instantiateInitialController];
            if (nil == windowControler) return;
            
            VirgilAccountsViewController * controller = (VirgilAccountsViewController *)[storyBoard instantiateControllerWithIdentifier : @"viewAccounts"];
            
            [windowControler setContentViewController:controller];
            
            if (nil == controller) return;
            
            NSWindow * controllerWindow = [windowControler window];
            if (nil == controllerWindow) return;
            
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
        
        [containerWindow beginSheet : controllerWindow
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
        
        [containerWindow beginSheet : controllerWindow
                  completionHandler : ^(NSModalResponse returnCode) {
                  }];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

+ (VirgilPrivateKey *) getPrivateKey : (NSString *) account {
    _currentAccount = account;
    _userActivityKey = nil;
    
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
            
            VirgilEmailConfirmViewController * controller =
            (VirgilEmailConfirmViewController*)[storyBoard instantiateControllerWithIdentifier : @"viewSignIn"];
            
            [windowControler setContentViewController:controller];
            
            if (nil == controller) return;
            
            NSWindow * controllerWindow = [windowControler window];
            
            if (nil == controllerWindow) return;
            
            [containerWindow beginSheet : controllerWindow
                      completionHandler : ^(NSModalResponse returnCode) {
                          dispatch_semaphore_signal(semaphore);
                      }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return _userActivityKey;
}

+ (BOOL) askForCanDecrypt {
    NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
    if (nil == containerWindow) return NO;
    
    NSBundle * bundle = [VirgilGui getVirgilBundle];
    if (nil == bundle) return NO;
    
    @try {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSStoryboard * storyBoard =
            [NSStoryboard storyboardWithName : @"Main"
                                      bundle : bundle];
            if (nil == storyBoard) return;
            
            NSWindowController * windowControler = [storyBoard instantiateInitialController];
            if (nil == windowControler) return;
            
            VirgilDecryptAcceptViewController * controller =
            (VirgilDecryptAcceptViewController*)[storyBoard instantiateControllerWithIdentifier : @"viewDecryptAccept"];
            
            [windowControler setContentViewController:controller];
            
            if (nil == controller) return;
            
            NSWindow * controllerWindow = [windowControler window];
            
            if (nil == controllerWindow) return;
            
            [containerWindow beginSheet : controllerWindow
                      completionHandler : ^(NSModalResponse returnCode) {
                          dispatch_semaphore_signal(semaphore);
                      }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return userAccept == [VirgilDecryptAcceptViewController getLastResult];
}

+ (void) confirmAccount : account
       confirmationCode : code
           resultObject : (id)resultObject
            resultBlock : (void (^)(id arg1, BOOL isOk))resultBlock {
    NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
    if (nil == containerWindow) {
        resultBlock(resultObject, NO);
        return;
    }
        
    NSBundle * bundle = [VirgilGui getVirgilBundle];
    if (nil == bundle) {
        resultBlock(resultObject, NO);
        return;
    }
    
    @try {
        NSStoryboard * storyBoard =
        [NSStoryboard storyboardWithName : @"Main"
                                  bundle : bundle];
        if (nil == storyBoard) {
            resultBlock(resultObject, NO);
            return;
        }
        
        NSWindowController * windowControler = [storyBoard instantiateInitialController];
        if (nil == windowControler) return;
        
        VirgilEmailConfirmViewController * controller =
        (VirgilEmailConfirmViewController*)[storyBoard instantiateControllerWithIdentifier : @"viewEmailConfirm"];
        
        if (nil == controller) {
            resultBlock(resultObject, NO);
            return;
        }
        
        [controller setConfirmationCode : code
                             forAccount : account
                           resultObject : resultObject
                            resultBlock : resultBlock];
        
        [windowControler setContentViewController:controller];
        
        NSWindow * controllerWindow = [windowControler window];
        
        if (nil == controllerWindow) {
            resultBlock(resultObject, NO);
            return;
        }
        
        [containerWindow beginSheet : controllerWindow
                  completionHandler : ^(NSModalResponse returnCode) {
                  }];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

+ (NSString *) currentAccount {
    return _currentAccount;
}

+ (void) setUserActivityPrivateKey : (VirgilPrivateKey *) privateKey {
    _userActivityKey = privateKey;
}

@end
