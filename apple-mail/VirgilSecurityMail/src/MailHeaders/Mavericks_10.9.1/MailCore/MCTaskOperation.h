/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSBlockOperation.h"

@class MCActivityMonitor;

@interface MCTaskOperation : NSBlockOperation
{
    MCActivityMonitor *_parentMonitor;
    MCActivityMonitor *_monitor;
}

+ (void)setTaskDescription:(const char *)arg1;
@property(retain) MCActivityMonitor *monitor; // @synthesize monitor=_monitor;
@property(retain) MCActivityMonitor *parentMonitor; // @synthesize parentMonitor=_parentMonitor;
- (void)cancel;
- (void)dealloc;
- (void)main;
- (id)setTaskName:(id)arg1 priority:(unsigned char)arg2 canCancel:(BOOL)arg3;
- (void)setParentMonitor:(id)arg1 taskName:(id)arg2;

@end

