//
//  VirgilNSWindow.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 12.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSWindow (Virgil)

- (void) MAToggleFullScreen : (id)sender;

- (void) addMenu : (NSView *)menu;
- (void) setPositionOfMenu : (NSView *)menu;
- (void) setPositionOfMenu : (NSView *)menu
                    offset : (NSPoint)offset;
- (id)titlebarView;

@end

