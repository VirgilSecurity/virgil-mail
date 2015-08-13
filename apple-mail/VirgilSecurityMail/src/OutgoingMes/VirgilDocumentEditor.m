//
//  VirgilDocumentEditor.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 12.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilDocumentEditor.h"
#import "VirgilMenu.h"
#import "MailNotificationCenter.h"
#import "MFError.h"
#import "DocumentEditor.h"

@implementation VirgilDocumentEditor

- (void) MABackEndDidLoadInitialContent : (id)content {
    NSLog(@"MABackEndDidLoadInitialContent");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didExitFullScreen:)
                                                 name:@"NSWindowDidExitFullScreenNotification"
                                               object:nil];
    
    [self addMenu];
    [self MABackEndDidLoadInitialContent:content];
}

- (void) addMenu {
    VirgilMenu * menu = [[VirgilMenu alloc] init];
    menu.delegate = self;
    NSWindow *window = [self valueForKey:@"_window"];

    if([NSApp mainWindow].styleMask & NSFullScreenWindowMask)
        [menu prepareForFullScreen:window];
    else
        [menu prepareForNormalView:window];
}

- (void)didExitFullScreen:(NSNotification *)notification {
    //[self performSelectorOnMainThread:@selector(configureSecurityMethodAccessoryViewForNormalMode) withObject:nil waitUntilDone:NO];
}

- (void) hideMenu {
    
}

- (void)MADealloc {
    @try {
        [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] removeObserver:self];
        [(MailNotificationCenter *)[NSClassFromString(@"MailNotificationCenter") defaultCenter] removeObserver:self];
    }
    @catch(NSException *e) {
        
    }
    [self MADealloc];
}

- (void)MABackEnd:(id)backEnd didCancelMessageDeliveryForEncryptionError:(MFError *)error {
    [self MABackEnd:backEnd didCancelMessageDeliveryForEncryptionError:error];
}

- (void)MABackEnd:(id)backEnd didCancelMessageDeliveryForError:(MFError *)error {
    [self MABackEnd:backEnd didCancelMessageDeliveryForError:error];
}

@end
