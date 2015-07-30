//
//  VirgilHandlersInstaller.m
//  VirgilSecurityMail
//
//  Created by Roman Kutashenko on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilHandlersInstaller.h"
#import "JRLPSwizzle.h"
#import "VirgilSecurityMail-Prefix.pch"

@implementation VirgilHandlersInstaller

+ (NSDictionary *) commonHandlers {
	return @{
             @"MessageContentController": @[
					 @"setMessageToDisplay:"
                     ],
             @"MimeBody": @[
					 @"isSignedByMe",
					 @"_isPossiblySignedOrEncrypted"
                     ],
             @"MessageCriterion": @[
					 @"_evaluateIsDigitallySignedCriterion:",
					 @"_evaluateIsEncryptedCriterion:"
                     ]
             };
}

+ (NSDictionary *)handlerChangesForMavericks {
	return @{
             @"MessageContentController": @{
                     @"status": @"renamed",
                     @"name": @"MessageViewController",
                     @"selectors": @{
                             @"replaced": @[
                                     @[
                                         @"setMessageToDisplay:",
                                         @"setRepresentedObject:"
                                         ]
                                     ]
                             }
                     },
             @"MimeBody": @{
					 @"status": @"renamed",
					 @"name": @"MCMimeBody"
                     },
             @"MessageCriterion": @{
					 @"status": @"renamed",
					 @"name": @"MFMessageCriterion"
                     },
             };
}

+ (NSDictionary *)handlerChangesForYosemite {
    return @{};
}


+ (NSDictionary *) handlers {
	static NSDictionary *_handlers;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
		NSMutableDictionary *handlers = [[NSMutableDictionary alloc] init];
		NSDictionary *commonHandlers = [self commonHandlers];
		
		// Make a mutable version of all the dictionary.
		for(NSString *class in commonHandlers)
			handlers[class] = [NSMutableArray arrayWithArray:commonHandlers[class]];
		
		/* Fix, once we can compile with stable Xcode including 10.9 SDK. */
		if(floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8)
			[self applyHandlerChangesForVersion:@"10.9" toHandlers:handlers];
        
		if(floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
            [self applyHandlerChangesForVersion:@"10.10" toHandlers:handlers];
        
		_handlers = [NSDictionary dictionaryWithDictionary:handlers];
	});
	
	return _handlers;
}

+ (void)applyHandlerChangesForVersion:(NSString *)osxVersion toHandlers:(NSMutableDictionary *)handlers {
	NSDictionary *handlerChanges;
	if([osxVersion isEqualToString:@"10.9"])
		handlerChanges = [self handlerChangesForMavericks];
	else if([osxVersion isEqualToString:@"10.10"])
        handlerChanges = [self handlerChangesForYosemite];
    
	for(NSString *class in handlerChanges) {
		NSDictionary *handler = handlerChanges[class];
		
		// Class was added.
		if(!handlers[class]) {
			handlers[class] = handler[@"selectors"];
			continue;
		}
		// Class was removed.
		if([handler[@"status"] isEqualToString:@"removed"]) {
			[handlers removeObjectForKey:class];
			continue;
		}
		// Selectors were updated
		if(handler[@"selectors"]) {
			for(NSString *action in handler[@"selectors"]) {
				for(id selector in handler[@"selectors"][action]) {
					if([action isEqualToString:@"added"])
						[(NSMutableArray *)handlers[class] addObject:selector];
					else if([action isEqualToString:@"removed"])
						[(NSMutableArray *)handlers[class] removeObject:selector];
					else if([action isEqualToString:@"replaced"]) {
						[(NSMutableArray *)handlers[class] removeObject:selector[0]];
						[(NSMutableArray *)handlers[class] addObject:selector[1]];
					}
                    else if([action isEqualToString:@"renamed"]) {
                        [(NSMutableArray *)handlers[class] removeObject:selector[0]];
                        [(NSMutableArray *)handlers[class] addObject:selector];
                    }
				}
			}
		}
		
		// Class was renamed.
		if([handler[@"status"] isEqualToString:@"renamed"]) {
			handlers[handler[@"name"]] = handlers[class];
			[handlers removeObjectForKey:class];
		}
	}
}

+ (NSString *)legacyClassNameForName:(NSString *)className {
    // Some classes have been renamed in Mavericks.
    // This methods converts known classes to their counterparts in Mavericks.
    if([@[@"MC", @"MF"] containsObject:[className substringToIndex:2]])
        return [className substringFromIndex:2];
    
    if([className isEqualToString:@"DocumentEditor"])
        return @"MailDocumentEditor";
    
    if([className isEqualToString:@"MessageViewController"])
        return @"MessageContentController";
    
    if([className isEqualToString:@"HeaderViewController"])
        return @"MessageHeaderDisplay";
    
    return className;
}

+ (void)installHandlerByPrefix:(NSString *)prefix {
	NSDictionary *handlers = [self handlers];
    NSString *ourClassPrefix = @"Virgil";
	
	NSError * __autoreleasing error = nil;
    for(NSString *class in handlers) {
        error = nil;
        
		Class mailClass = NSClassFromString(class);
        if(!mailClass) {
            NSLog(@"Virgil Security Mail Plugin can't install all need handlers. Absent class is %@.", class);
			continue;
		}
		
        NSString *oldClass = [[self class] legacyClassNameForName:class];
        NSArray *selectors = handlers[class];
		
        // Create names for our hander classes. "Virgil" + real Apple Mail class
        NSString * ourClassName = [ourClassPrefix stringByAppendingString:oldClass];
		Class ourClass = NSClassFromString(ourClassName);
		BOOL extend = ourClass != nil ? YES : NO;
		if(extend) {
			if(![mailClass jrlp_addMethodsFromClass:ourClass error:&error]) {
                NSLog(@"Virgil Security Mail Plugin can't install all need handlers. Methods of %@ couldn't be added to %@.", ourClass, mailClass);
            }
		}
		
		for(id selectorNames in selectors) {
            error = nil;
            
            NSString *virgilSelectorName = [selectorNames isKindOfClass:[NSArray class]] ? selectorNames[0] : selectorNames;
			NSString *mailSelectorName = [selectorNames isKindOfClass:[NSArray class]] ? selectorNames[1] : selectorNames;
			NSString *extensionSelectorName = [NSString stringWithFormat:@"%@%@%@", prefix, [[virgilSelectorName substringToIndex:1] uppercaseString],
											   [virgilSelectorName substringFromIndex:1]];
			SEL selector = NSSelectorFromString(mailSelectorName);
			SEL extensionSelector = NSSelectorFromString(extensionSelectorName);
            
			if(![mailClass jrlp_swizzleMethod:selector withMethod:extensionSelector error:&error]) {
                // If that didn't work, try to add as class method.
                if(![mailClass jrlp_swizzleClassMethod:selector withClassMethod:extensionSelector error:&error])
                    NSLog(@"WARNING: %@ doesn't respond to selector %@ - %@", NSStringFromClass(mailClass),
						  NSStringFromSelector(selector), error);
            }
		}
	}
}

@end


