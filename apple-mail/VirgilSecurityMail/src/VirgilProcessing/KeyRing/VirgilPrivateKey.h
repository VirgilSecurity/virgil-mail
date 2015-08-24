//
//  VirgilPrivateKey.h
//  TestGUI
//
//  Created by Роман Куташенко on 24.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilPrivateKey : NSObject {
@public
NSString * account;
NSString * password;
NSString * key;
}

- (id) init;
- (id) initAccount : (NSString *)a_account
          password : (NSString *)a_password
        privateKey : (NSString *)a_key;

@property (retain) NSString * account;
@property (retain) NSString * password;
@property (retain) NSString * key;
@end
