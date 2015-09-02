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
