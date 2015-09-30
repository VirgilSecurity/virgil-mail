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

#import "VirgilMimePart.h"
#import "VirgilProcessingManager.h"
#import <MimeBody.h>
#import "VirgilClassNameResolver.h"
#import "VirgilLog.h"

#import "ParsedMessage.h"
#import "MCAttachment.h"

@implementation VirgilMimePart

- (id)MADecodeWithContext:(id)ctx {    
    id decryptedPart = nil;
    id nativePart = [self MADecodeWithContext:ctx];
    
#if 0
    if (YES == [[VirgilProcessingManager sharedInstance]
                checkConfirmationEmail: (MimePart *)self]) {
        return nativePart;
    }
#endif
    
    NSString *className = NSStringFromClass([nativePart class]);
    if ([className isEqualToString:@"MCParsedMessage"]) {
        
        // Iterate throw all attachements and decrypt
        
        NSMutableDictionary * attachments = [((ParsedMessage *)nativePart).attachmentsByURL mutableCopy];
        NSMutableSet * forDelete = [[NSMutableSet alloc] init];
        
        for (NSString * key in [attachments allKeys]) {
            MCAttachment * attach = [attachments objectForKey : key];
            
            if ([attach.filename isEqualToString : VIRGIL_MAIL_INFO_ATTACH] ||
                [attach.filename isEqualToString : WIN_MAIL_DATA_ATTACH]) {
                [forDelete addObject : key];
                continue;
            }
            
            NSData * decryptedAttach = [[VirgilProcessingManager sharedInstance]
                                                      decryptedAttachementByName:attach.filename];
            if (nil != decryptedAttach) {
                attach.currentData = decryptedAttach;
            }
        }
        
        // Remove helper attachments
        for (NSString * key in forDelete) {
            [attachments removeObjectForKey : key];
        }

        ((ParsedMessage *)nativePart).attachmentsByURL = [attachments copy];
        
        decryptedPart = nativePart;
        
    } else {
        decryptedPart = [[VirgilProcessingManager sharedInstance]
                         decryptMessagePart:(MimePart *)self];
    }
    
    return (nil != decryptedPart) ?
            decryptedPart :
            nativePart;
}

- (id)MADecodeTextPlainWithContext:(MFMimeDecodeContext *)ctx {
    id decryptedPart =
            [[VirgilProcessingManager sharedInstance] decryptMessagePart:(MimePart *)self];
    
    return (nil != decryptedPart) ?
            decryptedPart :
            [self MADecodeTextPlainWithContext:ctx];
}

- (id)MADecodeTextHtmlWithContext:(MFMimeDecodeContext *)ctx {
    id decryptedPart =
                [[VirgilProcessingManager sharedInstance] decryptMessagePart:(MimePart *)self];
    
    return (nil != decryptedPart) ?
                    decryptedPart :
                    [self MADecodeTextHtmlWithContext:ctx];
}

- (id)MADecodeApplicationOctet_streamWithContext:(MFMimeDecodeContext *)ctx {
    return [self MADecodeApplicationOctet_streamWithContext:ctx];
}

- (void)MAClearCachedDecryptedMessageBody {
    VLogInfo(@"MAClearCachedDecryptedMessageBody");
    return [self MAClearCachedDecryptedMessageBody];
}

- (BOOL)MAHasCachedDataInStore {
    //if (YES == [[VirgilProcessingManager sharedInstance] isEncryptedByVirgilByAnyPart:(MimePart *)self]) {
    //    return NO;
    //}
    return [self MAHasCachedDataInStore];
}

@end
