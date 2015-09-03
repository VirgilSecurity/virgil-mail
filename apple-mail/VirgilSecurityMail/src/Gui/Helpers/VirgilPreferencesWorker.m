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

#import "VirgilPreferencesWorker.h"
#import <NSPreferences.h>
#import <NSPreferencesModule.h>

#import "VirgilPreferences.h"

@implementation NSPreferences (Virgil)

static BOOL _showAllItems = YES;
static NSString * _preferencesName = @"Virgil Preferences";

+ (NSString *) virgilPreferencesName {
    return _preferencesName;
}

+ (id) MASharedPreferences {
    static BOOL added = NO;
    
	id preferences = [self MASharedPreferences];
    if(nil == preferences) return nil;
    
    if (added) return preferences;
    
    NSPreferencesModule * virgilPreferences = [VirgilPreferences sharedInstance];
    [preferences addPreferenceNamed : _preferencesName
                              owner : virgilPreferences];
    added = YES;
	
    NSWindow *preferencesPanel = [preferences valueForKey:@"_preferencesPanel"];
    NSToolbar *toolbar = [preferencesPanel toolbar];
    if(nil == toolbar) return preferences;
    
    [toolbar insertItemWithItemIdentifier : _preferencesName
                                  atIndex : [[toolbar items] count]];
    _showAllItems = YES;
    [preferences resizeWindowToShowAllToolbarItems:preferencesPanel];
    return preferences;
}

- (NSSize)sizeForWindowShowingAllToolbarItems:(NSWindow *)window {
    NSRect frame = [window frame];
    float width = 0.0f;
	NSArray *subviews = [[[[window toolbar] valueForKey:@"_toolbarView"] subviews][0] subviews];
    for (NSView *view in subviews) {
        width += view.frame.size.width;
	}
    // Add padding to fit them all.
    width += 10;
    return NSMakeSize(width > frame.size.width ? width : frame.size.width, frame.size.height);
}

- (NSSize)MAWindowWillResize:(id)window toSize:(NSSize)toSize {
    if(NO == _showAllItems)
        return [self MAWindowWillResize:window toSize:toSize];
    
    NSSize newSize = [self sizeForWindowShowingAllToolbarItems:window];
    _showAllItems = NO;
    return newSize;
}

- (void)resizeWindowToShowAllToolbarItems:(NSWindow *)window {
    NSRect frame = [window frame];
    frame.size = [self sizeForWindowShowingAllToolbarItems:window];
    _showAllItems = YES;
    [window setFrame:frame display:YES];
}

- (void)MAToolbarItemClicked:(id)toolbarItem {
    [self MAToolbarItemClicked : toolbarItem];
    [self resizeWindowToShowAllToolbarItems:[self valueForKey:@"_preferencesPanel"]];
}

- (void)MAShowPreferencesPanelForOwner:(id)owner {
    [self MAShowPreferencesPanelForOwner:owner];
    [self resizeWindowToShowAllToolbarItems:[self valueForKey:@"_preferencesPanel"]];
}

@end
