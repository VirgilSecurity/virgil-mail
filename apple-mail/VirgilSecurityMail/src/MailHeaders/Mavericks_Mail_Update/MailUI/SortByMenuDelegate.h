/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

#import "NSMenuDelegate.h"

@class NSMenuItem;

@interface SortByMenuDelegate : NSObject <NSMenuDelegate>
{
    NSMenuItem *_ascendingMenuItem;
    NSMenuItem *_descendingMenuItem;
}

@property NSMenuItem *descendingMenuItem; // @synthesize descendingMenuItem=_descendingMenuItem;
@property NSMenuItem *ascendingMenuItem; // @synthesize ascendingMenuItem=_ascendingMenuItem;
- (void)menuNeedsUpdate:(id)arg1;

@end

