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

#import "VirgilBannerContainerViewController.h"
#import "VirgilDynamicVariables.h"
#import "VirgilProcessingManager.h"
#import "VirgilGui.h"
#import "VirgilLog.h"

#import <BannerContainerViewController.h>
#import <BannerViewController.h>

#define VIRGIL_BANNER_INDEX 3

#define BANNER_IMAGE @"BANNER_IMAGE"
#define BANNER_TEXT_FIELD @"BANNER_TEXT_FIELD"
#define BUTTON_TITLE @"BUTTON_TITLE"
#define BUTTON_TARGET @"BUTTON_TARGET"
#define BUTTON_ACTION @"BUTTON_ACTION"

@implementation VirgilBannerContainerViewController

- (void)MAUpdateBannerDisplay {
    [self restoreOriginalView];
    
    [self MAUpdateBannerDisplay];
    
    if ([((BannerContainerViewController*)self).representedObject isExistsDynVar:@"IsConfirmationEmail"]) {
        [self showEmailConfirmation];
    }
}

- (void)MASetRepresentedObject:(id)arg1 {
    [self MASetRepresentedObject:arg1];
    
    [self restoreOriginalView];
    if ([((BannerContainerViewController*)self).representedObject isExistsDynVar:@"IsConfirmationEmail"]) {
        [self showEmailConfirmation];
    }
}

- (void) restoreOriginalView {
    static BOOL flEntered = NO;
    
    if (YES == flEntered) return;
    flEntered = YES;
    
    BannerContainerViewController * bannerController = (BannerContainerViewController *)self;
    BannerViewController * viewController = (BannerViewController *)[bannerController.bannerViewControllers objectAtIndex:VIRGIL_BANNER_INDEX];

    NSTextField * curTextField;
    for (id viewElement in [(NSView *)viewController.view subviews]) {
        NSString * className = NSStringFromClass ([viewElement class]);
        
        if ([className isEqualTo:@"NSTextField"]) {
            curTextField = (NSTextField *)viewElement;
            
        } else if ([className isEqualTo:@"BannerImageView"]) {
            NSImageView * imageView = (NSImageView *)viewElement;
            if ([imageView isExistsDynVar:BANNER_IMAGE]) {
                [imageView setImage:[imageView dynVar:BANNER_IMAGE]];
            }
            
        } else if ([className isEqualTo:@"NSButton"]) {
            NSButton * button = (NSButton *)viewElement;
            if ([button isExistsDynVar:BUTTON_TITLE]) button.title = [button dynVar:BUTTON_TITLE];
            if ([button isExistsDynVar:BUTTON_TARGET]) [[button cell] setTarget:[button dynVar:BUTTON_TARGET]];
            if ([button isExistsDynVar:BUTTON_ACTION]) [[button cell] setAction:NSSelectorFromString([button dynVar:BUTTON_ACTION])];
        }
    }
    
    if (curTextField && [viewController isExistsDynVar:BANNER_TEXT_FIELD]) {
        NSTextField * original = [viewController dynVar:BANNER_TEXT_FIELD];
        [(NSView *)viewController.view replaceSubview:curTextField with:original];
        [(NSView *)viewController.view setNeedsDisplay:YES];
    }
    
    // TODO: Pay attention here
    viewController.wantsDisplay = NO;
    flEntered = NO;
}

- (void) showEmailConfirmation {
    BannerContainerViewController * bannerController = (BannerContainerViewController *)self;
    BannerViewController * viewController = (BannerViewController *)[bannerController.bannerViewControllers objectAtIndex:VIRGIL_BANNER_INDEX];
    
    NSTextField * oldTextField = nil;
    
    for (id viewElement in [(NSView *)viewController.view subviews]) {
        NSString * className = NSStringFromClass ([viewElement class]);
        
        if ([className isEqualTo:@"NSTextField"]) {
            oldTextField = (NSTextField *)viewElement;
            
        } else if ([className isEqualTo:@"BannerImageView"]) {
            NSImageView * imageView = (NSImageView *)viewElement;
            if (![imageView isExistsDynVar:BANNER_IMAGE]) [imageView setDynVar:BANNER_IMAGE value:imageView.image];
            
            [imageView setImage:[NSImage imageNamed:@"menu"]];
            
        } else if ([className isEqualTo:@"NSButton"]) {
            NSButton * button = (NSButton *)viewElement;
            if (![button isExistsDynVar:BUTTON_TITLE]) [button setDynVar:BUTTON_TITLE value:button.title];
            if (![button isExistsDynVar:BUTTON_TARGET]) [button setDynVar:BUTTON_TARGET value:[[button cell] target]];
            if (![button isExistsDynVar:BUTTON_ACTION]) [button setDynVar:BUTTON_ACTION value:NSStringFromSelector([[button cell] action])];
            [button setTitle:@"Confirm"];
            [[button cell] setAction:@selector(onConfirmClicked:)];
            [[button cell] setTarget:self];
        }
    }
    
    if (nil != oldTextField) {
        if (![viewController isExistsDynVar:BANNER_TEXT_FIELD]) [viewController setDynVar:BANNER_TEXT_FIELD value:oldTextField];
        
        NSString * account = [bannerController.representedObject dynVar:@"ConfirmationAccount"];
        NSString * message = [NSString stringWithFormat:@"This message contains confirmation code for account %@", account];
        NSTextField * newTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 2, 200, 25)];
        [newTextField setFont:oldTextField.font];
        [newTextField setTextColor:oldTextField.textColor];
        [newTextField setStringValue : message];
        [newTextField setBackgroundColor:oldTextField.backgroundColor];
        [newTextField setDrawsBackground:oldTextField.drawsBackground];
        [newTextField setBordered:oldTextField.bordered];
        [newTextField setEditable:NO];
        
        [(NSView *)viewController.view replaceSubview:oldTextField with:newTextField];
    }
    
    viewController.wantsDisplay = YES;
}

- (void) clearVirgilBanner {
    BannerContainerViewController * bannerController = (BannerContainerViewController *)self;
    [bannerController.representedObject removeAllDynVars];
    [self restoreOriginalView];
    [self MAUpdateBannerDisplay];
    
    BannerViewController * viewController = (BannerViewController *)[bannerController.bannerViewControllers objectAtIndex:VIRGIL_BANNER_INDEX];
    viewController.wantsDisplay = NO;
}

- (void) onConfirmClicked : (id)sender {
    NSString * code = [((BannerContainerViewController*)self).representedObject dynVar:@"ConfirmationCode"];
    NSString * account = [((BannerContainerViewController*)self).representedObject dynVar:@"ConfirmationAccount"];
    if (nil == account | nil == code) return;
    [VirgilGui confirmAccount : account
             confirmationCode : code
                 resultObject : self
                  resultBlock : ^(id arg1, BOOL isOk) {
                      if (isOk) {
                          @try {
                              [self performSelectorOnMainThread : @selector(clearVirgilBanner)
                                                     withObject : nil
                                                  waitUntilDone : NO];
                          }
                          @catch (NSException *exception) {
                          }
                          @finally {
                          }
                      }
                  }];
}

@end
