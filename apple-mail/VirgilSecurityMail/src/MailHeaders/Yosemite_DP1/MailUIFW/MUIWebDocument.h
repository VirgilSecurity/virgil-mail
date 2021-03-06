/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

#import "NSCoding.h"
#import "NSCopying.h"

@class MUIWebAttachment, NSArray, NSDictionary, NSError, NSMutableDictionary, NSString, NSURL;

@interface MUIWebDocument : NSObject <NSCoding, NSCopying>
{
    NSString *_html;
    NSMutableDictionary *_jsDocumentContext;
    BOOL _loadRemoteContent;
    BOOL _hasBlockedRemoteContent;
    NSArray *_attachments;
    Class _webAttachmentClass;
    unsigned long long _imageScale;
    NSURL *_baseURL;
    NSDictionary *_dataDetectorsContext;
    NSError *_parseError;
    unsigned long long _originalEncoding;
    MUIWebAttachment *_imageArchiveAttachment;
}

@property(retain, nonatomic) MUIWebAttachment *imageArchiveAttachment; // @synthesize imageArchiveAttachment=_imageArchiveAttachment;
@property(copy, nonatomic) NSString *html; // @synthesize html=_html;
@property(nonatomic) unsigned long long originalEncoding; // @synthesize originalEncoding=_originalEncoding;
@property(nonatomic) BOOL hasBlockedRemoteContent; // @synthesize hasBlockedRemoteContent=_hasBlockedRemoteContent;
@property(nonatomic) BOOL loadRemoteContent; // @synthesize loadRemoteContent=_loadRemoteContent;
@property(retain, nonatomic) NSError *parseError; // @synthesize parseError=_parseError;
@property(copy, nonatomic) NSDictionary *dataDetectorsContext; // @synthesize dataDetectorsContext=_dataDetectorsContext;
@property(retain, nonatomic) NSURL *baseURL; // @synthesize baseURL=_baseURL;
@property(nonatomic) unsigned long long imageScale; // @synthesize imageScale=_imageScale;
@property(nonatomic) Class webAttachmentClass; // @synthesize webAttachmentClass=_webAttachmentClass;
@property(copy, nonatomic) NSArray *attachments; // @synthesize attachments=_attachments;
- (void).cxx_destruct;
- (id)attachmentForGeneratedContentID:(id)arg1;
- (id)description;
- (id)_defaultDocumentHTML;
- (void)setValueInJsDocumentContext:(id)arg1 forKey:(id)arg2;
@property(readonly, copy, nonatomic) NSDictionary *jsDocumentContext;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)encodeWithCoder:(id)arg1;
- (void)_muiWebDocumentCommonInit;
- (id)initWithCoder:(id)arg1;
- (id)init;

@end

