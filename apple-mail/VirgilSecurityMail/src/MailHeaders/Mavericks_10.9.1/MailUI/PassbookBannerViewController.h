/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "LoadImagesBannerViewController.h"

@class GlassButton, NSMutableArray, NSTextField;

@interface PassbookBannerViewController : LoadImagesBannerViewController
{
    NSTextField *_messageField;
    GlassButton *_viewPassButton;
    NSMutableArray *_passes;
}

@property(retain, nonatomic) NSMutableArray *passes; // @synthesize passes=_passes;
@property(nonatomic) GlassButton *viewPassButton; // @synthesize viewPassButton=_viewPassButton;
@property(nonatomic) NSTextField *messageField; // @synthesize messageField=_messageField;
- (void)showPasses:(id)arg1;
- (void)updateBannerContents;
- (void)updateWantsDisplay;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)setRepresentedObject:(id)arg1;
- (void)setWantsDisplay:(BOOL)arg1;
- (void)setView:(id)arg1;
- (void)setContainer:(id)arg1;
- (void)awakeFromNib;
- (BOOL)shouldDisplayToLoadImages;
- (CDStruct_3c058996)iconAlignmentRectInsets;
- (id)backgroundColor;
- (void)dealloc;
- (id)initWithBannerContainerViewController:(id)arg1;
- (id)nibName;

// Remaining properties
@property(nonatomic) BOOL loaded;

@end

