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

#import "VirgilMessageViewController.h"
#import "VirgilProcessingManager.h"
#import "VirgilDynamicVariables.h"
#import "VirgilLog.h"

#import <BannerContainerViewController.h>
#import <ConversationMember.h>
#import <Message.h>
#import <MimeBody.h>

#import "MessageViewController.h"

@implementation VirgilMessageViewController

- (void)MASetRepresentedObject:(id)representedObject {
    [self MASetRepresentedObject:representedObject];
    
    [representedObject removeAllDynVars];
    
    Message * message = (Message *)(((ConversationMember *)representedObject).originalMessage);
    
    NSString * myAccount = [[VirgilProcessingManager sharedInstance] getMyAccountFromMessage:message];
    BOOL accountNeedsConfirmation = [[VirgilProcessingManager sharedInstance] accountNeedsConfirmation:myAccount];
    BOOL accountNeedsPrivateKey = [[VirgilProcessingManager sharedInstance] accountNeedsPrivateKey:myAccount];
    BOOL accountNeedsDeletion = [[VirgilProcessingManager sharedInstance] accountNeedsDeletion:myAccount];
    if (accountNeedsConfirmation || accountNeedsPrivateKey || accountNeedsDeletion) {
        NSString * confirmationCode = [[VirgilProcessingManager sharedInstance] confirmationCodeFromEmail:message];
        if (nil != confirmationCode) {
            [self needShowConfirmationAccept:myAccount code:confirmationCode object:representedObject];
        }
    }
}

- (void) needShowConfirmationAccept : (NSString *) account
                               code : (NSString *) code
                             object : (id) object {
    [object setDynVar:@"IsConfirmationEmail" value:[NSNumber numberWithBool:YES]];
    [object setDynVar:@"ConfirmationCode" value:code];
    [object setDynVar:@"ConfirmationAccount" value:account];
    [self showBanner];
}

- (void) showBanner {
    BannerContainerViewController * bannerController = [self valueForKey:@"bannerViewController"];
    [bannerController updateBannerDisplay];
}

@end
