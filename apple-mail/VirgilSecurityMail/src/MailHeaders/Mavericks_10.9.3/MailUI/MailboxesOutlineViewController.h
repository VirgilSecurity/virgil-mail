/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

#import "MVMailboxSelectionOwner.h"
#import "MailboxOutlineItemControllerDelegate.h"
#import "MailboxesOutlineViewDelegate.h"
#import "NSOutlineViewDataSource.h"

@class MFMailbox, MailboxesOutlineView, NSMapTable;

@interface MailboxesOutlineViewController : NSObject <MailboxesOutlineViewDelegate, MVMailboxSelectionOwner, NSOutlineViewDataSource, MailboxOutlineItemControllerDelegate>
{
    double _idealOutlineViewWidth;
    id <MailboxesOutlineViewControllerDelegate> _delegate;
    long long _reloadingCount;
    long long _wantsToEditInlineCount;
    MailboxesOutlineView *_outlineView;
    NSMapTable *_itemControllers;
    MFMailbox *_clickedMailbox;
}

@property(retain) MFMailbox *clickedMailbox; // @synthesize clickedMailbox=_clickedMailbox;
@property(readonly) NSMapTable *itemControllers; // @synthesize itemControllers=_itemControllers;
@property(retain) MailboxesOutlineView *outlineView; // @synthesize outlineView=_outlineView;
- (void)mailbox:(id)arg1 nameUpdated:(id)arg2;
- (unsigned long long)badgeCountForItem:(id)arg1;
- (id)mailboxesOutlineView;
- (void)outlineViewItemDidCollapse:(id)arg1;
- (void)outlineViewItemDidExpand:(id)arg1;
- (void)didCloseContextMenu:(id)arg1;
- (void)willShowContextMenu:(id)arg1;
- (void)setFirstResponderAfterMouseDownOnOutlineView:(id)arg1;
- (void)selectAllInOutlineView:(id)arg1;
- (void)outlineView:(id)arg1 didAddRowView:(id)arg2 forRow:(long long)arg3;
- (void)outlineView:(id)arg1 didRemoveRowView:(id)arg2 forRow:(long long)arg3;
- (void)outlineViewSelectionDidChange:(id)arg1;
- (id)outlineView:(id)arg1 selectionIndexesForProposedSelection:(id)arg2;
- (BOOL)outlineView:(id)arg1 shouldCollapseItem:(id)arg2;
- (BOOL)outlineView:(id)arg1 shouldExpandItem:(id)arg2;
- (double)outlineView:(id)arg1 heightOfRowByItem:(id)arg2;
- (BOOL)outlineView:(id)arg1 isGroupItem:(id)arg2;
- (id)outlineView:(id)arg1 viewForTableColumn:(id)arg2 item:(id)arg3;
- (id)outlineView:(id)arg1 rowViewForItem:(id)arg2;
- (unsigned long long)_outlineView:(id)arg1 validateDrop:(id)arg2 proposedItem:(id)arg3 proposedChildIndex:(long long)arg4 allowStoreCreation:(BOOL)arg5;
- (unsigned long long)outlineView:(id)arg1 validateDrop:(id)arg2 proposedItem:(id)arg3 proposedChildIndex:(long long)arg4;
- (BOOL)outlineView:(id)arg1 acceptDrop:(id)arg2 item:(id)arg3 childIndex:(long long)arg4;
- (void)pasteboard:(id)arg1 provideDataForType:(id)arg2;
- (void)outlineView:(id)arg1 draggingSession:(id)arg2 endedAtPoint:(struct CGPoint)arg3 operation:(unsigned long long)arg4;
- (BOOL)outlineView:(id)arg1 writeItems:(id)arg2 toPasteboard:(id)arg3;
- (id)outlineView:(id)arg1 persistentObjectForItem:(id)arg2;
- (id)outlineView:(id)arg1 itemForPersistentObject:(id)arg2;
- (id)itemControllerForItem:(id)arg1 makeIfNecessary:(BOOL)arg2;
- (id)outlineView:(id)arg1 objectValueForTableColumn:(id)arg2 byItem:(id)arg3;
- (id)outlineView:(id)arg1 child:(long long)arg2 ofItem:(id)arg3;
- (BOOL)outlineView:(id)arg1 isItemExpandable:(id)arg2;
- (long long)outlineView:(id)arg1 numberOfChildrenOfItem:(id)arg2;
- (id)mailboxSelectionWindow;
- (void)_revealMailbox:(id)arg1;
- (void)revealMailbox:(id)arg1;
- (id)sortedSectionItemsForTimeMachine;
- (id)expandedItems;
- (BOOL)sectionIsExpanded:(id)arg1;
- (BOOL)mailboxIsExpanded:(id)arg1;
- (void)selectPathsToMailboxes:(id)arg1 scrollToVisible:(BOOL)arg2;
- (void)selectPathsToMailboxes:(id)arg1;
- (BOOL)isSelectedMailboxSpecial;
- (id)selectedMailbox;
- (id)selectedMailboxes;
- (void)_mailboxPendingNameDidChange:(id)arg1;
- (void)_viewerPreferencesChanged:(id)arg1;
- (void)_userInfoDidChange:(id)arg1;
- (void)_displayCountDidChange:(id)arg1;
- (void)_mailboxesActivityDidChange:(id)arg1;
- (void)_sectionListingDidChange:(id)arg1;
- (void)_mailboxPublicStatusDidChange:(id)arg1;
- (void)_mailboxListingDidChange:(id)arg1;
- (void)_accountOfflineStatusDidChange:(id)arg1;
- (void)_accountAdded:(id)arg1;
- (void)_handleWebAuthenticationRequiredError:(id)arg1 withCompletionHandler:(id)arg2;
- (void)_alertClickedForItem:(id)arg1;
- (void)rowDoubleClicked:(id)arg1;
- (void)rowClicked:(id)arg1;
- (void)alertClicked:(id)arg1;
- (BOOL)_isTopLevelItem:(id)arg1;
- (void)_saveSelectionAndReloadItem:(id)arg1;
- (void)_updateProgressIndicatorForMailbox:(id)arg1;
- (id)_copyActivityMonitorsForMailbox:(id)arg1 finishedCount:(unsigned long long *)arg2 includingDescendants:(BOOL)arg3;
- (void)_redisplayRowsForItems:(id)arg1;
- (unsigned long long)_badgeCountForItem:(id)arg1;
- (id)_firstChildIfCollapsedSpecialMailbox:(id)arg1;
- (void)_endWantsToEditInline;
- (void)_beginWantsToEditInline;
@property(readonly) BOOL wantsToEditInline;
- (void)_endReloading;
- (void)_beginReloading;
@property(readonly) BOOL isReloading;
- (void)editNameOfMailbox:(id)arg1;
- (void)makeMailboxesListFirstResponder;
@property(nonatomic) double idealOutlineViewWidth; // @synthesize idealOutlineViewWidth=_idealOutlineViewWidth;
@property(readonly, nonatomic) double minimumWidthNeededToUseMailboxes;
@property(readonly, nonatomic) double minimizedOutlineViewWidth;
- (void)clearDelegateBecauseWindowIsClosing;
- (void)dealloc;
- (void)_migrateAutosaveName;
@property id <MailboxesOutlineViewControllerDelegate> delegate;
- (void)awakeFromNib;
- (id)init;

@end

