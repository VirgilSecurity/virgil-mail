//
//  VirgilDocumentEditor.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 12.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirgilMenu.h"

@interface VirgilDocumentEditor : NSObject <NSMenuDelegate, VirgilMenuViewDelegate>
- (void) MABackEndDidLoadInitialContent : (id)content;
- (void) MADealloc;
- (void) addMenu;
- (void) didExitFullScreen : (NSNotification *)notification;
- (void) hideMenu;

@end
