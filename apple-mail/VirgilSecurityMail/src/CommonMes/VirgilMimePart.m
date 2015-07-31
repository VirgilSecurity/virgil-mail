//
//  VirgilMimePart.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 31.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMimePart.h"
#import "VirgilProcessingHelper.h"
#import <MimeBody.h>

@implementation VirgilMimePart

- (BOOL)MAUsesKnownSignatureProtocol {
    NSLog(@"MAUsesKnownSignatureProtocol");
    //return YES;
    return [self MAUsesKnownSignatureProtocol];
}

- (id)MADecodeWithContext:(id)ctx {
    NSLog(@"MADecodeWithContext");
    
    //Message *currentMessage = [(MimeBody *)[self mimeBody] message];
    MimePart * topLevelPart = [self topLevelPart];
    
    NSMutableArray * mimeParts = [[NSMutableArray alloc] init];
    [mimeParts addObject:topLevelPart];
    
    if ([VirgilProcessingHelper isEncryptedByVirgil:topLevelPart]) {
        NSLog(@"           Virgil e-mail !!!");
    } else {
        NSLog(@"           NOT Virgil e-mail :-(");
    }
    
    return [self MADecodeWithContext:ctx];
}

- (MimePart *) topLevelPart {
    MimePart * res = (MimePart *)self;
    while ([res parentPart] != nil) {
        res = [res parentPart];
    }
    return res;
}

- (id)MADecodeTextPlainWithContext:(MFMimeDecodeContext *)ctx {
    //Message *currentMessage = [(MimeBody *)[self mimeBody] message];
    
    NSLog(@"MADecodeTextPlainWithContext");
    return [self MADecodeTextPlainWithContext:ctx];
}

- (id)MADecodeTextHtmlWithContext:(MFMimeDecodeContext *)ctx {
    NSLog(@"MADecodeTextHtmlWithContext");
    return [self MADecodeTextHtmlWithContext:ctx];
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
