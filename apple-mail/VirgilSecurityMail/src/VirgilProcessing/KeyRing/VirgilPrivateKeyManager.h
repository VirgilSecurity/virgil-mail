//
//  VirgilPrivateKeyManager.h
//  TestGUI
//
//  Created by Роман Куташенко on 24.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirgilPrivateKey.h"

// This class will be removed after implementstion of Private Keys SDK
@interface VirgilPrivateKeyManager : NSObject

+ (VirgilPrivateKey *) getPrivateKey : (NSString *) account
                            password : (NSString *) password
                         publicKeyID : (NSString *) publicKeyID;

+ (BOOL) pushPrivateKey : (VirgilPrivateKey *) key;

@end
