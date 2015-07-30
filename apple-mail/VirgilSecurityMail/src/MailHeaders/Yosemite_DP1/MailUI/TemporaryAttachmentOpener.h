/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "GenericAttachmentFetcher.h"

@class NSString;

@interface TemporaryAttachmentOpener : GenericAttachmentFetcher
{
    NSString *_applicationPath;
}

@property(readonly, copy, nonatomic) NSString *applicationPath; // @synthesize applicationPath=_applicationPath;
- (void).cxx_destruct;
- (double)temporaryFolderTimeout;
- (void)didSaveAttachment:(id)arg1 toPath:(id)arg2;
- (void)_openAttachmentAtPath:(id)arg1;
- (void)downloadedAllAttachments;
- (id)initWithAttachments:(id)arg1;
- (id)initWithAttachments:(id)arg1 applicationPath:(id)arg2;

@end

