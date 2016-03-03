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

#import "VirgilPreferences.h"
#import "VirgilPreferencesContainer.h"
#import "VirgilPreferencesWorker.h"
#import "VirgilVersion.h"

@implementation VirgilPreferences

NSString * homePage = @"https://virgilsecurity.com";
NSString * updateURL = @"https://downloads.virgilsecurity.com/apps/virgil-mail/apple-mail/VirgilSecurityMail.dmg";

NSMutableAttributedString * normalHomeLink = nil;
NSMutableAttributedString * activeHomeLink = nil;


-(id)init {
	self = [super init];
	if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver : self
                   selector : @selector(defaultsChanged:)
                       name : NSUserDefaultsDidChangeNotification
                     object : nil];
	}
	
	return self;
}

- (void) dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver : self
                      name : NSUserDefaultsDidChangeNotification
                    object : nil];
}

- (void)defaultsChanged : (NSNotification *)notification {
    [self updateGuiElements];
}

- (NSImage *)imageForPreferenceNamed:(NSString *)aName {
    return [NSImage imageNamed:@"square"];
}

- (IBAction)onOptionChanged:(id)sender {
    BOOL isOn = NSOnState == [sender state];
    [VirgilPreferencesContainer setUseEncryption : isOn];
}

- (IBAction)onDownloadUpdate:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:updateURL]];
}

- (void) updateGuiElements {
    // ----------- Load settings -----------
    NSInteger encByDefaultState = [VirgilPreferencesContainer isUseEncryption] ? NSOnState : NSOffState;
    [_encByDefaultCheckBox setState:encByDefaultState];
    
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
    
    // -------- Load versions info ---------
    [[VirgilVersion sharedInstance] setDelegate:self];
    [self reloadVersionInfo];
}

- (void) showLatestVersion : (NSString *) latestVersion {
    BOOL canShow = latestVersion != nil;
    _latestVersionTextField.hidden = !canShow;
    _latestVersionLabel.hidden = !canShow;
    if (canShow) {
        [_latestVersionTextField setStringValue:latestVersion];
    }
}

- (void) showUpdateButton : (BOOL) show {
    _btnUpdate.hidden = !show;
}

- (void) reloadVersionInfo {
    [_currentVersionTextField setStringValue:[[VirgilVersion sharedInstance] currentVersion]];
    NSString * latestVersion = [[VirgilVersion sharedInstance] cachedLatestVersion];
    [self showLatestVersion:latestVersion];
    BOOL needUpdate = [[VirgilVersion sharedInstance] isNeedUpdate];
    [self showUpdateButton:needUpdate];
}

- (void) versionUpdated : (NSString * _Nullable) newVersion {
    [self reloadVersionInfo];
}


- (IBAction)onOpenHomeLink:(id)sender {
    [_btnHomeLink setAttributedTitle:activeHomeLink];
    
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_btnHomeLink setAttributedTitle:normalHomeLink];
    });
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:homePage]];
}

- (void)willBeDisplayed {
    [self updateGuiElements];
}

- (BOOL)isResizable {
	return NO;
}


@end
