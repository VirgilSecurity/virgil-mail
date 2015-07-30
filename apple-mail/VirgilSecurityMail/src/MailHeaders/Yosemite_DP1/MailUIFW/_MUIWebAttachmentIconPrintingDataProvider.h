/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

#import "MCCIDURLProtocolDataProvider.h"

@class NSData, NSImage, NSString, NSURL;

@interface _MUIWebAttachmentIconPrintingDataProvider : NSObject <MCCIDURLProtocolDataProvider>
{
    NSImage *_iconImage;
    NSURL *_cidURL;
}

@property(readonly) NSURL *cidURL; // @synthesize cidURL=_cidURL;
@property(retain) NSImage *iconImage; // @synthesize iconImage=_iconImage;
- (void).cxx_destruct;
@property(readonly, copy) NSData *data;
@property(readonly, copy) NSString *mimeType;
- (id)initWithImage:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) long long fileSize;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

