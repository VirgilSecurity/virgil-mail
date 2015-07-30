/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */



#import "MessageConsumer-Protocol.h"

@class InvocationQueue, LibraryStore;

@interface _LibraryStoreMessageConsumer : NSObject <MessageConsumer>
{
    LibraryStore *_libraryStore;
    InvocationQueue *_callbackQueue;
}

- (id)initWithLibraryStore:(id)arg1 useCallbackQueue:(BOOL)arg2;
- (void)dealloc;
- (void)newMessagesAvailable:(id)arg1 conversationsMembersByMessageID:(id)arg2;
- (BOOL)shouldCancel;
- (id)libraryNotificationObject;
- (id)libraryNotificationMessages;
- (void)finishedSendingMessages;

@end

