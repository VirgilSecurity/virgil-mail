/**
 * Copyright (C) 2016 Virgil Security Inc.
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

#import "VirgilUpdaterWindowController.h"

@interface VirgilUpdaterWindowController ()

@end

@implementation VirgilUpdaterWindowController

NSMutableAttributedString * normalHomeLink = nil;
NSMutableAttributedString * activeHomeLink = nil;
NSString * homePage = @"https://virgilsecurity.com";
BOOL needInstall = NO;
BOOL viewLoaded = NO;

NSString * currentVersionStr = @"";
NSString * latestVersionStr = @"";

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // --------- Prepare home link ---------
    NSColor *color = [NSColor blueColor];
    normalHomeLink =
    [[NSMutableAttributedString alloc] initWithAttributedString:[_btnHomeLink attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [normalHomeLink length]);
    [normalHomeLink addAttributes : @{NSForegroundColorAttributeName:color,NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]}
                            range : titleRange];
    
    NSColor *colorAlt = [NSColor colorWithCalibratedRed:(30/255.0f) green:(144/255.0f) blue:(255/255.0f) alpha:1.0];
    activeHomeLink =
    [[NSMutableAttributedString alloc] initWithAttributedString:[_btnHomeLink attributedTitle]];
    [activeHomeLink addAttributes : @{NSForegroundColorAttributeName:colorAlt,NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]}
                            range : titleRange];
    
    [_btnHomeLink setAttributedTitle:normalHomeLink];
    [[self window] setLevel:NSFloatingWindowLevel];
    viewLoaded = YES;
    [self showVersions];
}

- (void) showCurrentVersion : (NSString *)currentVersion
              latestVersion : (NSString *)latestVersion {
    currentVersionStr = currentVersion;
    latestVersionStr = latestVersion;
    [self showVersions];
}

- (void) showVersions {
    if (viewLoaded) {
        _currentVersionTextView.stringValue = currentVersionStr;
        _latestVersionTextView.stringValue = latestVersionStr;
    }
}

- (id)init {
    self = [super initWithWindowNibName:@"VirgilUpdaterWindowController"];
    return self;
}

- (IBAction)onInstallUpdate:(id)sender {
    needInstall = YES;
    [self close];
}

- (IBAction)onTerminateUpdate:(id)sender {
    [self close];
}

- (void)windowWillClose:(NSNotification *)notification {
    if (_delegate != nil) {
        if (needInstall) {
            [_delegate installUpdate];
        } else {
            [_delegate terminateUpdate];
        }
    }
}

- (IBAction)onOpenHomePage:(id)sender {
    [_btnHomeLink setAttributedTitle:activeHomeLink];
    
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_btnHomeLink setAttributedTitle:normalHomeLink];
    });
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:homePage]];
}

@end
