//
//  VirgilMimeBody.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMimeBody.h"

@implementation VirgilMimeBody

- (BOOL)MAIsSignedByMe {
    //if([[self message] encryptedByVirgil])
    //    return [self MAIsSignedByMe];
    BOOL ret = [self MAIsSignedByMe];
    NSLog(@"MAIsSignedByMe = %hhd", ret);
    return ret;
}

- (BOOL)MA_isPossiblySignedOrEncrypted {
    BOOL ret = [self MA_isPossiblySignedOrEncrypted];
    NSLog(@"MA_isPossiblySignedOrEncrypted = %hhd", ret);
    return ret;
}

@end
