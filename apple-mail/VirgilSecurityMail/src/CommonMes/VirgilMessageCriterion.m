//
//  VirgilMessageCriterion.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMessageCriterion.h"

@implementation VirgilMessageCriterion
- (BOOL)MA_evaluateIsDigitallySignedCriterion:(Message *)message {
    BOOL ret = [self MA_evaluateIsDigitallySignedCriterion:message] /*|| ((VirgilMessage *)message).isSigned*/;
    NSLog(@"MA_evaluateIsDigitallySignedCriterion = %hhd", ret);
    return ret;
}

- (BOOL)MA_evaluateIsEncryptedCriterion:(Message *)message {
    BOOL ret = [self MA_evaluateIsEncryptedCriterion:message] /*|| ((VirgilMessage *)message).isEncrypted*/;
    NSLog(@"MA_evaluateIsDigitallySignedCriterion = %hhd", ret);
    return ret;
}
@end
