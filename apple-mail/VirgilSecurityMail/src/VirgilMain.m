#import "VirgilMain.h"

@interface VirgilMain (VirgilNoImplementation)
+ (void)registerBundle;
@end

@implementation VirgilMain

+ (void)initialize {
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    /// If this class is not available that means Mail.app
    /// doesn't allow bundles anymore.
    
    if (!mvMailBundleClass) {
        NSLog(@"Mail.app doesn't support bundles anymore. Exit.");
        return;
    }
    
    // Registering plugin in Mail.app
    [mvMailBundleClass registerBundle];
    
    NSLog(@"Virgil Security Mail Plugin successfully Loaded");
}

@end
