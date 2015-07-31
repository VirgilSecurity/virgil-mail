//
//  VirgilMimePart.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 31.07.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MimeBody.h>
#import <MimePart.h>
#import <MFMimeDecodeContext.h>

@interface VirgilMimePart : NSObject
- (BOOL)MAUsesKnownSignatureProtocol;
- (id)MADecodeWithContext:(id)ctx;
- (id)MADecodeTextPlainWithContext:(MFMimeDecodeContext *)ctx;
- (id)MADecodeTextHtmlWithContext:(MFMimeDecodeContext *)ctx;
- (id)MADecodeApplicationOctet_streamWithContext:(MFMimeDecodeContext *)ctx;
- (void)MAVerifySignature;
- (BOOL)MAIsEncrypted;
- (BOOL)MAIsMimeEncrypted;
- (BOOL)MAIsSigned;
- (BOOL)MAIsMimeSigned;
- (id)MANewEncryptedPartWithData:(NSData *)data recipients:(id)recipients encryptedData:(NSData **)encryptedData NS_RETURNS_RETAINED;
- (id)MANewSignedPartWithData:(id)data sender:(id)sender signatureData:(id *)signatureData NS_RETURNS_RETAINED;
- (void)MAClearCachedDecryptedMessageBody;
@end

@interface VirgilMimePart (NativeMimePartMethods)
- (MimeBody *)mimeBody;
- (MimePart *)startPart;
- (MimePart *)parentPart;
- (MimePart *)nextSiblingPart;
- (NSData *)bodyData;
- (id)dispositionParameterForKey:(NSString *)key;
- (BOOL)isType:(NSString *)type subtype:(NSString *)subtype;
- (id)bodyParameterForKey:(NSString *)key;
- (NSArray *)subparts;
- (id)decryptedMessageBody;
- (void)setDispositionParameter:(id)parameter forKey:(id)key;
- (BOOL)isAttachment;
- (NSData *)signedData;
- (NSString *)type;
- (NSString *)subtype;
- (id)contentTransferEncoding;

@end
