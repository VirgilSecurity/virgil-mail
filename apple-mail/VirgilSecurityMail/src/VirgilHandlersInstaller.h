//
//  VirgilHandlersInstaller.h
//  VirgilSecurityMail
//
//  Created by Roman Kutashenko on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilHandlersInstaller : NSObject

+ (NSDictionary *) handlers;
+ (void) installHandlerByPrefix :(NSString *)prefix;

@end
