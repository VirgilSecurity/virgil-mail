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

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self printBundleVersion];
    updater = [SUUpdater sharedUpdater];
    updater.delegate = self;
    updater.automaticallyDownloadsUpdates = YES;
    [updater checkForUpdatesInBackground];
    
    [NSTimer scheduledTimerWithTimeInterval : 30
                                     target : self
                                   selector : @selector(terminateIfIdle)
                                   userInfo : nil
                                    repeats : YES];
}

- (void) printBundleVersion {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *app = [info objectForKey:@"CFBundleName"];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"%@ : %@", app, version);
}

- (NSString *) pathToRelaunchForUpdater : (SUUpdater *)updater {
    return @"/Applications/Mail.app";
}

- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)item {
    /*[NSTimer scheduledTimerWithTimeInterval : 5
                                     target : self
                                   selector : @selector(raiseApp)
                                   userInfo : nil
                                    repeats : NO];*/
    NSLog(@"didFindValidUpdate");
}

- (void)updater:(SUUpdater *)updater willDownloadUpdate:(SUAppcastItem *)item withRequest:(NSMutableURLRequest *)request {
    NSLog(@"willDownloadUpdate");
}

- (void)updater:(SUUpdater *)updater willInstallUpdate:(SUAppcastItem *)item {
     NSLog(@"willInstallUpdate");
}

- (void) raiseApp {
    [NSApp activateIgnoringOtherApps:YES];
}

- (void) terminateIfIdle {
    //if (![updater updateInProgress]) {
        [NSApp terminate:nil];
    //}
}

@end
