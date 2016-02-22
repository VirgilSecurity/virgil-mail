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
#import "VirgilMain.h"
#import "VirgilLog.h"
#import "VirgilProcessingManager.h"
#import "MailNotificationCenter.h"
#import "MFError.h"
#import "DocumentEditor.h"
#import "VirgilGui.h"
#import "VirgilHeadersEditor.h"

@implementation VirgilDocumentEditor

- (void) MABackEndDidLoadInitialContent : (id)content {
    [self addMenu];
    [self MABackEndDidLoadInitialContent:content];
}

- (void) addMenu {
    VirgilMenu * menu = [[VirgilMenu alloc] init];
    menu.delegate = self;
    
    if(![VirgilMain isElCapitan]) {
        NSWindow *window = [self valueForKey:@"_window"];

        if([NSApp mainWindow].styleMask & NSFullScreenWindowMask)
            [menu prepareForFullScreen:window];
        else
            [menu prepareForNormalView:window];
    }
}

- (void)didExitFullScreen:(NSNotification *)notification {
}

- (void) hideMenu {
}

- (void) MAShow {
    [self MAShow];
    
#if 0
    if (NO == catchNotificationsReady) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver : self
                   selector : @selector(checkAccount:)
                       name : NSUserDefaultsDidChangeNotification
                     object : nil];
        catchNotificationsReady = YES;
    }
#endif
    
    [self checkAccount : nil];
}

- (void) MASend:(id)arg1 {
    NSString * senderEmail;
    
    @try {
        VirgilHeadersEditor * vhe = ((DocumentEditor *)self).headersEditor;
        senderEmail = [vhe currentFrom];
    }
    @catch (NSException *exception) {}
    @finally {}
    
    BOOL canSend = [[VirgilProcessingManager sharedInstance] canSendEmail:senderEmail];
    
    if (canSend) {
        [self MASend:arg1];
    } else {
        [self checkAccount:nil];
    }
}

- (void) checkAccount : (NSNotification *)notification {
    @try {
        VirgilHeadersEditor * vhe = ((DocumentEditor *)self).headersEditor;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                           [vhe checkAccount];
                       });
        
    }
    @catch (NSException *exception) {}
    @finally {}
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


@end
