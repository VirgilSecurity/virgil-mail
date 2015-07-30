/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSView.h"

@class FlagButtonImageView, NSMutableArray, NSMutableDictionary, NSTextField;

@interface FlagsMenuItemView : NSView
{
    NSMutableDictionary *_flagViews;
    NSMutableArray *_trackingAreas;
    NSTextField *_flagTitleTextField;
    NSTextField *_flagNameTextField;
    FlagButtonImageView *_clearFlaggedStatusView;
}

@property(retain, nonatomic) FlagButtonImageView *clearFlaggedStatusView; // @synthesize clearFlaggedStatusView=_clearFlaggedStatusView;
@property(retain, nonatomic) NSTextField *flagNameTextField; // @synthesize flagNameTextField=_flagNameTextField;
@property(retain, nonatomic) NSTextField *flagTitleTextField; // @synthesize flagTitleTextField=_flagTitleTextField;
- (void).cxx_destruct;
- (void)setEnabled:(BOOL)arg1;
- (void)viewDidMoveToWindow;
- (void)mouseUp:(id)arg1;
- (void)mouseExited:(id)arg1;
- (void)mouseEntered:(id)arg1;
- (void)_drawSelectedOutlineForView:(id)arg1;
- (id)_viewForFlagColor:(BOOL)arg1;
- (void)dealloc;
- (void)awakeFromNib;
- (void)_flagsMenuItemViewCommonInit;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;

@end

