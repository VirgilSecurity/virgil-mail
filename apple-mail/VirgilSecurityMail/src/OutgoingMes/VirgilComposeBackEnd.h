//
//  VirgilComposeBackEnd.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 14.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebComposeMessageContents.h>
#import <ComposeBackEnd.h>

@interface VirgilComposeBackEnd : NSObject

- (id) MA_makeMessageWithContents : (WebComposeMessageContents *)contents
                          isDraft : (BOOL)isDraft
                       shouldSign : (BOOL)shouldSign
                    shouldEncrypt : (BOOL)shouldEncrypt
              shouldSkipSignature : (BOOL)shouldSkipSignature
                shouldBePlainText : (BOOL)shouldBePlainText;

- (BOOL) MACanEncryptForRecipients : (NSArray *)recipients
                            sender : (NSString *)sender;

- (BOOL) MACanSignFromAddress : (NSString *)address;

- (id) MARecipientsThatHaveNoKeyForEncryption;
- (void) MASetEncryptIfPossible : (BOOL)encryptIfPossible;
- (void) MASetSignIfPossible : (BOOL)signIfPossible;
- (void) MA_configureLastDraftInformationFromHeaders : (id)headers
                                           overwrite : (BOOL)overwrite;
- (id) MANewOutgoingMessageUsingWriter : (id)writer
                              contents : (id)contents
                               headers : (id)headers
                               isDraft : (BOOL)isDraft
                     shouldBePlainText : (BOOL)shouldBePlainText;
- (id) MASender;
- (id) MAInitCreatingDocumentEditor : (BOOL)createDocumentEditor;
- (void) MASetKnowsCanSign : (BOOL)knowsCanSign;
- (BOOL) MA_saveThreadShouldCancel;
@end

@interface VirgilComposeBackEnd (NativeComposeBackEndMethods)
- (BOOL) containsAttachments;
- (id) attachments;
@end

