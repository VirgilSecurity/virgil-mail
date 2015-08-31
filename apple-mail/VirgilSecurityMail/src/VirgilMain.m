#import "VirgilMain.h"
#import "VirgilHandlersInstaller.h"
#import "VirgilProcessingManager.h"

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
        NSLog(@"Mail.app doesn't support bundles anymore. Exit.");
        return;
    }
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    class_setSuperclass([self class], mvMailBundleClass);
#pragma GCC diagnostic pop

    VirgilMain * instance = [VirgilMain sharedInstance];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[VirgilProcessingManager sharedInstance] getAllPrivateKeys];
    });
    
    // Registering plugin in Mail.app
    [[((VirgilMain *)self) class] registerBundle];
}

- (id)init {
	if (self = [super init]) {
		NSLog(@"Virgil Security Mail Plugin successfully Loaded");

        // Install handlers
        [VirgilHandlersInstaller installHandlerByPrefix:VirgilMailMethodPrefix];
	}
    
	return self;
}

- (void)dealloc {
}


@end
