//
//  VirgilCryptoLibWrapper.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 03.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilCryptoLibWrapper : NSObject
+ (NSData *) decryptData : (NSData *) data
         publicKeyId : (NSString *) publicKeyId
          privateKey : (NSString *) privateKey
   privateKeyPassword: (NSString *) privateKeyPassword;
@end
