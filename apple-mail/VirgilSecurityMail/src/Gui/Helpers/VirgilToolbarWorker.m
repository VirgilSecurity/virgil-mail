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

#import "VirgilToolbarWorker.h"
#import "VirgilGui.h"

#define VIRGIL_ITEM_IDENTIFIER @"virgilMenu:"

@implementation NSToolbar (Virgil)

- (id) MAConfigureToolbarItems {
    id result = [self MAConfigureToolbarItems];
    
    NSString * tbName = [self identifier];
    NSArray  * toolbarArray = nil;
    
    NSString *itemAtRightFromDefaults = @"";
    
    if ([tbName isEqualToString:@"MainWindow"] ){
        NSDictionary * toolbarItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"Virgil Security Menu", @"help",
                                  VIRGIL_ITEM_IDENTIFIER, @"identifier",
                                  @"rect", @"image",
                                  @"9000", @"tag",
                                  @"Virgil Security Menu", @"title",
                                  @"Virgil Security", @"paletteLabel",
                                  @"Virgil Security", @"altTitle",
                                  nil];
        
        toolbarArray = [NSArray arrayWithObjects : toolbarItem, nil];
        
        itemAtRightFromDefaults = @"Search";
        
    }
    
    if (nil != toolbarArray) {
        
        NSInteger itemsCount = [toolbarArray count];
        NSArray * defaultItems = [result objectForKey : @"DefaultToolbarItems"];
        NSInteger index = [defaultItems indexOfObject : itemAtRightFromDefaults];
        
        for (int i = 0; i < itemsCount; i++) {
            
            id identifier = [[toolbarArray objectAtIndex : i] objectForKey : @"identifier"];
            [result setObject: [toolbarArray objectAtIndex : i] forKey: identifier];
            
            //all
            if(![[result objectForKey : @"AllToolbarItems"] containsObject : identifier]) {
                [[result objectForKey : @"AllToolbarItems"] addObject : identifier];
            }
            
            //defaults
            if(![[result objectForKey : @"DefaultToolbarItems"] containsObject : identifier]) {
                [[result objectForKey : @"DefaultToolbarItems"] insertObject : identifier
                                                                     atIndex : index - 1];
            }
        }
    }
    
    [[VirgilToolbarDelegate sharedInstance] setDefaultDelegate : [self delegate]];
    [self setDelegate : [VirgilToolbarDelegate sharedInstance]];
    
    return result;
}

@end

@implementation VirgilToolbarDelegate

@synthesize defaultDelegate = _defaultDelegate;

+ (VirgilToolbarDelegate *) sharedInstance {
    static VirgilToolbarDelegate * singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    
    return singletonObject;
}

+ (id) alloc{
    return [super alloc];
}

- (id) init{
    _defaultDelegate = nil;
    return [super init];
}

- (void) toolbarWillAddItem: (NSNotification *) notification {
    if (nil != _defaultDelegate) {
        [_defaultDelegate toolbarWillAddItem : notification];
    }
}

- (void) onVirgilMenuClicked {
    [VirgilGui showAccountsFor:nil];
}

- (void) toolbarDidRemoveItem : (NSNotification *) notification {
    if (nil != _defaultDelegate) {
        [_defaultDelegate toolbarDidRemoveItem : notification];
    }
}

- (void) setDefaultDelegate : (id <NSToolbarDelegate>) a_defaultDelegate {
    _defaultDelegate = a_defaultDelegate;
}

- (NSToolbarItem *) toolbar : (NSToolbar *) toolbar
      itemForItemIdentifier : (NSString *) itemIdentifier
  willBeInsertedIntoToolbar : (BOOL)flag {
    
    if ([itemIdentifier isEqualToString : VIRGIL_ITEM_IDENTIFIER]) {
        NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier : itemIdentifier];
        NSButton * btn = [[NSButton alloc] init];
        
        NSString * _title = @"Virgil Menu";
        [btn setButtonType : NSMomentaryPushInButton];
        [btn setBezelStyle : NSTexturedRoundedBezelStyle];
        [btn setAlignment : NSCenterTextAlignment];
        [btn setEnabled : YES];
        [btn setTitle : @""];

        [item setView : btn];
        NSSize _sz = NSMakeSize(42, 23);
        [item setMinSize : _sz];
        [item setMaxSize : _sz];
        [item setLabel : _title];
        [item setImage : [NSImage imageNamed:@"rect"]];
        [item setTarget : self];
        [item setAction : @selector(onVirgilMenuClicked)];

        return item;
    } else if (nil != _defaultDelegate) {
        return [_defaultDelegate toolbar : toolbar
                   itemForItemIdentifier : itemIdentifier
               willBeInsertedIntoToolbar : flag];
    }
    return nil;
}

- (NSArray *) toolbarDefaultItemIdentifiers : (NSToolbar *) toolbar {
    if (nil != _defaultDelegate) {
        return [_defaultDelegate toolbarDefaultItemIdentifiers : toolbar];
    }
    return nil;
}

- (NSArray *) toolbarAllowedItemIdentifiers : (NSToolbar *) toolbar {
    if (nil != _defaultDelegate) {
        return [_defaultDelegate toolbarAllowedItemIdentifiers : toolbar];
    }
    return nil;
}

- (NSArray *) toolbarSelectableItemIdentifiers : (NSToolbar *) toolbar {
    if (nil != _defaultDelegate) {
        return [_defaultDelegate toolbarSelectableItemIdentifiers : toolbar];
    }
    return nil;
}

@end
