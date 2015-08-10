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

- (void) addAttachement:(id)attach attachHash:(id)attachHash {
    if ([self isEmpty]) return;
    [_mailParts setValue:attach forKey:attachHash];
}

- (id) partByHash:(id)partHash {
    if ([self isEmpty]) {
        NSLog(@"Error: PART NOT PRESENT");
        return nil;
    }
    return [_mailParts	valueForKey:[self hashVal:partHash]];
}

- (id) attachementByHash:(id)attachHash {
    if ([self isEmpty]) {
        NSLog(@"Error: PART NOT PRESENT");
        return nil;
    }
    return [_mailParts	valueForKey:attachHash];
}

@end
