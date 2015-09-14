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
    updater = [SUUpdater sharedUpdater];
    updater.delegate = self;
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    
    if (![arguments containsObject:@"--gui"]) {
        [updater checkForUpdates : nil];
    } else {
        [updater checkForUpdatesInBackground];
    }
    
    [NSTimer scheduledTimerWithTimeInterval : 30
                                     target : self
                                   selector : @selector(terminateIfIdle)
                                   userInfo : nil
                                    repeats : YES];
}

- (NSString *) pathToRelaunchForUpdater : (SUUpdater *)updater {
    return @"/Applications/Mail.app";
}

- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)item {
    [NSTimer scheduledTimerWithTimeInterval : 5
                                     target : self
                                   selector : @selector(raiseApp)
                                   userInfo : nil
                                    repeats : NO];
}

- (void) raiseApp {
    updater = [SUUpdater sharedUpdater];
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    int processID = [processInfo processIdentifier];
    
    NSLog(@"raiseApp %d", processID);
    
    NSTask *osascript = [[NSTask alloc] init];
    [osascript setLaunchPath:@"/usr/bin/osascript"];
    NSString * argBase = @"'tell application \"System Events\"\n set theprocs to every process whose unix id is %d\n repeat with proc in theprocs\n set the frontmost of proc to true\n end repeat\nend tell'";
    NSString * arg = [NSString stringWithFormat : argBase, processID];
    
    [osascript setArguments : [NSArray arrayWithObject : @[@"-e", arg]]];
    
    [osascript launch];
    [osascript waitUntilExit];
    
    NSLog(@"raiseApp %@", arg);
}

- (void) terminateIfIdle {
    if (![updater updateInProgress]) {
        [NSApp terminate:nil];
    }
}

@end
