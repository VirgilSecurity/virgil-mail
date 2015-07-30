#import "VirgilMain.h"
#import "VirgilHandlersInstaller.h"

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
