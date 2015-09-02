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

#import "VirgilNSWindow.h"
#import "DocumentEditor.h"
#import "VirgilDocumentEditor.h"

@implementation NSWindow (Virgil)

- (void) MAToggleFullScreen : (id)sender {
    NSLog(@"MAToggleFullScreen");
    
#if 0
    for(DocumentEditor * editor in [/*DocumentEditor*/NSClassFromString(@"DocumentEditor") documentEditors]) {
        if(editor.isModal) {
            [((VirgilDocumentEditor *)editor) hideMenu];
        }
    }
#endif
    
    [self MAToggleFullScreen:sender];
}

- (void) addMenu : (NSView *)menu {
    NSView *themeFrame = [[self contentView] superview];
    [self setPositionOfMenu:menu];
    [[(id)themeFrame titlebarView] addSubview:menu];
}

- (void) setPositionOfMenu : (NSView *)menu {
    [self setPositionOfMenu:menu offset:NSMakePoint(0.0f, 0.0f)];
}

- (void) setPositionOfMenu : (NSView *)menu
                    offset : (NSPoint)offset {
    NSView *themeFrame = [[self contentView] superview];
    NSRect c = [[(id)themeFrame titlebarView] frame];	// c for "container"
    NSRect mV = [menu frame];	// mV for "menu view"
    
    NSRect newFrame = NSMakeRect(
                                 c.size.width - mV.size.width - offset.x,	// x position
                                 c.size.height - mV.size.height - offset.y,	// y position
                                 mV.size.width,	// width
                                 mV.size.height);	// height
    
    [menu setFrame:newFrame];
}

@end


