/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

@protocol MUICollectionViewDelegate <NSObject>

@optional
- (void)collectionView:(id)arg1 didEndScrollInScrollView:(id)arg2;
- (void)collectionView:(id)arg1 didScrollInScrollView:(id)arg2;
- (void)collectionView:(id)arg1 didBeginScrollInScrollView:(id)arg2;
- (void)collectionView:(id)arg1 didDeselectIndex:(unsigned long long)arg2;
- (void)collectionView:(id)arg1 didSelectIndex:(unsigned long long)arg2;
- (void)collectionView:(id)arg1 didEndDisplayingCellView:(id)arg2 forItemAtIndex:(unsigned long long)arg3;
- (void)collectionView:(id)arg1 didBeginDisplayingCellView:(id)arg2 forItemAtIndex:(unsigned long long)arg3;
- (id)collectionView:(id)arg1 cellForItemAtIndex:(unsigned long long)arg2;
- (double)collectionView:(id)arg1 initialHeightOfCellAtIndex:(unsigned long long)arg2;
@end

