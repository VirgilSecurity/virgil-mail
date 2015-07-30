/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */



@class NSDate, NSString;

@interface LibraryCalendarEvent : NSObject
{
    NSString *_originalReceivedAccountURLString;
    NSString *_associatedCalendarItemIdString;
    NSString *_location;
    NSString *_uid;
    NSDate *_startDate;
    NSDate *_endDate;
    BOOL _isAllDayEvent;
    BOOL _isOutOfDate;
    BOOL _hasBeenProcessed;
    BOOL _isResponseRequested;
    long long _responseStatus;
}

- (void)dealloc;
@property long long responseStatus; // @synthesize responseStatus=_responseStatus;
@property BOOL isResponseRequested; // @synthesize isResponseRequested=_isResponseRequested;
@property BOOL hasBeenProcessed; // @synthesize hasBeenProcessed=_hasBeenProcessed;
@property BOOL isOutOfDate; // @synthesize isOutOfDate=_isOutOfDate;
@property BOOL isAllDayEvent; // @synthesize isAllDayEvent=_isAllDayEvent;
@property(copy) NSDate *endDate; // @synthesize endDate=_endDate;
@property(copy) NSDate *startDate; // @synthesize startDate=_startDate;
@property(copy) NSString *uid; // @synthesize uid=_uid;
@property(copy) NSString *location; // @synthesize location=_location;
@property(copy) NSString *associatedCalendarItemIdString; // @synthesize associatedCalendarItemIdString=_associatedCalendarItemIdString;
@property(copy) NSString *originalReceivedAccountURLString; // @synthesize originalReceivedAccountURLString=_originalReceivedAccountURLString;

@end

