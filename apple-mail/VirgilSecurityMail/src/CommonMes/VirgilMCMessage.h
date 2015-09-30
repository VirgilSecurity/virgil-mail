//
//  VirgilMCMessage.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 9/28/15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilMCMessage : NSObject
- (void)MASetMessageInfo:(id)info subjectPrefixLength:(unsigned char)subjectPrefixLength to:(id)to sender:(id)sender type:(BOOL)type dateReceivedTimeIntervalSince1970:(double)receivedDate dateSentTimeIntervalSince1970:(double)sentDate messageIDHeaderDigest:(id)messageIDHeaderDigest inReplyToHeaderDigest:(id)headerDigest dateLastViewedTimeIntervalSince1970:(double)lastViewedDate;
@end
