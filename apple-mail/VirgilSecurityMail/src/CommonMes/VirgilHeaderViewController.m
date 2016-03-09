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

#import "VirgilHeaderViewController.h"
#import "VirgilProcessingManager.h"
#import "VirgilImageProcessing.h"
#import "VirgilLog.h"

#import <HeaderViewController.h>
#import <MessageViewingState.h>
#import <Message.h>
#import <MimeBody.h>
#import <MessageViewer.h>

#import <MessageViewer.h>

#import <MessageViewingPaneController.h>
#import <ConversationMember.h>
#import <MCMessageBody.h>
#import <MCMessage.h>
#import <MCMimeBody.h>
#import <MCMimePart.h>


#define LogSize(SIZE) NSLog(@"%s: %0.0f x %0.0f", #SIZE, SIZE.width, SIZE.height)

@implementation VirgilHeaderViewController

- (void)VSM_updateTextStorageWithHardInvalidation:(BOOL)hardValidation {
    [self VSM_updateTextStorageWithHardInvalidation : hardValidation];
    
    MCMessage * message = [(ConversationMember *)[(HeaderViewController *)self representedObject] originalMessage];
    MCMimeBody * mimeBody = [message messageBody];
    
    if (NO == [[VirgilProcessingManager sharedInstance] isEncryptedByVirgilByAnyPart:[mimeBody topLevelPart]]) {
        return;
    }
    
    const DecryptStatus decryptStatus = [[VirgilProcessingManager sharedInstance] getDecriptionStatusForMessage:(Message *)message];
    [self applyVirgilStatus:decryptStatus];
    
    if (decryptUnknown == decryptStatus) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                           [[VirgilProcessingManager sharedInstance] decryptMessagePart:[mimeBody topLevelPart]];
                           const DecryptStatus decryptStatus = [[VirgilProcessingManager sharedInstance] getDecriptionStatusForMessage:(Message *)message];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [self applyVirgilStatus:decryptStatus];
                           });
                       });
    }
}

- (void) applyVirgilStatus : (DecryptStatus) status {
    NSString * statusImageName = @"encrypt_unknown_small";
    if (decryptOk == status) statusImageName =  @"encrypt_ok_small";
    if (decryptError == status) statusImageName =  @"encrypt_error_small";
    
    NSImageView * imageView = [self valueForKey:@"_senderImageView"];
    NSImage * virgilImage = [VirgilImageProcessing imageWithStatusPicture : imageView.image
                                                         statusImageName : statusImageName
                                                                 minWidth : 70
                                                                 minHeight : 70];
    [imageView setImage : virgilImage];
}

@end
