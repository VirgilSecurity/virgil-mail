/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

@class CriteriaUIHelper, MFMailbox, NSTextField, NSTextView, NSView, NSWindow;

@interface SmartMailboxEditor : NSObject
{
    MFMailbox *_mailboxBeingEdited;
    MFMailbox *_mailboxBeingValidated;
    BOOL _editedMailboxIsNew;
    CriteriaUIHelper *_criteriaUIHelper;
    NSWindow *_makeNewMailboxWindow;
    NSTextField *_nameField;
    NSWindow *_makeNewFolderWindow;
    NSTextField *_groupNameField;
    NSWindow *_notEditableWindow;
    NSTextField *_searchStringField;
    NSTextView *_mailboxesTextView;
    NSView *_criteriaView;
}

+ (BOOL)mailboxIsEditable:(id)arg1;
+ (BOOL)isEditingInProgress;
@property(nonatomic) NSView *criteriaView; // @synthesize criteriaView=_criteriaView;
@property(nonatomic) NSTextView *mailboxesTextView; // @synthesize mailboxesTextView=_mailboxesTextView;
@property(nonatomic) NSTextField *searchStringField; // @synthesize searchStringField=_searchStringField;
@property(retain, nonatomic) NSWindow *notEditableWindow; // @synthesize notEditableWindow=_notEditableWindow;
@property(nonatomic) NSTextField *groupNameField; // @synthesize groupNameField=_groupNameField;
@property(retain, nonatomic) NSWindow *makeNewFolderWindow; // @synthesize makeNewFolderWindow=_makeNewFolderWindow;
@property(nonatomic) NSTextField *nameField; // @synthesize nameField=_nameField;
@property(retain, nonatomic) NSWindow *makeNewMailboxWindow; // @synthesize makeNewMailboxWindow=_makeNewMailboxWindow;
@property(retain, nonatomic) CriteriaUIHelper *criteriaUIHelper; // @synthesize criteriaUIHelper=_criteriaUIHelper;
- (void)_saveEditedMailbox;
- (void)cancelClicked:(id)arg1;
- (void)okClicked:(id)arg1;
- (void)_sheetDidEnd:(id)arg1 returnCode:(long long)arg2;
- (void)createNewMailboxGroup;
- (void)editSmartMailbox:(id)arg1 suggestedName:(id)arg2 isNew:(BOOL)arg3;
- (void)dealloc;

@end

