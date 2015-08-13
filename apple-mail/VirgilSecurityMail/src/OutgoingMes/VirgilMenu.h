//
//  VirgilMenu.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 12.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

enum MenuElement {
    menuEl_unknown = -1,
    menuEl_active,
    menuEl_inactive,
    menuEl_preferences
};

@class VirgilMenu;

@protocol VirgilMenuViewDelegate <NSObject>

- (void) menuView:(VirgilMenu *)menu selectedElement:(id)element;

@end

@interface VirgilMenu : NSView <NSMenuDelegate> {
    BOOL _fullscreen;
    BOOL _useEncryption;
    BOOL _available;
    
    id <VirgilMenuViewDelegate> __weak _delegate;
    
    NSRect _nonFullScreenFrame;
    NSPopUpButton *_popup;
    NSImageView *_arrow;
    NSTextField *_label;
    
    NSMapTable *_attributedTitlesCache;
    NSMutableArray *_radioItems;
    NSMutableArray *_itemTitles;
}

@property (nonatomic, assign) BOOL useEncryption;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, weak) id <VirgilMenuViewDelegate> delegate;

- (id)init;
- (void) configureMenu : (NSArray *)elements;
- (void) elementSelected : (id)sender;
- (void) prepareForFullScreen : (NSWindow *)window;
- (void) prepareForNormalView : (NSWindow *)window;
- (void) setAvailable : (BOOL)available;
- (void) setUseEncryption : (BOOL)useEncryption;
- (void) updateAndCenterLabel;

@end

