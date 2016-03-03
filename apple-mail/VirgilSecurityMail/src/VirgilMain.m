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

#import "VirgilMain.h"
#import "VirgilHandlersInstaller.h"
#import "VirgilProcessingManager.h"
#import "VirgilPreferences.h"
#import "VirgilPreferencesContainer.h"
#import "VirgilGui.h"
#import "VirgilLog.h"
#import "VirgilVersion.h"

NSString *VirgilMailMethodPrefix = @"MA";

@interface VirgilMain (VirgilNoImplementation)
+ (void)registerBundle;
@end

@implementation VirgilMain

+ (void)initialize {
    if(self != [VirgilMain class])
        return;
    
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    /// If this class is not available that means Mail.app
    /// doesn't allow bundles anymore.
    
    if (!mvMailBundleClass) {
        VLogFatal(@"Mail.app doesn't support bundles anymore. Exit.");
        return;
    }
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    class_setSuperclass([self class], mvMailBundleClass);
#pragma GCC diagnostic pop

    VirgilMain * instance = [VirgilMain sharedInstance];
#pragma unused(instance)

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                       if ([VirgilPreferencesContainer isNeedShowWellcome]) {
                           [VirgilGui showWellcome];
                       }
    });
    
    // Registering plugin in Mail.app
    [[((VirgilMain *)self) class] registerBundle];
}

- (id)init {
	if (self = [super init]) {
		VLogInfo(@"Virgil Security Mail Plugin %@ successfully Loaded", [[VirgilVersion sharedInstance] currentVersion]);

        // Install handlers
        [VirgilHandlersInstaller installHandlerByPrefix:VirgilMailMethodPrefix];
	}
    [self _loadImages];
    
	return self;
}

+ (BOOL)isElCapitan {
    NSProcessInfo *info = [NSProcessInfo processInfo];
    if(![info respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)])
        return NO;
    
    NSOperatingSystemVersion requiredVersion = {10,11,0};
    return [info isOperatingSystemAtLeastVersion:requiredVersion];
}

+ (BOOL)hasPreferencesPanel {
    return YES;
}

+ (NSString *)preferencesOwnerClassName {
    return NSStringFromClass([VirgilPreferences class]);
}

+ (NSString *)preferencesPanelName {
    return @"Virgil";
}

- (void)_loadImages {
    NSBundle *myBundle = [NSBundle bundleForClass:[VirgilMain class]];
    
    NSArray *bundleImageNames = @[@"encrypt_mail",
                                  @"menu",
                                  @"square",
                                  @"rect",
                                  @"encrypt_ok_small",
                                  @"encrypt_unknown_small",
                                  @"encrypt_wrong_small",
                                  @"account",
                                  @"in_progress",
                                  @"ok",
                                  @"attention",
                                  @"problem",
                                  @"virgil_logo"];
    NSMutableArray *bundleImages = [[NSMutableArray alloc] initWithCapacity:[bundleImageNames count]];
    
    for (NSString *name in bundleImageNames) {
        NSImage *image = [[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:name]];
        
        // Shoud an image not exist, log a warning, but don't crash because of inserting
        // nil!
        if(!image) {
            NSLog(@"GPGMail: Image %@ not found in bundle resources.", name);
            continue;
        }
        [image setName:name];
        [bundleImages addObject:image];
    }
    
    _bundleImages = bundleImages;
    
}

@end
