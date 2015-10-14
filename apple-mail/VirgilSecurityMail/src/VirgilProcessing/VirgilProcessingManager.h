/**
 * Copyright (C) 2015 Virgil Security Inc.
 *
 * Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     (1) Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *     (2) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *     (3) Neither the name of the copyright holder nor the names of its
 *     contributors may be used to endorse or promote products derived from
 *     this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import <Message.h>
#import <MimePart.h>
#import <WebComposeMessageContents.h>
#import <OutgoingMessage.h>
#import "VirgilDecryptedMailContainer.h"
#import "VirgilAccountInfo.h"

#define VIRGIL_MAIL_INFO_ATTACH @"virgilsecurity.mailinfo"
#define WIN_MAIL_DATA_ATTACH @"winmail.dat"

@interface VirgilProcessingManager : NSObject

+ (VirgilProcessingManager *) sharedInstance;

+ (NSArray *) accountsList;

// Encryption
- (BOOL) isNeedToEncrypt;
- (BOOL) encryptMessage : (WebComposeMessageContents *)message
            attachments : (NSArray *)attachments
                 result : (OutgoingMessage *)result;

- (BOOL) inviteMessage : (WebComposeMessageContents *)message
                 result : (OutgoingMessage *)result;

// Decryption
- (id) decryptMessagePart:(MimePart *)mimePart;
- (NSData *) decryptedAttachementByName : (NSString *) name
                               forEmail : (id)message;
- (BOOL) isEncryptedByVirgil : (MimePart *)topMimePart;
- (BOOL) isEncryptedByVirgilByAnyPart : (MimePart *)mimePart;
- (MimePart *) topLevelPartByAnyPart:(MimePart *)part;
- (DecryptStatus) getDecriptionStatusForMessage : (Message *)message;

// Helper work with keys
- (NSString *) confirmationCodeFromEmail : (Message *) message;
- (BOOL) accountNeedsConfirmation : (NSString *)account;
- (NSString *) getMyAccountFromMessage : (Message *)message;

- (VirgilAccountInfo *) accountInfo : (NSString *)account
                       checkInCloud : (BOOL)checkInCloud;

- (void) checkAccountForEncryption : (NSString *) account;


@property (readonly, retain) VirgilDecryptedMailContainer * decryptedMailContainer;

@end
