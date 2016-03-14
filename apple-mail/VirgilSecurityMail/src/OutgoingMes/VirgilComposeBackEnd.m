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

#import "VirgilComposeBackEnd.h"
#import "VirgilProcessingManager.h"
#import "VirgilLog.h"
#import <MCAttachment.h>

@implementation VirgilComposeBackEnd

- (id) VSM_makeMessageWithContents : (WebComposeMessageContents *)contents
                          isDraft : (BOOL)isDraft
                       shouldSign : (BOOL)shouldSign
                    shouldEncrypt : (BOOL)shouldEncrypt
              shouldSkipSignature : (BOOL)shouldSkipSignature
                shouldBePlainText : (BOOL)shouldBePlainText {
    VLogInfo(@"VSM_makeMessageWithContents");

    VirgilProcessingManager * _vpm = [VirgilProcessingManager sharedInstance];
    BOOL _needEncryption = [_vpm isNeedToEncrypt];
    
    OutgoingMessage * result = [self VSM_makeMessageWithContents : contents
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
    
    VLogInfo(@"Attach count : %lu", [attachments count]);
    
    if (YES == [_vpm encryptMessage : contents
                        attachments : [attachments copy]
                             result : result]) {
        return result;
    }
    
    [_vpm inviteMessage : contents
                 result : result];
    
    return nil;
}


@end
