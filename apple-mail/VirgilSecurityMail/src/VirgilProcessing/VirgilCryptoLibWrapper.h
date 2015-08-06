//
//  VirgilCryptoLibWrapper.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 03.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VirgilEncryptorContainer.h"

@interface VirgilCryptoLibWrapper : NSObject
+ (BOOL) decryptContainer:(VirgilEncryptorContainer **) container;
@end
