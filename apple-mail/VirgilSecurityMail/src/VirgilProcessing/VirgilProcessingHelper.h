//
//  VirgilProcessingHelper.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 31.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Message.h>
#import <MimePart.h>
#import "VirgilEncryptorContainer.h"

@interface VirgilProcessingHelper : NSObject

+ (BOOL) isNeedToDecrypt;
+ (BOOL) isEncryptedByVirgil : (MimePart *)topMimePart;
+ (VirgilEncryptorContainer *) prepareDataForDecryptor:(Message *)message topMimePart:(MimePart *)topMimePart;

@end
