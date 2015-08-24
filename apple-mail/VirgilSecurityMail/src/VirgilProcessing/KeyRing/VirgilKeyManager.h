//
//  VirgilKeyManager.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 01.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirgilPublicKey.h"
#import "VirgilPrivateKey.h"

@interface VirgilKeyManager : NSObject
+ (BOOL) createAccount : (NSString *) account
          withPassword : (NSString *) password;

+ (BOOL) confirmAccountCreationWithCode : (NSString *) code;

+ (VirgilPublicKey *) getPublicKey : (NSString *) account;

+ (VirgilPrivateKey *) getPrivateKey : (NSString *) account
                            password : (NSString *) password;

@end
