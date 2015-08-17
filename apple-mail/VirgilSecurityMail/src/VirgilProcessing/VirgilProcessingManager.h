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
#import <WebComposeMessageContents.h>
#import <OutgoingMessage.h>
#import "VirgilDecryptedMail.h"

@interface VirgilProcessingManager : NSObject

+ (VirgilProcessingManager *) sharedInstance;

// Encryption
- (BOOL) isNeedToEncrypt;
- (BOOL) encryptMessage : (WebComposeMessageContents *)message
            attachments : (NSArray *)attachments
                 result : (OutgoingMessage *)result;

- (BOOL) inviteMessage : (WebComposeMessageContents *)message
                 result : (OutgoingMessage *)result;

// Decryption
- (id) decryptMessagePart:(MimePart *)mimePart;
- (NSData *) decryptedAttachementByName:(NSString *) name;
- (BOOL) isNeedToDecrypt;
- (BOOL) isEncryptedByVirgil : (MimePart *)topMimePart;
- (MimePart *) topLevelPartByAnyPart:(MimePart *)part;

@property (readonly) VirgilDecryptedMail * decryptedMail;

@end
