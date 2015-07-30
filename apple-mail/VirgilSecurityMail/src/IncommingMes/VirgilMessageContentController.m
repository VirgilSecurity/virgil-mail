//
//  VirgilMessageContentController.m
//  VirgilSecurityMail
//
//  Created by Roman Kutashenko on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMessageContentController.h"
//#import "VirgilDynamicVariables.h"

@implementation VirgilMessageContentController

- (void)MASetMessageToDisplay:(id)message {
    //[message setDynVar:@"MessageIsSelectedByUser" value:@YES];
    //[self MASetMessageToDisplay:message];
    NSLog(@"Message have been selected by user");
}

@end
