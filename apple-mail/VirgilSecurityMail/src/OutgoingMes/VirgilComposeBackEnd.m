//
//  VirgilComposeBackEnd.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 14.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilComposeBackEnd.h"
#import "VirgilProcessingManager.h"
#import <MCAttachment.h>

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
    
    // Prepare attachments array
    NSMutableArray * attachments = [[NSMutableArray alloc] init];
    @try {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            for (MCAttachment * attach in [self attachments]) {
                [attachments addObject:[attach copy]];
            }
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    NSLog(@"Attach count 2 : %lu", [attachments count]);
    
    [NSThread sleepForTimeInterval : 1.0f];
    
    if (YES == [_vpm encryptMessage : contents
                        attachments : [attachments copy]
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
