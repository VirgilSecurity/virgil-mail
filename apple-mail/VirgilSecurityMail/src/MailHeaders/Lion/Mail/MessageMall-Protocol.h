/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

@protocol MessageMall <NSObject>
- (void)unregisterForNotifications;
- (long long)filteredMessagesCount;
- (id)filteredMessageAtIndex:(unsigned long long)arg1;
- (id)filteredMessagesAtIndexes:(id)arg1;
- (id)filteredMessages;
- (id)filteredMessagesInRange:(struct _NSRange)arg1;
- (unsigned long long)indexOfFilteredMessage:(id)arg1;
- (unsigned long long)indexOfFilteredDocument:(id)arg1;
- (id)numberForMessage:(id)arg1;
- (id)filteredMessageAtIndex:(unsigned long long)arg1 isChildOfThread:(char *)arg2;
- (unsigned long long)indexOfMessage:(id)arg1;
- (id)filteredThreads;
- (void)clearFilteredMessages;
- (BOOL)isFocused;
- (void)setFocusedMessages:(id)arg1;
- (id)threadForMessageID:(id)arg1;
- (BOOL)messageIsPartOfAThread:(id)arg1;
- (id)messageIDsToShowAllCopiesOf;
- (void)showAllCopiesOfMessage:(id)arg1;
- (void)hideAllCopiesOfMessages:(id)arg1;
- (id)messagesIncludingHiddenCopies:(id)arg1;
- (id)originalOfMessage:(id)arg1;
- (BOOL)filteredListIncludesAllMessages;
- (id)smartMailboxMemberMessagesForMessages:(id)arg1;
- (unsigned long long)unreadCount;
- (unsigned long long)totalCount;
- (id)messageForMessageID:(id)arg1;
- (BOOL)isReadOnly;
- (BOOL)isOpened;
- (BOOL)canRebuild;
- (void)rebuildTableOfContentsAsynchronously;
- (BOOL)canCompact;
- (void)doCompact;
- (void)setupRowDrawingInfo:(struct __CFDictionary *)arg1;
- (id)hideMessages:(id)arg1;
- (id)unhideMessages:(id)arg1;
- (BOOL)deletedFlagForMessage:(id)arg1;
- (void)setMailboxUids:(id)arg1;
- (id)allMailboxUids;
- (id)selectedMailboxUids;
- (id)expandedSelectedMailboxUids;
- (id)stores;
- (id)expandedSelectedMailboxUidsAllowingSearch;
- (BOOL)includeDeleted;
- (void)setIncludeDeleted:(BOOL)arg1;
- (void)setSortOrder:(id)arg1 ascending:(BOOL)arg2;
- (id)sortOrder;
- (BOOL)isSortedAscending;
- (void)sortMessages:(id)arg1;
- (BOOL)displayingToColumn;
- (void)setDisplayingToColumn:(BOOL)arg1;
- (BOOL)isInThreadedMode;
- (BOOL)isInThreadedModeExcludingSearch;
- (void)setIsInThreadedMode:(BOOL)arg1;
- (void)toggleThreadedMode;
- (void)prepareToDisplayThread:(id)arg1;
- (BOOL)openThreadAtIndex:(long long)arg1 andSelectMessage:(id)arg2 animate:(BOOL)arg3;
- (id)quietlyOpenThreadAtIndex:(unsigned long long)arg1;
- (BOOL)closeThreadAtIndex:(long long)arg1 focusRow:(long long)arg2 animate:(BOOL)arg3;
- (id)quietlyCloseThreadAtIndex:(unsigned long long)arg1;
- (BOOL)openThreadsWithIDs:(id)arg1;
- (void)openAllThreads;
- (void)closeAllThreads;
- (void)reload:(id)arg1;
- (void)routeMessages:(id)arg1;
- (void)addMessagesInSameThreadAsMessage:(id)arg1 toSet:(id)arg2;
- (id)repliesToMessage:(id)arg1;
- (id)parentOfMessage:(id)arg1;
- (id)filteredThreadForMessage:(id)arg1;
- (id)unfilteredThreadForMessage:(id)arg1;
- (id)allRelatedMessagesForMessage:(id)arg1;
- (BOOL)hasNonDuplicateRelatedMessages:(id)arg1;
- (BOOL)supportsSearching;

@optional
- (void)searchForSuggestions:(id)arg1 in:(int)arg2 withOptions:(int)arg3;
- (void)searchForString:(id)arg1 in:(int)arg2 withOptions:(int)arg3;
- (id)criterionForSuggestion:(id)arg1 forSavedSearch:(BOOL)arg2;
- (unsigned long long)sizeForMessage:(id)arg1;
- (BOOL)isShowingSearchResults;
- (BOOL)isStillSearching;
- (int)currentSearchField;
- (int)currentSearchTarget;
@end

