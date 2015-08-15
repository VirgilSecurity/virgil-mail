//
//  VirgilComposeBackEnd.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 14.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilComposeBackEnd.h"
#import "VirgilProcessingManager.h"

@implementation VirgilComposeBackEnd

- (id) MA_makeMessageWithContents : (WebComposeMessageContents *)contents
                          isDraft : (BOOL)isDraft
                       shouldSign : (BOOL)shouldSign
                    shouldEncrypt : (BOOL)shouldEncrypt
              shouldSkipSignature : (BOOL)shouldSkipSignature
                shouldBePlainText : (BOOL)shouldBePlainText {
    NSLog(@"MA_makeMessageWithContents");

    VirgilProcessingManager * _vpm = [VirgilProcessingManager sharedInstance];
    BOOL _needEncryption = [_vpm isNeedToEncrypt];

    OutgoingMessage * result = [self MA_makeMessageWithContents : contents
                                                        isDraft : isDraft
                                                     shouldSign : shouldSign
                                                  shouldEncrypt : shouldEncrypt
                                            shouldSkipSignature : shouldSkipSignature
                                              shouldBePlainText : shouldBePlainText];
    
    if (NO == _needEncryption || YES == isDraft) {
        return result;
    }
    
    if (YES == [_vpm encryptMessage : contents
                             result : result]) {
        return result;
    }
    
    [_vpm inviteMessage : contents
                 result : result];
    
    return result;
}

- (BOOL) MACanEncryptForRecipients : (NSArray *)recipients
                            sender : (NSString *)sender {
    NSLog(@"MACanEncryptForRecipients");
    return [self MACanEncryptForRecipients : recipients
                                    sender : sender];
}

- (BOOL) MACanSignFromAddress : (NSString *)address {
    NSLog(@"MACanSignFromAddress");
    return [self MACanSignFromAddress : address];
}

- (id) MARecipientsThatHaveNoKeyForEncryption {
    NSLog(@"MARecipientsThatHaveNoKeyForEncryption");
    return [self MARecipientsThatHaveNoKeyForEncryption];
}

- (void) MASetEncryptIfPossible : (BOOL)encryptIfPossible {
    NSLog(@"MASetEncryptIfPossible");
    [self MASetEncryptIfPossible : encryptIfPossible];
}

- (void) MASetSignIfPossible : (BOOL)signIfPossible {
    NSLog(@"MASetSignIfPossible");
    [self MASetSignIfPossible : signIfPossible];
}

- (void) MA_configureLastDraftInformationFromHeaders : (id)headers
                                           overwrite : (BOOL)overwrite {
    NSLog(@"MA_configureLastDraftInformationFromHeaders");
    [self MA_configureLastDraftInformationFromHeaders : headers
                                            overwrite : overwrite];
}

- (id) MANewOutgoingMessageUsingWriter : (id)writer
                              contents : (id)contents
                               headers : (id)headers
                               isDraft : (BOOL)isDraft
                     shouldBePlainText : (BOOL)shouldBePlainText {
    NSLog(@"MANewOutgoingMessageUsingWriter");
    return [self MANewOutgoingMessageUsingWriter : writer
                                        contents : contents
                                         headers : headers
                                         isDraft : isDraft
                               shouldBePlainText : shouldBePlainText];
}

- (id) MASender {
    NSLog(@"MASender");
    return [self MASender];
}

- (id) MAInitCreatingDocumentEditor : (BOOL)createDocumentEditor {
    NSLog(@"MAInitCreatingDocumentEditor");
    return [self MAInitCreatingDocumentEditor : createDocumentEditor];
}

- (void) MASetKnowsCanSign : (BOOL)knowsCanSign {
    NSLog(@"MASetKnowsCanSign");
    [self MASetKnowsCanSign : knowsCanSign];
}

- (BOOL) MA_saveThreadShouldCancel {
    NSLog(@"MA_saveThreadShouldCancel");
    return [self MA_saveThreadShouldCancel];
}

@end
