//
//  VirgilMessageCriterion.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Message.h>

@interface VirgilMessageCriterion : NSObject
- (BOOL)MA_evaluateIsDigitallySignedCriterion:(Message *)message;
- (BOOL)MA_evaluateIsEncryptedCriterion:(Message *)message;
@end
