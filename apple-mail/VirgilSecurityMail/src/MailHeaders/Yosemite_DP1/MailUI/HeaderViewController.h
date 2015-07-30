/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSViewController.h"

#import "HeaderLayoutManagerDelegate.h"
#import "NSDraggingSource.h"
#import "NSTextViewDelegate.h"
#import "NSTokenAttachmentDelegate.h"

@class ConversationMember, HeaderTextContainer, NSButton, NSImageView, NSLayoutConstraint, NSMutableDictionary, NSMutableSet, NSString, NSTextAttachment, NSTextView;

@interface HeaderViewController : NSViewController <HeaderLayoutManagerDelegate, NSTextViewDelegate, NSTokenAttachmentDelegate, NSDraggingSource>
{
    long long _detailLevel;
    long long _showDetails;
    BOOL _showVIPButton;
    NSImageView *_senderImageView;
    NSButton *_unreadVIPButton;
    HeaderTextContainer *_textContainer;
    NSTextView *_textView;
    NSMutableDictionary *_displayStringsByHeaderKey;
    NSMutableSet *_expandedHeaderKeys;
    NSTextAttachment *_flagTextAttachment;
    NSTextAttachment *_attachmentTextAttachment;
    NSLayoutConstraint *_senderImageViewBottomSpaceConstraint;
}

@property(retain, nonatomic) NSLayoutConstraint *senderImageViewBottomSpaceConstraint; // @synthesize senderImageViewBottomSpaceConstraint=_senderImageViewBottomSpaceConstraint;
@property(readonly, nonatomic) NSTextAttachment *attachmentTextAttachment; // @synthesize attachmentTextAttachment=_attachmentTextAttachment;
@property(readonly, nonatomic) NSTextAttachment *flagTextAttachment; // @synthesize flagTextAttachment=_flagTextAttachment;
- (void).cxx_destruct;
- (void)toggleVIP:(id)arg1;
- (void)showSignerCertificate:(id)arg1;
- (void)draggingSession:(id)arg1 endedAtPoint:(struct CGPoint)arg2 operation:(unsigned long long)arg3;
- (void)draggingSession:(id)arg1 movedToPoint:(struct CGPoint)arg2;
- (void)draggingSession:(id)arg1 willBeginAtPoint:(struct CGPoint)arg2;
- (unsigned long long)draggingSession:(id)arg1 sourceOperationMaskForDraggingContext:(long long)arg2;
- (id)menuForTokenAttachment:(id)arg1;
- (BOOL)hasMenuForTokenAttachment:(id)arg1;
- (BOOL)textView:(id)arg1 writeCell:(id)arg2 atIndex:(unsigned long long)arg3 toPasteboard:(id)arg4 type:(id)arg5;
- (id)textView:(id)arg1 writablePasteboardTypesForCell:(id)arg2 atIndex:(unsigned long long)arg3;
- (void)textView:(id)arg1 clickedOnCell:(id)arg2 inRect:(struct CGRect)arg3 atIndex:(unsigned long long)arg4;
- (BOOL)textView:(id)arg1 clickedOnLink:(id)arg2 atIndex:(unsigned long long)arg3;
- (id)layoutManager:(id)arg1 shouldUseSelectedTextAttributes:(id)arg2 atCharacterIndex:(unsigned long long)arg3 effectiveRange:(struct _NSRange *)arg4;
- (void)layoutManager:(id)arg1 textContainerChangedGeometry:(id)arg2;
- (void)_layoutTextStorageIfNeeded;
- (void)_updateUnreadVIPButton;
- (void)_updateTextStorageWithHardInvalidation:(BOOL)arg1;
- (void)_updateSenderImageView;
- (void)_updateFlagTextAttachment;
- (void)_updateAttachmentTextAttachment;
- (void)_setImage:(id)arg1 forTextAttachmentCell:(id)arg2;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)_unregisterKVOForRepresentedObject:(id)arg1;
- (void)_registerKVOForRepresentedObject:(id)arg1;
- (void)mouseDragged:(id)arg1;
- (void)mouseDown:(id)arg1;
- (void)cursorUpdate:(id)arg1;
- (id)_messageViewer;
- (void)setView:(id)arg1;
@property(retain) ConversationMember *representedObject;
@property(nonatomic) BOOL showVIPButton;
@property(nonatomic) long long detailLevel;
@property(nonatomic) long long showDetails;
@property(readonly, nonatomic) NSTextView *textView; // @synthesize textView=_textView;
@property(readonly, nonatomic) HeaderTextContainer *textContainer; // @synthesize textContainer=_textContainer;
@property(readonly, nonatomic) NSButton *unreadVIPButton; // @synthesize unreadVIPButton=_unreadVIPButton;
@property(readonly, nonatomic) NSImageView *senderImageView;
- (void)dealloc;
- (void)_headerViewControllerCommonInit;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;
- (id)initWithCoder:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

