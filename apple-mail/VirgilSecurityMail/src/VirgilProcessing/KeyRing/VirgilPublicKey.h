//
//  VirgilPublicKey.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 10.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilPublicKey : NSObject {
@public
    NSString * accountID;
    NSString * publicKeyID;
    NSString * publicKey;
}

- (id) init;
- (id) initAccountID:(NSString *)a_accountID
         publicKeyID:(NSString *)a_publicKeyID
           publicKey:(NSString *)a_publicKey;

@property (retain) NSString * accountID;
@property (retain) NSString * publicKeyID;
@property (retain) NSString * publicKey;

@end