/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

//#import "NSObject.h"

//#import "NSURLDownloadDelegate.h"

@class MCMimeBody, MCMimePart, NSArray, NSData, NSDictionary, NSFileWrapper, NSImage, NSNumber, NSOperation, NSProgress, NSString, NSURL;

@interface MCAttachment : NSObject <NSURLDownloadDelegate>
{
    NSData *_currentData;
    NSFileWrapper *_fileWrapper;
    NSData *_originalData;
    BOOL _hasResourceForkData;
    struct CGSize _imageSizeFromHeaders;
    NSImage *_iconImage;
    long long _imageByteCountFromHeaders;
    unsigned short _finderFlags;
    MCMimeBody *_mimeBody;
    MCMimePart *_mimePart;
    NSString *_filenameForSaving;
    unsigned long long _approximateSize;
    BOOL _shouldHideExtension;
    BOOL _isCalendarInvitation;
    BOOL _isUnreferencedAttachment;
    unsigned int _type;
    unsigned int _creator;
    NSURL *_externalBodyURL;
    NSString *_filename;
    NSString *_originalFilename;
    NSNumber *_fileSize;
    NSString *_contentID;
    NSString *_extension;
    NSNumber *_filePermissions;
    NSString *_mimeType;
    NSString *_messageID;
    NSString *_mailSpecialHandlingType;
    id _stationeryCompositeImage;
    NSString *_savedPath;
    NSArray *_whereFroms;
    NSDictionary *_quarantineProperties;
    NSOperation *_fileReadingOperation;
    NSProgress *_downloadProgress;
}

+ (id)_backgroundFileReadingQueue;
+ (BOOL)automaticallyNotifiesObserversOfOriginalData;
@property(retain) NSProgress *downloadProgress; // @synthesize downloadProgress=_downloadProgress;
@property BOOL isUnreferencedAttachment; // @synthesize isUnreferencedAttachment=_isUnreferencedAttachment;
@property(retain) NSOperation *fileReadingOperation; // @synthesize fileReadingOperation=_fileReadingOperation;
@property(retain) NSDictionary *quarantineProperties; // @synthesize quarantineProperties=_quarantineProperties;
@property(retain) NSArray *whereFroms; // @synthesize whereFroms=_whereFroms;
@property(retain) NSString *savedPath; // @synthesize savedPath=_savedPath;
@property(readonly) id stationeryCompositeImage; // @synthesize stationeryCompositeImage=_stationeryCompositeImage;
@property(retain) NSString *mailSpecialHandlingType; // @synthesize mailSpecialHandlingType=_mailSpecialHandlingType;
@property BOOL isCalendarInvitation; // @synthesize isCalendarInvitation=_isCalendarInvitation;
@property(retain) NSString *messageID; // @synthesize messageID=_messageID;
@property(retain) NSString *mimeType; // @synthesize mimeType=_mimeType;
@property(retain) NSNumber *filePermissions; // @synthesize filePermissions=_filePermissions;
@property BOOL shouldHideExtension; // @synthesize shouldHideExtension=_shouldHideExtension;
@property(retain) NSString *extension; // @synthesize extension=_extension;
@property unsigned int creator; // @synthesize creator=_creator;
@property unsigned int type; // @synthesize type=_type;
@property(retain) NSString *contentID; // @synthesize contentID=_contentID;
@property(retain) NSNumber *fileSize; // @synthesize fileSize=_fileSize;
@property(retain) NSString *originalFilename; // @synthesize originalFilename=_originalFilename;
@property(retain) NSString *filename; // @synthesize filename=_filename;
@property(retain) NSURL *externalBodyURL; // @synthesize externalBodyURL=_externalBodyURL;
- (void)_finishedCoordinatedFileReadingWithURL:(id)arg1;
- (BOOL)hasPendingBackgroundRead;
- (void)beginBackgroundFileReading;
- (id)description;
- (id)symbolicLinkDestinationForFileWrapper;
- (id)createTemporaryFile;
- (BOOL)createEmptyAttachmentAtPath:(id)arg1;
- (void)setFilenameForSaving:(id)arg1;
- (id)fileWrapperIfAvailable;
@property(retain) NSFileWrapper *fileWrapper;
- (id)fileWrapperIncludeData:(BOOL)arg1 fetchLevel:(unsigned long long)arg2;
- (id)_fileWrapperIncludeData:(BOOL)arg1;
- (id)appleDoubleDataWithFilename:(const char *)arg1 length:(unsigned long long)arg2;
- (id)appleSingleDataWithFilename:(const char *)arg1 length:(unsigned long long)arg2;
- (BOOL)couldConfuseWindowsClients;
- (void)takeNewDataFromPath:(id)arg1;
@property BOOL isPartOfStationery;
- (BOOL)isDirectory;
- (id)remoteAccessMimeType;
- (BOOL)isRemotelyAccessed;
- (void)isImage:(char *)arg1 isPDF:(char *)arg2 bestMimeType:(id *)arg3;
- (void)isImage:(char *)arg1 isPDF:(char *)arg2;
- (BOOL)isPDF;
- (BOOL)isImage;
- (BOOL)isStationeryCompositeImage;
- (BOOL)isVideoOrAudio;
@property(readonly) NSString *typeIdentifier;
- (id)toolTip;
- (void)discardIconImage;
- (void)setIconImage:(id)arg1;
- (id)iconImage;
- (id)filenameWithoutHiddenExtension;
- (unsigned long long)approximateSize;
- (unsigned long long)approximateSizeOfWrapper;
- (BOOL)isDataDownloaded;
- (long long)imageByteCountFromHeaders;
- (struct CGSize)imageSizeFromHeaders;
- (void)setFromHeadersImageSize:(struct CGSize)arg1 byteCount:(long long)arg2;
- (void)downloadDidFinish:(id)arg1;
- (void)download:(id)arg1 didFailWithError:(id)arg2;
- (void)download:(id)arg1 didReceiveDataOfLength:(unsigned long long)arg2;
- (void)download:(id)arg1 didReceiveResponse:(id)arg2;
- (id)dataForFetchLevel:(unsigned long long)arg1;
- (void)takeInfoFromMessageAttachment:(id)arg1 saveOriginalData:(BOOL)arg2;
- (void)_configureWithMimePart;
@property(retain) MCMimePart *mimePart;
- (void)setFileNameForResizedImage:(id)arg1;
- (BOOL)isFullSize;
- (void)revertToOriginalData;
- (void)setDataForResizedImage:(id)arg1;
- (BOOL)isScalable;
@property(retain, nonatomic) NSData *currentData;
@property(retain, nonatomic) NSData *originalData;
- (id)attachmentWithCurrentData;
- (void)dealloc;
- (id)initWithFileURL:(id)arg1;
- (id)initWithStationeryCompositeImage:(id)arg1;
- (id)initWithExternalBodyURL:(id)arg1;
- (id)initWithFileWrapper:(id)arg1;
- (id)initWithMailInternalData:(id)arg1;
- (id)initWithData:(id)arg1;

@end

