//
//  VirgilProcessingManager.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 31.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Message.h>
#import <MimePart.h>
#import "VirgilDecryptedMail.h"

@interface VirgilProcessingManager : NSObject

+ (VirgilProcessingManager *) sharedInstance;

- (id) decryptMessagePart:(MimePart *)mimePart;
- (BOOL) isNeedToDecrypt;
- (BOOL) isEncryptedByVirgil : (MimePart *)topMimePart;
- (MimePart *) topLevelPartByAnyPart:(MimePart *)part;

@property (readonly) VirgilDecryptedMail * decryptedMail;

@end
