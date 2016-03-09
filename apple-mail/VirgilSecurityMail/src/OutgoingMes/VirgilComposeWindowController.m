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

#import "VirgilComposeWindowController.h"
#import "VirgilMailToolbar.h"
#import "VirgilMenu.h"
#import "VirgilDynamicVariables.h"

@implementation VirgilComposeWindowController

- (id)VSMToolbarDefaultItemIdentifiers:(id)toolbar {
    id defaultItemIdentifiers = [self VSMToolbarDefaultItemIdentifiers:toolbar];
    
    NSMutableArray *identifiers = [defaultItemIdentifiers mutableCopy];
    [identifiers addObject:VIRGIL_MENU_IDENTIFIER];
    
    return identifiers;
}

- (id)VSMToolbar:(id)toolbar itemForItemIdentifier:(id)itemIdentifier willBeInsertedIntoToolbar:(BOOL)willBeInsertedIntoToolbar {
    if(![itemIdentifier isEqualToString:VIRGIL_MENU_IDENTIFIER]) {
        return [self VSMToolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:willBeInsertedIntoToolbar];
    }
    
    for(NSToolbarItem *item in [toolbar items]) {
        if([item.itemIdentifier isEqualToString:itemIdentifier])
            return nil;
    }
    
    VirgilMenu * menu = [[VirgilMenu alloc] init];
    [self setDynVar:menu value:@"VirgilDocumentMenu"];
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    
    [item setView : menu];
    [item setMinSize:NSMakeSize(75, 23)];
    [item setTarget:nil];
    
    return item;
}

- (void)VSM_performSendAnimation {
    [self VSM_performSendAnimation];
}

- (void)VSM_tabBarView:(id)tabBarView performSendAnimationOfTabBarViewItem:(id)tabBarViewItem {
    [self VSM_tabBarView:tabBarView performSendAnimationOfTabBarViewItem:tabBarViewItem];
}

@end
