/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

@class NSArray, NSDictionary, NSMutableArray, NSMutableDictionary, NSMutableSet;

@interface _FilteredListInfo : NSObject
{
    int _taskType;
    NSMutableArray *_filteredMessages;
    NSArray *_changedMessages;
    NSMutableSet *_filteredThreads;
    NSArray *_changedThreads;
    NSDictionary *_changedFlags;
    NSArray *_messagesFilteredIn;
    NSArray *_messagesFilteredOut;
    NSMutableDictionary *_messageSortValues;
    NSDictionary *_snippetsForMessages;
}

+ (id)infoForType:(int)arg1;
@property int taskType; // @synthesize taskType=_taskType;
@property(retain) NSDictionary *snippetsForMessages; // @synthesize snippetsForMessages=_snippetsForMessages;
@property(retain) NSMutableDictionary *messageSortValues; // @synthesize messageSortValues=_messageSortValues;
@property(retain) NSArray *messagesFilteredOut; // @synthesize messagesFilteredOut=_messagesFilteredOut;
@property(retain) NSArray *messagesFilteredIn; // @synthesize messagesFilteredIn=_messagesFilteredIn;
@property(retain) NSDictionary *changedFlags; // @synthesize changedFlags=_changedFlags;
@property(retain) NSArray *changedThreads; // @synthesize changedThreads=_changedThreads;
@property(retain) NSMutableSet *filteredThreads; // @synthesize filteredThreads=_filteredThreads;
@property(retain) NSArray *changedMessages; // @synthesize changedMessages=_changedMessages;
@property(retain) NSMutableArray *filteredMessages; // @synthesize filteredMessages=_filteredMessages;
- (void)dealloc;

@end

