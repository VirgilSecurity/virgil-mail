/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

#import "NSCopying.h"

@class Conversation, MCMessage, MCMessageBody, MCMessageHeaders, MUIWebDocument, NSArray, NSData, NSDate, NSImage, NSIndexSet, NSMutableSet, NSString, WebDocumentGenerator;

@interface ConversationMember : NSObject <NSCopying>
{
    NSMutableSet *_primitiveMessages;
    NSMutableSet *_primaryMessages;
    NSMutableSet *_hiddenMessages;
    BOOL _isPrimary;
    BOOL _isDeleted;
    unsigned long long _messageNumber;
    MCMessage *_originalMessage;
    NSImage *_senderImage;
    BOOL _senderIsVIP;
    int _conversationPosition;
    BOOL _primitiveIsUnread;
    BOOL _primitiveIsFlagged;
    NSIndexSet *_primitiveFlagColors;
    unsigned long long _primitiveJunkStatus;
    BOOL _isEncrypted;
    BOOL _isSigned;
    NSArray *_signers;
    NSArray *_signerNames;
    BOOL _bodyCached;
    BOOL _registeredForNotifications;
    BOOL _shouldLogConversationViewUpdates;
    BOOL _senderImageLoadedOrTimedOut;
    MCMessageHeaders *_headers;
    Conversation *_conversation;
    NSArray *_messages;
    WebDocumentGenerator *_documentGenerator;
}

+ (id)keyPathsForValuesAffectingJunkStatus;
+ (id)keyPathsForValuesAffectingFlagColors;
+ (id)keyPathsForValuesAffectingIsFlagged;
+ (id)keyPathsForValuesAffectingIsUnread;
+ (BOOL)automaticallyNotifiesObserversForKey:(id)arg1;
+ (id)keyPathsForValuesAffectingMessageBody;
+ (id)keyPathsForValuesAffectingAttachmentSize;
+ (id)keyPathsForValuesAffectingNumberOfAttachments;
+ (id)keyPathsForValuesAffectingMailboxName;
+ (id)keyPathsForValuesAffectingDateReceived;
+ (id)keyPathsForValuesAffectingSubject;
+ (id)keyPathsForValuesAffectingBccRecipients;
+ (id)keyPathsForValuesAffectingCcRecipients;
+ (id)keyPathsForValuesAffectingToRecipients;
+ (id)keyPathsForValuesAffectingSender;
+ (id)keyPathsForValuesAffectingMessageIDHeaderDigest;
+ (id)keyPathsForValuesAffectingWebDocument;
+ (id)flagsAffectingConversationMember;
@property(nonatomic) BOOL senderImageLoadedOrTimedOut; // @synthesize senderImageLoadedOrTimedOut=_senderImageLoadedOrTimedOut;
@property(readonly, nonatomic) BOOL shouldLogConversationViewUpdates; // @synthesize shouldLogConversationViewUpdates=_shouldLogConversationViewUpdates;
@property(nonatomic) BOOL registeredForNotifications; // @synthesize registeredForNotifications=_registeredForNotifications;
@property(nonatomic) BOOL bodyCached; // @synthesize bodyCached=_bodyCached;
@property(retain, nonatomic) WebDocumentGenerator *documentGenerator; // @synthesize documentGenerator=_documentGenerator;
@property(copy, nonatomic) NSArray *messages; // @synthesize messages=_messages;
@property(nonatomic) Conversation *conversation; // @synthesize conversation=_conversation;
@property(retain, nonatomic) MCMessageHeaders *headers; // @synthesize headers=_headers;
- (id)messagesInSameMailboxAsOriginalMessage;
- (BOOL)isPrimaryMessage:(id)arg1;
- (void)unhideMessage:(id)arg1;
- (void)hideMessage:(id)arg1;
- (void)removeMessage:(id)arg1;
- (void)addMessage:(id)arg1 isPrimary:(BOOL)arg2;
- (id)_preferredOriginalMessage;
- (void)_reloadOriginalMessage;
- (BOOL)_messageIsInSent:(id)arg1;
- (BOOL)_messageIsInTrashJunkOrOutbox:(id)arg1;
- (BOOL)_messageIsDeleted:(id)arg1;
- (BOOL)_shouldDisplayMessage:(id)arg1;
- (void)updateLastViewedDate;
- (void)_reloadSenderIsVIP;
- (void)_VIPSendersDidChange:(id)arg1;
- (void)_reloadValuesForAggregateFlags;
- (void)flagsChangedForMessage:(id)arg1;
@property(nonatomic) unsigned long long junkStatus;
@property(copy, nonatomic) NSIndexSet *flagColors;
@property(nonatomic) BOOL isFlagged;
@property(nonatomic) BOOL isUnread;
- (void)_addressPhotoChanged:(id)arg1;
- (void)_addressPhotoLoaded:(id)arg1;
- (void)_asyncLoadSenderImage;
- (void)_senderImageTimedOut;
@property(nonatomic) unsigned long long primitiveJunkStatus;
@property(copy, nonatomic) NSIndexSet *primitiveFlagColors;
@property(nonatomic) BOOL primitiveIsFlagged;
@property(nonatomic) BOOL primitiveIsUnread;
@property(nonatomic) int conversationPosition;
@property(nonatomic) BOOL senderIsVIP;
@property(retain, nonatomic) NSImage *senderImage;
@property(retain, nonatomic) MCMessage *originalMessage;
@property(nonatomic) unsigned long long messageNumber;
@property(nonatomic) BOOL isDeleted;
@property(nonatomic) BOOL isPrimary;
- (void)_reloadSecurityProperties;
@property(retain, nonatomic) NSArray *signerNames;
@property(retain, nonatomic) NSArray *signers;
@property(nonatomic) BOOL isSigned;
@property(nonatomic) BOOL isEncrypted;
@property(readonly, nonatomic) MCMessageBody *messageBody;
@property(readonly, nonatomic) unsigned long long attachmentSize;
@property(readonly, nonatomic) unsigned long long numberOfAttachments;
@property(readonly, nonatomic) NSString *mailboxName;
@property(readonly, nonatomic) NSDate *dateReceived;
@property(readonly, nonatomic) NSString *subject;
@property(readonly, nonatomic) NSArray *bccRecipients;
@property(readonly, nonatomic) NSArray *ccRecipients;
@property(readonly, nonatomic) NSArray *toRecipients;
@property(readonly, nonatomic) NSString *sender;
@property(readonly, nonatomic) NSData *messageIDHeaderDigest;
@property(readonly, nonatomic) MUIWebDocument *webDocument;
- (void)cancelLoad;
- (void)asyncLoad:(id)arg1;
- (void)invalidate;
- (id)description;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (void)dealloc;
- (id)initWithMessages:(id)arg1 primaryMessages:(id)arg2 forConversation:(id)arg3;
- (id)initWithMessage:(id)arg1 isPrimary:(BOOL)arg2 forConversation:(id)arg3;
- (id)init;

@end

