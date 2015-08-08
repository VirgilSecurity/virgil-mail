//
//  VirgilDecryptedMail.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 06.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilDecryptedMail.h"
#import "MessageBody.h"
#import "Message.h"
#import "VirgilClassNameResolver.h"

@implementation VirgilDecryptedMail

+(id)alloc{
    return [super alloc];
}

-(id)init{
    _curMailHash = 0;
    _mailParts = [[NSMutableDictionary alloc] init];
    return [super init];
}

- (void) clear {
    _curMailHash = 0;
    [_mailParts removeAllObjects];
}

- (BOOL) isEmpty {
    return !_curMailHash;
}

- (NSString *) hashVal:(id)someId {
    return [NSString stringWithFormat:@"%lu", (NSUInteger)someId];
}

- (NSString *) invalidHashVal {
    return [NSString stringWithFormat:@"%lu", (NSUInteger)0];
}

- (void) setCurrentMailHash:(id)hash {
    if ([self isCurrentMail:hash]) {
        [self clear];
    }
    _curMailHash = [self hashVal:hash];
}

- (BOOL) isCurrentMail:(id)someMail {
    return _curMailHash == [self hashVal:someMail];
}

- (void) addPart:(id)part partHash:(id)partHash {
    if ([self isEmpty]) return;
    [_mailParts setValue:part forKey:[self hashVal:partHash]];
}

- (id) partByHash:(id)partHash {
    if ([self isEmpty]) return nil;
    return [_mailParts	valueForKey:[self hashVal:partHash]];
}

/*
+ (MimeBody *) create:(VirgilEncryptorContainer *) dataContainer {
    // 1. Create a new Message using messageWithRFC822Data:
    // This creates the message store automatically!
    Message *decryptedMessage;
    MimeBody *decryptedMimeBody;
    
    NSData * messageBodyData = [(NSString *)@"<h1>Test !!!</h1>" dataUsingEncoding:NSUTF8StringEncoding];
    
    decryptedMessage = [[VirgilClassNameResolver resolveClassFromName:@"Message"]
                            messageWithRFC822Data:messageBodyData sanitizeData:YES];
    
    
    // 2. Set message info from the original encrypted message.
    //[decryptedMessage setMessageInfoFromMessage:dataContainer.originalMessage];
    
    NSLog(@"1 >>> %@", [decryptedMessage subject]);
    
    [decryptedMessage setSubject:@"CHANGED SUBJECT !!!"];
    
    NSLog(@"2 >>> %@", [decryptedMessage subject]);
    
    NSLog(@"3 >>> %@", [dataContainer.originalMessage subject]);
    
    decryptedMimeBody = [decryptedMessage messageBody];
    
    
    // 3. Call message body updating flags to set the correct flags for the new message.
    // This will setup the decrypted message, run through all parts and find signature part.
    // We'll save the message body for later, since it will be used to do a last
    // decodeWithContext and the output returned.
    // Fake the message flags on the decrypted message.
    // messageBodyUpdatingFlags: calls isMimeEncrypted. Set MimeEncrypted on the message,
    // so the correct info is returned.
    //[decryptedMessage setIvar:@"MimeEncrypted" value:@YES];
    //decryptedMimeBody = [decryptedMessage messageBodyUpdatingFlags:YES];
    
    // Top Level part reparses the message. This method doesn't.
    //MimePart *topPart = [self topPart];
    // Set the decrypted message here, otherwise we run into a memory problem.
    //[topPart setDecryptedMessageBody:decryptedMimeBody isEncrypted:self.PGPEncrypted isSigned:self.PGPSigned error:self.PGPError];
    //self.PGPDecryptedBody = self.decryptedMessageBody;
    
    return decryptedMimeBody;
}
*/
@end
