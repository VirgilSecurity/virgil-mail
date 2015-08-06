//
//  VirgilEncryptorContainer.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 01.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilEncryptorContainer : NSObject {
@public
    BOOL isEncrypted;
    NSString * sender;
    NSArray * receivers;
    NSData * content;
    NSDictionary * attachements;
    // TODO: Need documentation here.
    // Content depends on encryptor work direction.
    NSString * privateKey;
    NSString * publicKeyID;
}

@property    BOOL isEncrypted;
@property (retain) NSString * sender;
@property (retain) NSString * receiver;
@property (retain) NSString * content;
@property (retain) NSString * attachements;
@property (retain) NSString * privateKey;
@property (retain) NSString * publicKeyID;

@end
