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
#include <sys/sysctl.h>
#import "VirgilUpdaterWindowController.h"

@interface SWindowOfProcess : NSObject {
}

- (id) initPID : (pid_t)pid
         title : (NSString *)title;

@property pid_t pid;
@property (retain) NSString * title;

@end

@implementation SWindowOfProcess

- (id) initPID : (pid_t)pid
         title : (NSString *)title {
    if ([super init]) {
        self.pid = pid;
        self.title = title;
    }
    return self;
}

@end

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

VirgilUpdaterWindowController * windowController = nil;
SUUpdater * updater;
NSString * version;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self prepareBundleVersion];
    [self terminateOtherUpdaters];
    updater = [SUUpdater sharedUpdater];
    updater.delegate = self;
    updater.automaticallyDownloadsUpdates = YES;
    [updater checkForUpdatesInBackground];
    
    [NSTimer scheduledTimerWithTimeInterval : 300
                                     target : self
                                   selector : @selector(terminate)
                                   userInfo : nil
                                    repeats : YES];
}

- (NSArray*) windowsInfo {
    NSMutableArray * res = [NSMutableArray new];
    
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
    CFIndex i, c = CFArrayGetCount(windowList);
    
    for (i = 0; i < c; i++) {
        NSDictionary * windowInfo = (__bridge NSDictionary*)CFArrayGetValueAtIndex(windowList, i);
        NSNumber * pid = windowInfo[(id)kCGWindowOwnerPID];
        NSString * title = windowInfo[(id)kCGWindowName];
        [res addObject:[[SWindowOfProcess alloc] initPID:[pid intValue] title:title]];
    }
    CFRelease(windowList);
    
    return [res copy];
}

- (void) terminateOtherUpdaters {
    NSArray *runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
    
    NSArray * windowInfoList = [self windowsInfo];
    
    for (NSRunningApplication *app in runningApplications) {
        NSString * execURL = [[app executableURL] absoluteString];
        if ([execURL rangeOfString:@"virgil.VirgilUpdate"].location != NSNotFound) {
            [app terminate];
        }
        
        if ([[app bundleIdentifier] isEqualToString:@"com.apple.installer"]) {
            pid_t pid = [app processIdentifier];
            
            for (SWindowOfProcess * winInfo in windowInfoList) {
                if (winInfo.pid == pid) {
                    if ([winInfo.title rangeOfString:@"Virgil Security Mail"].location != NSNotFound) {
                        [app terminate];
                    }
                }
            }
        }
    }
}

- (void) prepareBundleVersion {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *app = [info objectForKey:@"CFBundleName"];
    version = [info objectForKey:@"CFBundleVersion"];
    NSLog(@"%@ : %@", app, version);
}

- (NSString *) pathToRelaunchForUpdater : (SUUpdater *)updater {
    return @"/Applications/Mail.app";
}

- (void)updaterDidNotFindUpdate:(SUUpdater *)updater {
    [self terminate];
}

- (void)updater:(SUUpdater *)updater willInstallUpdateOnQuit:(SUAppcastItem *)item immediateInstallationInvocation:(NSInvocation *)invocation {
    
    [self showWindowWithCurrentVersion : version
                         latestVersion : item.versionString];
}

- (void) showWindowWithCurrentVersion : (NSString *)currentVersion
                        latestVersion : (NSString *)latestVersion {
    if (windowController == nil) {
        windowController = [VirgilUpdaterWindowController new];
        windowController.delegate = self;
    }
    [windowController showCurrentVersion:currentVersion latestVersion:latestVersion];
    [windowController showWindow:self];
    [[windowController window] makeKeyAndOrderFront:nil];
}

- (void) terminate {
    [NSApp terminate:nil];
}

// MARK: - VirgilUpdaterProtocol

- (void) installUpdate {
    [self terminate];
}

- (void) terminateUpdate {
    SEL driverSelector = NSSelectorFromString(@"driver");
    if ([updater respondsToSelector:driverSelector]) {
        id updateDriver = [updater performSelector:driverSelector withObject:updater];
        if (updateDriver != nil) {
            SEL updateStopSelector = NSSelectorFromString(@"stopUpdatingOnTermination");
            if ([updateDriver respondsToSelector:updateStopSelector]) {
                [updateDriver performSelector:updateStopSelector withObject:updateDriver];
            }
        }
    }
    [self terminate];
}

@end
