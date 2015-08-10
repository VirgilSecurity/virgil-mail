//
//  VirgilPKIManager.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 01.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirgilPublicKey.h"

@interface VirgilPKIManager : NSObject
+ (VirgilPublicKey *) getPublicKey:(NSString *) account;
@end
