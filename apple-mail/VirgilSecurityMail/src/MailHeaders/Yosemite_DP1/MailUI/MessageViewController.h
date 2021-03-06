/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSViewController.h"

#import "NSMenuDelegate.h"

@class BannerContainerViewController, ConversationMember, HeaderViewController, MessageView, MessageWebDocumentView, NSScrollView, NSString, NSTrackingArea, NSView;

@interface MessageViewController : NSViewController <NSMenuDelegate>
{
    BannerContainerViewController *_bannerViewController;
    HeaderViewController *_headerViewController;
    NSView *_actionButtons;
    NSView *_headerView;
    NSScrollView *_bodyScrollView;
    MessageWebDocumentView *_webDocumentView;
    NSTrackingArea *_rolloverTrackingArea;
}

+ (id)keyPathsForValuesAffectingShowingAllHeaders;
+ (id)keyPathsForValuesAffectingLoaded;
+ (id)keyPathsForValuesAffectingPageZoom;
+ (id)keyPathsForValuesAffectingHeaderDetailLevel;
+ (id)keyPathsForValuesAffectingShowHeaderDetails;
@property(retain, nonatomic) NSTrackingArea *rolloverTrackingArea; // @synthesize rolloverTrackingArea=_rolloverTrackingArea;
@property(retain, nonatomic) MessageWebDocumentView *webDocumentView; // @synthesize webDocumentView=_webDocumentView;
@property(retain, nonatomic) NSScrollView *bodyScrollView; // @synthesize bodyScrollView=_bodyScrollView;
@property(retain, nonatomic) NSView *headerView; // @synthesize headerView=_headerView;
@property(retain, nonatomic) NSView *actionButtons; // @synthesize actionButtons=_actionButtons;
@property(retain, nonatomic) HeaderViewController *headerViewController; // @synthesize headerViewController=_headerViewController;
@property(retain, nonatomic) BannerContainerViewController *bannerViewController; // @synthesize bannerViewController=_bannerViewController;
- (void).cxx_destruct;
- (BOOL)validateMenuItem:(id)arg1;
- (BOOL)validateToolbarItem:(id)arg1;
- (void)menuNeedsUpdate:(id)arg1;
- (void)exportAttachments:(id)arg1;
- (void)quickLookAllAttachments:(id)arg1;
- (void)saveAllAttachmentsWithoutPrompting:(id)arg1;
- (void)saveAllAttachments:(id)arg1;
- (void)saveAttachment:(id)arg1;
- (void)viewSource:(id)arg1;
- (void)showMessageInMailbox:(id)arg1;
- (void)showFilteredHeaders:(id)arg1;
- (void)showAllHeaders:(id)arg1;
- (void)forward:(id)arg1;
- (void)replyAll:(id)arg1;
- (void)reply:(id)arg1;
- (void)delete:(id)arg1;
- (id)_messageViewer;
- (void)mouseExited:(id)arg1;
- (void)mouseEntered:(id)arg1;
- (void)_updateHeaderMouseOver;
- (void)_updateRolloverTrackingArea:(id)arg1;
- (void)cursorUpdate:(id)arg1;
@property(retain) ConversationMember *representedObject;
@property(retain) MessageView *view;
@property(readonly, nonatomic) BOOL showingAllHeaders;
@property(readonly, nonatomic) BOOL loaded;
@property(nonatomic) double pageZoom;
@property(nonatomic) long long headerDetailLevel;
@property(nonatomic) long long showHeaderDetails;
- (void)dealloc;
- (void)awakeFromNib;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

