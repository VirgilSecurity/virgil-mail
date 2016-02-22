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

#import <Foundation/Foundation.h>

enum MenuElement {
    menuEl_unknown = -1,
    menuEl_active,
    menuEl_inactive
};

@class VirgilMenu;

@protocol VirgilMenuViewDelegate <NSObject>

- (void) menuView:(VirgilMenu *)menu selectedElement:(id)element;

@end

@interface VirgilMenu : NSView <NSMenuDelegate> {
    BOOL _fullscreen;
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

@property (nonatomic, assign) BOOL available;
@property (nonatomic, weak) id <VirgilMenuViewDelegate> delegate;

- (id) init;
- (void) elementSelected : (id)sender;
- (void) prepareForFullScreen : (NSWindow *)window;
- (void) prepareForNormalView : (NSWindow *)window;
- (void) updateAndCenterLabel;

@end

