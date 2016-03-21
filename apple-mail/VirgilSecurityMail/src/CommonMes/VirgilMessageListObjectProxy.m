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

#import "VirgilMessageListObjectProxy.h"
#import "VirgilProcessingManager.h"
#import "VirgilImageProcessing.h"
#import "VirgilLog.h"

#import <MessageListObjectProxy.h>
#import <MCMessage.h>
#import <MCMimeBody.h>

static BOOL _virgilShowPhotos = NO;

@implementation VirgilMessageListObjectProxy

- (void)VSM_updateSnippet {
    [self VSM_updateSnippet];
    MCMimeBody * mimeBody = [((MFMessageThread *)((MessageListObjectProxy *)self).message).newestMessage messageBody];
    if (YES == [[VirgilProcessingManager sharedInstance] isEncryptedByVirgil:[mimeBody topLevelPart]]) {
        NSString * virgilSnippet = @"Encrypted by Virgil";
        [self setValue:virgilSnippet forKey:@"snippet"];
        [self setValue:virgilSnippet forKey:@"snippetString"];
    }
}

- (void)VSM_updatePhoto {
    [self VSM_updatePhoto];
    @try {
        [self highlightVirgil];
    }
    @catch (NSException *exception) {}
}

- (void) highlightVirgil {
    @try {
        MCMimeBody * mimeBody = [((MFMessageThread *)((MessageListObjectProxy *)self).message).newestMessage messageBody];
        if (YES == [[VirgilProcessingManager sharedInstance] isEncryptedByVirgil:[mimeBody topLevelPart]]) {
            NSImage * virgilImage;
            if (YES == _virgilShowPhotos) {
                virgilImage = [VirgilImageProcessing imageWithStatusPicture : ((MessageListObjectProxy *)self).photo
                                                            statusImageName : @"encrypt_ok_small"
                                                                   minWidth : 70
                                                                  minHeight : 48];
            } else {
                ((MessageListObjectProxy *)self).showContactPhotos = YES;
                virgilImage = [NSImage imageNamed:@"encrypt_mail_small"];
            }
            
            [self setValue:virgilImage forKey:@"selectedPhoto"];
            [self setValue:virgilImage forKey:@"unselectedPhoto"];
        }
    }
    @catch (NSException *exception) {}
}

- (void)VSM_updateContactPhotoVisibilityFromDefaults {
    [self VSM_updateContactPhotoVisibilityFromDefaults];
    _virgilShowPhotos = ((MessageListObjectProxy *)self).showContactPhotos;
    [self VSM_updatePhoto];
    //[self highlightVirgil];
}

@end
