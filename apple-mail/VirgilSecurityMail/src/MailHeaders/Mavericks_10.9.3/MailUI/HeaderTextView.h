/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSTextView.h"

@interface HeaderTextView : NSTextView
{
    id <NSTextAttachmentCell> _attachmentCell;
    struct CGSize _contentSize;
    struct CGRect _attachmentCellRect;
}

@property(nonatomic) struct CGSize contentSize; // @synthesize contentSize=_contentSize;
@property(nonatomic) struct CGRect attachmentCellRect; // @synthesize attachmentCellRect=_attachmentCellRect;
@property(retain, nonatomic) id <NSTextAttachmentCell> attachmentCell; // @synthesize attachmentCell=_attachmentCell;
- (BOOL)writeSelectionToPasteboard:(id)arg1 type:(id)arg2;
- (id)_selectedAttributedString;
- (id)writablePasteboardTypes;
- (void)mouseMoved:(id)arg1;
- (void)mouseExited:(id)arg1;
- (void)mouseEntered:(id)arg1;
- (void)rightMouseDown:(id)arg1;
- (void)mouseDown:(id)arg1;
- (void)cursorUpdate:(id)arg1;
- (id)_attachmentCellForCharacterAtIndex:(unsigned long long)arg1;
- (unsigned long long)_glyphIndexForPoint:(struct CGPoint)arg1 glyphRect:(struct CGRect *)arg2;
- (void)resetCursorRects;
- (void)keyDown:(id)arg1;
- (struct CGSize)intrinsicContentSize;
- (void)setConstrainedFrameSize:(struct CGSize)arg1;
- (BOOL)autoscroll:(id)arg1;
- (BOOL)resignFirstResponder;
- (BOOL)canBecomeKeyView;
- (void)dealloc;

@end

