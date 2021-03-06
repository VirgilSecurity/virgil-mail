/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "MUICollectionCellView.h"

#import "NSAccessibilityGroup.h"

@class CALayer, MessageWebDocumentView, NSScrollView, NSString;

@interface MessageView : MUICollectionCellView <NSAccessibilityGroup>
{
    NSScrollView *_bodyScrollView;
    MessageWebDocumentView *_webDocumentView;
    CALayer *_borderLayer;
}

@property(nonatomic) __weak CALayer *borderLayer; // @synthesize borderLayer=_borderLayer;
@property(retain, nonatomic) MessageWebDocumentView *webDocumentView; // @synthesize webDocumentView=_webDocumentView;
@property(retain, nonatomic) NSScrollView *bodyScrollView; // @synthesize bodyScrollView=_bodyScrollView;
- (void).cxx_destruct;
- (void)collectionView:(id)arg1 didScrollInScrollView:(id)arg2;
- (BOOL)_isSelected;
- (id)_borderColor;
- (void)prepareContentInRect:(struct CGRect)arg1;
- (void)updateLayer;
- (void)layoutSublayersOfLayer:(id)arg1;
- (id)makeBackingLayer;
- (void)setFrameSize:(struct CGSize)arg1;
- (void)setFrameOrigin:(struct CGPoint)arg1;
- (CDStruct_3c058996)alignmentRectInsets;
- (void)setFocused:(BOOL)arg1;
- (void)setSelected:(BOOL)arg1;
- (void)setEmphasized:(BOOL)arg1;
- (void)setCellIndex:(unsigned long long)arg1;
- (BOOL)wantsUpdateLayer;
- (BOOL)isFlipped;
- (BOOL)canBecomeKeyView;
- (BOOL)acceptsFirstResponder;
- (void)awakeFromNib;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

