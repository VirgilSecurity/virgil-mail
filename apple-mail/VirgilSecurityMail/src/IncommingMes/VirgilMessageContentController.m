//
//  VirgilMessageContentController.m
//  VirgilSecurityMail
//
//  Created by Roman Kutashenko on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMessageContentController.h"
#import "VirgilDynamicVariables.h"

@implementation VirgilMessageContentController

- (void)MASetMessageToDisplay:(id)message {
    [message setDynVar:@"UserSelectedMessage" value:@YES];
    [self MASetMessageToDisplay:message];
    NSLog(@"Message have been selected by user");
}

// MessageContentController was renamed to MessageViewController in Mavericks.
// The following methods only apply to Mavericks.

- (void)MASetRepresentedObject:(id)representedObject {
    // Reset the details hidden value, if a previous PGP processed message
    // forced the details to be shown.
    if([self dynVar:@"RealDetailsHidden"])
        [self setValue:[self dynVar:@"RealDetailsHidden"] forKey:@"_detailsHidden"];
    
    if([self dynVar:@"RealShowDetails"])
        [self setValue:[self dynVar:@"RealShowDetails"] forKey:@"_showDetails"];
    
    //[[representedObject originalMessage] setDynVar:@"UserSelectedMessage" value:[NSNumber numberWithBool:YES]];
    //[[representedObject originalMessage] setDynVar:@"LoadingStage" value:[NSNumber numberWithBool:YES]];
    [self MASetRepresentedObject:representedObject];
    NSLog(@"Message have been selected by user");
}

@end
