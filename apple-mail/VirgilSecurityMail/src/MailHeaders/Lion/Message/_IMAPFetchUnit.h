/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */



@class IMAPClientFetchDataItem, IMAPFetchResult;

@interface _IMAPFetchUnit : NSObject
{
    unsigned int _uid;
    IMAPClientFetchDataItem *_fetchItem;
    IMAPFetchResult *_expectedFetchResult;
}

- (void)dealloc;
- (void)_setupExpectedFetchResult;
- (BOOL)matchesFetchResponse:(id)arg1;
- (id)newFailedFetchResponse;
@property(retain) IMAPFetchResult *expectedFetchResult; // @synthesize expectedFetchResult=_expectedFetchResult;
@property(retain) IMAPClientFetchDataItem *fetchItem; // @synthesize fetchItem=_fetchItem;
@property unsigned int uid; // @synthesize uid=_uid;

@end

