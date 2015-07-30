/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

#import "DocumentEditor.h"

@class MailDocumentEditor, NSNotification, NSString;

@interface NoteDocumentEditor : DocumentEditor
{
    MailDocumentEditor *_mailEditor;
    id _webViewPolicyDelegate;
    struct {
        unsigned int isFirstView:1;
        unsigned int isLastView:1;
        unsigned int isEditingPaused:1;
        unsigned int isClosed:1;
        unsigned int preventClose:1;
        unsigned int otherEditorHasChanges:1;
        unsigned int isReadOnly:1;
        unsigned int contentIsPrepared:1;
    } _noteFlags;
}

+ (BOOL)usesCustomScroller;
+ (BOOL)documentType;
+ (id)documentEditors;
+ (id)documentWebPreferencesIdentifierForRichText:(BOOL)arg1;
+ (void)restoreDraftMessage:(id)arg1 withSavedState:(id)arg2;
+ (id)createEditorWithSettings:(id)arg1;
+ (id)createEditorWithEditor:(id)arg1;
+ (id)editorForNote:(id)arg1;
+ (id)editorForNote:(id)arg1 forSingleMessageViewer:(BOOL)arg2;
+ (id)editorWithSettings:(id)arg1;
+ (id)_editorWithSettings:(id)arg1 forSingleMessageViewer:(BOOL)arg2;
- (id)webViewEditor;
@property BOOL otherEditorHasChanges;
@property BOOL isReadOnly;
@property BOOL isFirstView;
@property BOOL isLastView;
@property BOOL isEditingPaused;
@property BOOL isClosed;
@property BOOL preventClose;
@property BOOL contentIsPrepared;
@property(readonly) BOOL isSelectionEditable;
- (void)showPrintPanel:(id)arg1;
- (void)_printOperationDidRun:(id)arg1 success:(BOOL)arg2 contextInfo:(void *)arg3;
- (id)initWithType:(int)arg1 settings:(id)arg2 backEnd:(id)arg3;
- (id)loadInterfaceOperation;
- (void)prepareContent;
- (void)_loadNotePaperIntoWebView:(id)arg1;
- (void)finishLoadingEditor;
- (BOOL)windowShouldClose:(id)arg1;
- (void)didLoadNotePaperIntoWebView:(id)arg1;
- (BOOL)load;
- (BOOL)shouldRecordTypeAheadEvents;
- (BOOL)shouldDisplayInspectorBar;
@property(readonly) NSNotification *documentModifiedNotification;
@property(readonly) NSString *editorID;
- (void)_documentClosed:(id)arg1;
- (void)_documentModified:(id)arg1;
- (void)beginDocumentMove;
- (void)endDocumentMove;
- (id)loadInitialDocumentOperation;
- (void)_setMailEditor:(id)arg1;
- (void)dealloc;
- (BOOL)validateUserInterfaceItem:(id)arg1;
- (BOOL)canSave;
- (void)pauseEditing;
- (void)resumeEditing;
- (void)webViewDidChange:(id)arg1;
- (void)_backupWebViewDelegates;
- (void)_restoreWebViewDelegates;
- (id)resource;
- (id)_frameSaveName;
- (id)contentWebFrame;
- (void)composePrefsChanged;
- (void)reportSaveFailure:(id)arg1;
- (void)_mailAccountsDidChange:(id)arg1;
- (id)findTarget;
- (Class)backEndClass;
- (long long)editorSharedNib;
- (id)toolbarIdentifier;
- (void)_documentsWillBeginTransfer:(id)arg1;
- (void)_documentsDidEndTransfer:(id)arg1;
- (void)editorDidLoad:(id)arg1;
- (void)editorFailedLoad:(id)arg1;
- (void)show;
- (void)windowWillClose:(id)arg1;
- (id)mailAttachmentsAdded:(id)arg1;
- (void)backEndDidLoadInitialContent:(id)arg1;
- (void)_updateScrollerStyle;
- (void)send:(id)arg1;
- (BOOL)_sendButtonShouldBeEnabled;

@end

