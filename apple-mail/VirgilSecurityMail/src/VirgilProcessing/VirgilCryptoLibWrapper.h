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
      privateKeyPassword : (NSString *) privateKeyPassword;

+ (BOOL) isSignatureCorrect : (NSData *) signature
                       data : (NSData *) data
                  publicKey : (NSString *) publicKey;

+ (NSData *) encryptData : (NSData *) data
              publicKeys : (NSArray *) publicKeys;

+ (NSData *) signatureForData : (NSData *) data
               withPrivateKey : (NSString *) privateKey
            privatKeyPassword : (NSString *) privateKeyPassword;

@end
