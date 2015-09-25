//
//  VirgilMessageContentController.m
//  VirgilSecurityMail
//
//  Created by Roman Kutashenko on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMessageContentController.h"
#import "VirgilLog.h"

@implementation VirgilMessageContentController

- (void)MASetMessageToDisplay:(id)message {
    [self MASetMessageToDisplay:message];
    VLogInfo(@"Message have been selected by user");
}

- (void)MASetRepresentedObject:(id)representedObject {
    [self MASetRepresentedObject:representedObject];
    VLogInfo(@"Message have been selected by user");
}

@end
