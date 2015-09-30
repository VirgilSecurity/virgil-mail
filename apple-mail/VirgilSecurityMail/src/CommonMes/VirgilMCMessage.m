//
//  VirgilMCMessage.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 9/28/15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMCMessage.h"
#import "VirgilLog.h"

@implementation VirgilMCMessage

- (void)MASetDateLastViewedTimeIntervalSince1970:(double)arg1; {
    [self MASetDateLastViewedTimeIntervalSince1970:arg1];
    VLogInfo(@">>>>>>>>>>>>>>>>>>> MASetDateLastViewedTimeIntervalSince1970");
}

- (void)MASetMessageInfo:(id)info subjectPrefixLength:(unsigned char)subjectPrefixLength to:(id)to sender:(id)sender type:(BOOL)type dateReceivedTimeIntervalSince1970:(double)receivedDate dateSentTimeIntervalSince1970:(double)sentDate messageIDHeaderDigest:(id)messageIDHeaderDigest inReplyToHeaderDigest:(id)headerDigest dateLastViewedTimeIntervalSince1970:(double)lastViewedDate {
    
    
     VLogInfo(@">>>>>>>>>>>>>>>>>>> MASetMessageInfo");
    
    [self MASetMessageInfo:info subjectPrefixLength:subjectPrefixLength to:to sender:sender type:type dateReceivedTimeIntervalSince1970:receivedDate dateSentTimeIntervalSince1970:sentDate messageIDHeaderDigest:messageIDHeaderDigest inReplyToHeaderDigest:headerDigest dateLastViewedTimeIntervalSince1970:lastViewedDate];
}

@end
