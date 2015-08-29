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

#import "VirgilKeysGui.h"
#import "VirgilSignInViewController.h"

@implementation VirgilKeysGui

+ (VirgilPrivateKey*) getPrivateKey : (NSString *) account {
    // Get active mail write window
    
    NSWindow * containerWindow = [[NSApplication sharedApplication] mainWindow];
    if (nil == containerWindow) return nil;
    
    NSBundle * bundle = nil;
    for (NSBundle * b in [NSBundle allBundles]) {
        if ([b isLoaded] &&
            [[b bundlePath] containsString : @"VirgilSecurityMail"]) {
            bundle = b;
            break;
        }
    }

    if (nil == bundle) return nil;
    
    @try {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSStoryboard * storyBoard =
            [NSStoryboard storyboardWithName : @"Main"
                                      bundle : bundle];
            if (nil == storyBoard) return;
            
            NSWindowController * signInViewControler = [storyBoard instantiateInitialController];
            if (nil == signInViewControler) return;
            
            NSWindow * controllerWindow = [signInViewControler window];
            if (nil == controllerWindow) return;

            [containerWindow beginSheet : controllerWindow
                      completionHandler : ^(NSModalResponse returnCode) {
                      }];
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return nil;
}

+ (void) addMailWriteWindow : (NSWindow *) window {
    if (nil == _mailWriteWindows) {
        _mailWriteWindows = [[NSMutableArray alloc] init];
    }
    [_mailWriteWindows addObject : window];
    NSLog(@"                addMailWriteWindow : %@", window.title);
}

+ (void) removeMailWriteWindow : (NSWindow *) window {
    
}

@end
