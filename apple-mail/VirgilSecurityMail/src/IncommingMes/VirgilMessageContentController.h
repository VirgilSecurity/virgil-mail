//
//  VirgilMessageContentController.h
//  VirgilSecurityMail
//
//  Created by Roman Kutashenko on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilMessageContentController : NSObject

 // Invoked by Mail.app if the user selects a message (not automaticaly selected).
- (void)MASetMessageToDisplay:(id)message;

@end
