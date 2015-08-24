//
//  VirgilPrivateKeyEndpoints.h
//  TestGUI
//
//  Created by Роман Куташенко on 24.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilPrivateKeyEndpoints : NSObject

- (id) initWithBaseURL : (NSString *)a_baseURL;
- (NSString *) getToken;
- (NSString *) getPrivateKeyByPublicID : (NSString *) publicKeyID;
- (NSString *) getKeyPush;

@property (retain, readonly) NSString * baseURL;

@end
