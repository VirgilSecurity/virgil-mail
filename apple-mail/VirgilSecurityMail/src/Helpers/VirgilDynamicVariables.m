#import "VirgilDynamicVariables.h"
#import <objc/runtime.h>

@implementation NSObject (VirgilDynamicVariables)

- (void)setDynVar:(id)key value:(id)value {
    objc_setAssociatedObject(self,
                             (__bridge const void *)(key),
                             value,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)dynVar:(id)key {
    return objc_getAssociatedObject(self, (__bridge const void *)(key));
}

- (BOOL)isExistsDynVar:(id)key {
    return [self dynVar:key] == nil ? NO : YES;
}

- (void)removeAllDynVars {
    objc_removeAssociatedObjects(self);
}

@end
