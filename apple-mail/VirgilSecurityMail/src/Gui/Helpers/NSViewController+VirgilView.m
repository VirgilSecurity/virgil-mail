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

#import "NSViewController+VirgilView.h"
#import "VirgilReplaceAnimator.h"
#import "VirgilErrorViewController.h"

@implementation NSViewController (VirgilView)

- (BOOL) changeView : (NSString *) newViewName {
    NSStoryboard * storyboard = [self storyboard];
    if (nil == storyboard) return NO;
    NSViewController * controller =
    (NSViewController*)[storyboard instantiateControllerWithIdentifier : newViewName];
    if (nil == controller) return NO;
    [self presentViewController : controller
                       animator : [[VirgilReplaceAnimator alloc] init]];
    return YES;
}

- (BOOL) showErrorView : (NSString *) errorText {
    NSStoryboard * storyboard = [self storyboard];
    
    if (nil == storyboard) return NO;
    VirgilErrorViewController * controller =
    (VirgilErrorViewController*)[storyboard instantiateControllerWithIdentifier : @"viewError"];
    
    if (nil == controller) return NO;
    
    [controller setErrorText : errorText];
    
    [self presentViewControllerAsSheet : controller];
    
    return YES;
}

- (BOOL) showCompactErrorView : (NSString *) errorText
                       atView : (NSView *) atView {
    NSStoryboard * storyboard = [self storyboard];
    
    if (nil == storyboard) return NO;
    VirgilErrorViewController * controller =
    (VirgilErrorViewController*)[storyboard instantiateControllerWithIdentifier : @"viewCompactError"];
    
    if (nil == controller) return NO;
    
    [controller setErrorText : errorText];
    
    [self presentViewController : controller
        asPopoverRelativeToRect : atView.bounds
                         ofView : atView
                  preferredEdge : NSMaxXEdge
                       behavior : NSPopoverBehaviorTransient];
    return YES;
}

- (void) closeWindow {
    NSWindow * mainWindow = [[NSApplication sharedApplication] mainWindow];
    NSWindow * curWindow = [[self view] window];
    [mainWindow endSheet : curWindow
              returnCode : NSModalResponseStop];
    [curWindow close];
}

@end
