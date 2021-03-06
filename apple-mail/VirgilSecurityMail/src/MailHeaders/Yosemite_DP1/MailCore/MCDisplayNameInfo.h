/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

@class NSString;

@interface MCDisplayNameInfo : NSObject
{
    NSString *_shortName;
    NSString *_mediumName;
    NSString *_fullName;
}

@property(readonly, copy, nonatomic) NSString *fullName; // @synthesize fullName=_fullName;
@property(readonly, copy, nonatomic) NSString *mediumName; // @synthesize mediumName=_mediumName;
@property(readonly, copy, nonatomic) NSString *shortName; // @synthesize shortName=_shortName;
- (void).cxx_destruct;
- (id)debugDescription;
- (id)initWithShortName:(id)arg1 mediumName:(id)arg2 fullName:(id)arg3;
- (id)init;

@end

