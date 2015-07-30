@interface NSObject (VirgilDynamicVariables)
- (void)setDynVar:(id)key value:(id)value;
- (id)dynVar:(id)key;
- (BOOL)isExistsDynVar:(id)key;
- (void)removeAllDynVars;
@end
