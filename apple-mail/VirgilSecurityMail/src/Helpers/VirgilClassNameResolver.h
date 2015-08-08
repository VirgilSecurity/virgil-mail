//
//  VirgilClassNameResolver.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 06.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilClassNameResolver : NSObject
+ (Class)resolveClassFromName:(NSString *)name;
@end
