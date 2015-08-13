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
//- (void) updateSecurityMethodHighlight;
- (void) hideMenu;


/**
 Setup the security method accessory view and add it to the theme frame.
 */
//- (void)setupSecurityMethodHintAccessoryView;

/**
 Called from NSWindow toggleFullScreen: to hide the accessory view.
 */
//- (void)hideSecurityMethodAccessoryView;

/**
 Delegate method which is used by the security method accessory view to inform
 the delegate that the user changed the security method.
 */
//- (void)securityMethodAccessoryView:(GMSecurityMethodAccessoryView *)accessoryView didChangeSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod;

@end
