//
//  VirgilMimeBody.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 30.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilMimeBody : NSObject
- (BOOL)MAIsSignedByMe;
- (BOOL)MA_isPossiblySignedOrEncrypted;
@end

@interface VirgilMimeBody (NativeMimeBodyMethods)
- (id) message;
- (NSData *)bodyData;
- (id) topLevelPart;
@end