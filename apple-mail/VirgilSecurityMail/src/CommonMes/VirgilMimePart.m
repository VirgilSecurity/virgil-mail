//
//  VirgilMimePart.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 31.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMimePart.h"
#import "VirgilProcessingManager.h"
#import <MimeBody.h>
#import "VirgilClassNameResolver.h"

#import "ParsedMessage.h"
#import "MCAttachment.h"

@implementation VirgilMimePart

- (BOOL)MAUsesKnownSignatureProtocol {
    NSLog(@"MAUsesKnownSignatureProtocol");
    //return YES;
    return [self MAUsesKnownSignatureProtocol];
}

- (id)MADecodeWithContext:(id)ctx {
    NSLog(@"MADecodeWithContext");
    
    id decryptedPart = nil;
    
    id nativePart = [self MADecodeWithContext:ctx];
    NSString *className = NSStringFromClass([nativePart class]);
    if ([className isEqualToString:@"MCParsedMessage"]) {
        
        // Iterate throw all attachements and decrypt
        for (MCAttachment * attach in [((ParsedMessage *)nativePart).attachmentsByURL allValues]) {
            // TODO: Check for need to decrypt by attach.originalData
            NSData * decryptedAttach = [[VirgilProcessingManager sharedInstance]
                                                      decryptedAttachementByName:attach.filename];
            if (nil != decryptedAttach) {
                attach.currentData = decryptedAttach;
            }
        }
        
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
    NSLog(@"MADecodeTextPlainWithContext");
    id decryptedPart =
            [[VirgilProcessingManager sharedInstance] decryptMessagePart:(MimePart *)self];
    
    return (nil != decryptedPart) ?
            decryptedPart :
            [self MADecodeTextPlainWithContext:ctx];
}

- (id)MADecodeTextHtmlWithContext:(MFMimeDecodeContext *)ctx {
    NSLog(@"MADecodeTextHtmlWithContext");
    id decryptedPart =
                [[VirgilProcessingManager sharedInstance] decryptMessagePart:(MimePart *)self];
    
    return (nil != decryptedPart) ?
                    decryptedPart :
                    [self MADecodeTextHtmlWithContext:ctx];
}

- (id)MADecodeApplicationOctet_streamWithContext:(MFMimeDecodeContext *)ctx {
    NSLog(@"MADecodeApplicationOctet_streamWithContext");
    return [self MADecodeApplicationOctet_streamWithContext:ctx];
}

- (void)MAVerifySignature {
    NSLog(@"MAVerifySignature");
    return [self MAVerifySignature];
}

- (BOOL)MAIsEncrypted {
    NSLog(@"MAIsEncrypted");
    return [self MAIsEncrypted];
}

- (BOOL)MAIsMimeEncrypted {
    NSLog(@"MAIsMimeEncrypted");
    return [self MAIsMimeEncrypted];
}

- (BOOL)MAIsSigned {
    NSLog(@"MAIsSigned");
    return [self MAIsSigned];
}

- (BOOL)MAIsMimeSigned {
    NSLog(@"MAIsMimeSigned");
    return [self MAIsMimeSigned];
}

- (id)MANewEncryptedPartWithData:(NSData *)data recipients:(id)recipients encryptedData:(NSData **)encryptedData NS_RETURNS_RETAINED {
    NSLog(@"MANewEncryptedPartWithData");
    return [self MANewEncryptedPartWithData:data recipients:recipients encryptedData:encryptedData];
}

- (id)MANewSignedPartWithData:(id)data sender:(id)sender signatureData:(id *)signatureData NS_RETURNS_RETAINED {
    NSLog(@"MANewSignedPartWithData");
    return [self MANewSignedPartWithData:data sender:sender signatureData:signatureData];
}

- (void)MAClearCachedDecryptedMessageBody {
    NSLog(@"MAClearCachedDecryptedMessageBody");
    return [self MAClearCachedDecryptedMessageBody];
}

@end
