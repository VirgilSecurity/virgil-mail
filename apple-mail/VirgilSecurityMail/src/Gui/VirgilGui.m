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
#import "VirgilKeyManager.h"
#import "VirgilDecryptAcceptViewController.h"
#import "VirgilKeyChainContainer.h"
#import "VirgilKeyChain.h"

static VirgilPrivateKey * _userActivityKey = nil;

@implementation VirgilGui

NSString * _currentAccount = @"";
NSString * _confirmationCode = @"";
BOOL _waitConfirmation = NO;

+ (void) setConfirmationCode : (NSString *) confirmationCode {
    _waitConfirmation = YES;
    if (nil == confirmationCode) {
        _confirmationCode = @"";
    } else {
        _confirmationCode = confirmationCode;
    }
}

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

+ (VirgilPrivateKey *) getPrivateKey : (NSString *) account {
    _currentAccount = account;
    _userActivityKey = nil;
    
    // Check for need confirmation
    if (YES == _waitConfirmation) {
        _waitConfirmation = NO;
        return [VirgilGui getPrivateKeyAfterActivation : _confirmationCode
                                            forAccount : account];
    }
    
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

+ (VirgilPrivateKey*) getPrivateKeyAfterActivation : (NSString *) confirmationCode
                                        forAccount : (NSString *) account {
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
                (VirgilEmailConfirmViewController*)[storyBoard instantiateControllerWithIdentifier : @"viewEmailConfirm"];
            
            [windowControler setContentViewController:controller];
            
            if (nil == controller) return;
            [controller setConfirmationCode : confirmationCode forAccount : account];
            
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

+ (NSString *) currentAccount {
    return _currentAccount;
}

+ (void) setUserActivityPrivateKey : (VirgilPrivateKey *) privateKey {
    _userActivityKey = privateKey;
}

@end
