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

#import "VirgilMenu.h"
#import "VirgilNSWindow.h"
#import "VirgilProcessingManager.h"
#import "VirgilPreferencesContainer.h"
#import "NSBezierPath_KBAdditions.h"
#import "NSBezierPath+StrokeExtensions.h"
#import <Cocoa/Cocoa.h>

#define MENU_DEFAULT_HEIGHT 17.0f
#define MENU_DEFAULT_WIDTH 80.0f
#define MENU_FULLSCREEN_HEIGHT 22.0f

@interface VirgilMenu ()

@property (nonatomic, assign) BOOL fullscreen;
@property (nonatomic, assign) NSRect nonFullScreenFrame;

@property (nonatomic, strong) NSPopUpButton *popup;
@property (nonatomic, strong) NSTextField *label;

@property (nonatomic, strong) NSMapTable *attributedTitlesCache;

@property (nonatomic, strong) NSMutableArray *radioItems;
@property (nonatomic, strong) NSMutableArray *itemTitles;

@end

@implementation VirgilMenu

- (id) init {
    self = [super initWithFrame:NSMakeRect(0.0f, 0.0f, MENU_DEFAULT_WIDTH, MENU_DEFAULT_HEIGHT)];
    if(self) {
        self.autoresizingMask = NSViewMinYMargin | NSViewMinXMargin;
        _attributedTitlesCache = [NSMapTable mapTableWithStrongToStrongObjects];
        _available = YES;
        _radioItems = [[NSMutableArray alloc] init];
        _itemTitles = [[NSMutableArray alloc] init];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver : self
                   selector : @selector(defaultsChanged:)
                       name : NSUserDefaultsDidChangeNotification
                     object : nil];
        [self createMenu];
    }
    return self;
}

- (void) dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver : self
                      name : NSUserDefaultsDidChangeNotification
                    object : nil];
}

- (void) defaultsChanged : (NSNotification *)notification {
    [self setNeedsDisplay : YES];
    [self updateAndCenterLabel];
    [self updateMenuState];
}

- (void) createMenu {
    NSPopUpButton *popup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0.0f, 0.0f,
                                                                           self.frame.size.width,
                                                                           self.frame.size.height)
                                                      pullsDown:NO];
    [[popup cell] setArrowPosition:NSPopUpNoArrow];
    [popup setAutoresizingMask:NSViewMinYMargin];
    [popup setBordered:NO];
    
    NSMenu *menu = popup.menu;
    menu.autoenablesItems = NO;
    menu.delegate = self;
    
    [_radioItems removeAllObjects];
    
    [_itemTitles removeAllObjects];
    [self appendMenuItemForParent:menu
                        withTitle:@"Active"
                              tag:(int)menuEl_active
                      isCheckable:YES
                   actionSelector:@selector(elementSelected:)];
    
    [self appendMenuItemForParent:menu
                        withTitle:@"Inactive"
                              tag:(int)menuEl_inactive
                      isCheckable:YES
                   actionSelector:@selector(elementSelected:)];
    
    // Add the initial label.
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
    label.backgroundColor = [NSColor clearColor];
    label.bordered = NO;
    label.selectable = NO;
    label.editable = NO;
    label.font = [NSFont fontWithName:@"Menlo" size:12];
    [label setTextColor:[NSColor whiteColor]];
    
    [self addSubview:label];
    self.label = label;
    
    [self addSubview:popup];
    self.popup = popup;
    
    [self updateAndCenterLabel];
    [self updateMenuState];
}

- (void) updateMenuState {
    if (YES == [VirgilPreferencesContainer isUseEncryption]) {
        [_popup selectItemWithTag:menuEl_active];
    } else {
        [_popup selectItemWithTag:menuEl_inactive];
    }
}

- (void) appendMenuSeparatorForParent:(NSMenu *) parent {
    [parent addItem:[NSMenuItem separatorItem]];
    [_itemTitles addObject:@""];
}

- (void) appendMenuItemForParent:(NSMenu *) parent
                               withTitle:(NSString *)title
                                     tag:(int)tag
                             isCheckable:(BOOL)checkable
                          actionSelector:(SEL)actionSelector {
    
    NSMenuItem *item = [parent addItemWithTitle:title
                                         action:actionSelector
                                  keyEquivalent:@""];
    [_itemTitles addObject:title];
    item.target = self;
    item.enabled = YES;
    item.tag = tag;
    item.keyEquivalentModifierMask = NSCommandKeyMask | NSAlternateKeyMask;
    item.title = @"";
    
    if (YES == checkable) {
        [_radioItems addObject:item];
    }
}

- (void) elementSelected : (id)sender {
    BOOL isActive = menuEl_active == [sender tag];
    [VirgilPreferencesContainer setUseEncryption : isActive];
    [self menuDidClose:self.menu];
}

- (void) prepareForFullScreen : (NSWindow *)window {
    self.fullscreen = YES;
    [window addMenu:self];
    [window setPositionOfMenu:self offset:NSMakePoint(200.0f, 0.f)];
    NSRect frame = self.frame;
    frame.size.height = MENU_FULLSCREEN_HEIGHT;
    frame.origin.y = frame.origin.y - 16.0f;
    self.frame = frame;
    
    self.popup.frame = NSMakeRect(0.0f, 0.0f, self.frame.size.width, MENU_FULLSCREEN_HEIGHT);
    self.popup.menu.font = [NSFont systemFontOfSize:12.f];
    [self.popup setNeedsDisplay];
    
    [self updateAndCenterLabel];
}

- (void) prepareForNormalView : (NSWindow *)window {
    self.fullscreen = NO;
    [self removeFromSuperview];
    
    NSRect frame = self.frame;
    frame.size.height = 17.0f;
    self.frame = frame;
    self.hidden = NO;
    
    // Adjust the height of the popup.
    self.popup.frame = NSMakeRect(0.0f, 0.0f, self.frame.size.width, MENU_DEFAULT_HEIGHT);
    self.popup.menu.font = [NSFont systemFontOfSize:10.f];
    [self.popup setNeedsDisplay];
    
    [self updateAndCenterLabel];
    
    [window addMenu:self];
}

- (void)updateAndCenterLabel {
    [self.label setStringValue:@"Virgil"];
    [self.label sizeToFit];
    NSRect frame = self.label.frame;
    
    frame.origin.y = 2;
    
    // Now center the new label.
    frame.origin.x = roundf((self.frame.size.width - frame.size.width) / 2.0f);
    self.label.frame = frame;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = [self bounds];
    rect.origin = NSMakePoint(0, 0);
    float cornerRadius = 4.0f;
    KBCornerType corners = self.fullscreen ? (KBTopLeftCorner | KBBottomLeftCorner | KBTopRightCorner | KBBottomRightCorner) : (KBTopRightCorner | KBBottomLeftCorner);
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect inCorners:corners cornerRadius:cornerRadius flipped:NO];
    
    NSGradient *gradient = nil;
    NSColor *strokeColor = nil;
    
    if (self.available) {
        if(YES == [VirgilPreferencesContainer isUseEncryption]) {
            gradient = [self gradientUseEncryptionColor:&strokeColor];
        } else {
            gradient = [self gradientDontUseEncryptionColor:&strokeColor];
        }
    } else {
        gradient = [self gradientNotAvailableColor:&strokeColor];
    }
    
    [gradient drawInBezierPath:path angle:90.0f];
    [strokeColor setStroke];
    
    [path strokeInside];
}

- (NSGradient *)gradientNotAvailableColor:(NSColor **)strokeColor {
    NSGradient *gradient = nil;
    
    NSUInteger greenStart = 128.0f;
    NSUInteger greenStep = 18.0f;
    
    if(!self.fullscreen) {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:0/255.0f green:greenStart/255.0f blue:0/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:0/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:0/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 2))/255.0f blue:0/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 3))/255.0f blue:0/255.0f alpha:1.0], 1.0f, nil];
    }
    else {
        greenStep = 8.0f;
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 6))/255.0f blue:0/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 7))/255.0f blue:0/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 8))/255.0f blue:0/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 9))/255.0f blue:0/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:0/255.0f green:(greenStart + (greenStep * 10))/255.0f blue:0/255.0f alpha:1.0], 1.0f, nil];
    }
    
    *strokeColor = [NSColor colorWithDeviceRed:0/255.0f green:greenStart/255.0f blue:0/255.0f alpha:1.0];
    
    return gradient;
}

- (NSGradient *)gradientUseEncryptionColor:(NSColor **)strokeColor {
    NSGradient *gradient = nil;
    
    NSUInteger redStart = 20.0f;
    NSUInteger greenStart = 80.0f;
    // Start for full screen.
    NSUInteger greenStartAlt = 128.0f;
    NSUInteger blueStart = 240.0f;
    NSUInteger redStep, greenStep, blueStep;
    redStep = greenStep = blueStep = 18.0f;
    
    if(!self.fullscreen) {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:redStart/255.0f green:greenStart/255.0f blue:blueStart/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 1))/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:blueStart/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 1))/255.0f green:(greenStart + (greenStep * 1))/255.0f blue:blueStart/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 2))/255.0f green:(greenStart + (greenStep * 2))/255.0f blue:blueStart/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 3))/255.0f green:(greenStart + (greenStep * 3))/255.0f blue:blueStart/255.0f alpha:1.0], 1.0f, nil];
    }
    else {
        redStep = greenStep = blueStep = 8.0f;
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:(redStart + (redStep * 2))/255.0f green:(greenStartAlt + (greenStep * 2))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 3))/255.0f green:(greenStartAlt + (greenStep * 3))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 4))/255.0f green:(greenStartAlt + (greenStep * 4))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 5))/255.0f green:(greenStartAlt + (greenStep * 5))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(redStart + (redStep * 6))/255.0f green:(greenStartAlt + (greenStep * 6))/255.0f blue:(blueStart + (blueStep * 1))/255.0f alpha:1.0], 1.0f, nil];
    }
    
    *strokeColor = [NSColor colorWithDeviceRed:redStart/255.0f green:greenStart/255.0f blue:blueStart/255.0f alpha:1.0];
    
    return gradient;
}

- (NSGradient *)gradientDontUseEncryptionColor:(NSColor **)strokeColor {
    NSGradient *gradient = nil;
    
    NSUInteger greyStart = 146.0f;
    NSUInteger greyStep = 18.0f;
    
    if(!self.fullscreen) {
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:greyStart/255.0f green:128.0f/255.0f blue:128.0f/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 1))/255.0f green:(greyStart + (greyStep * 1))/255.0f blue:(greyStart + (greyStep * 1))/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 1))/255.0f green:(greyStart + (greyStep * 1))/255.0f blue:(greyStart + (greyStep * 1))/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 2))/255.0f green:(greyStart + (greyStep * 2))/255.0f blue:(greyStart + (greyStep * 2))/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 3))/255.0f green:(greyStart + (greyStep * 3))/255.0f blue:(greyStart + (greyStep * 3))/255.0f alpha:1.0], 1.0f,
                    nil];
    }
    else {
        greyStep = 8.0f;
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithDeviceRed:(greyStart + (greyStep * 4))/255.0f green:(greyStart + (greyStep * 4))/255.0f blue:(greyStart + (greyStep * 4))/255.0f alpha:1.0], 0.0f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 5))/255.0f green:(greyStart + (greyStep * 5))/255.0f blue:(greyStart + (greyStep * 5))/255.0f alpha:1.0], 0.13f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 6))/255.0f green:(greyStart + (greyStep * 6))/255.0f blue:(greyStart + (greyStep * 6))/255.0f alpha:1.0], 0.27f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 7))/255.0f green:(greyStart + (greyStep * 7))/255.0f blue:(greyStart + (greyStep * 7))/255.0f alpha:1.0], 0.61f,
                    [NSColor colorWithDeviceRed:(greyStart + (greyStep * 8))/255.0f green:(greyStart + (greyStep * 8))/255.0f blue:(greyStart + (greyStep * 8))/255.0f alpha:1.0], 1.0f,
                    nil];
    }
    
    
    *strokeColor = [NSColor colorWithDeviceRed:greyStart/255.0f green:greyStart/255.0f blue:greyStart/255.0f alpha:1.0];
    
    return gradient;
}

- (void)menuWillOpen:(NSMenu *)menu {
    int pos = 0;
    for(NSMenuItem *item in menu.itemArray) {
        NSString *title = [_itemTitles objectAtIndex:pos++];
        if (title) {
            item.title = title;
        }
    }
}

- (void)menuDidClose:(NSMenu *)menu {
    for(NSMenuItem *item in menu.itemArray) {
        item.attributedTitle = nil;
        item.title = @"";
    }
}

@end
