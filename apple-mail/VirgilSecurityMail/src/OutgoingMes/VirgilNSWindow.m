//
//  VirgilNSWindow.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 12.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

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


