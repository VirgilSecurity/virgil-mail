//
//  VirgilDecryptedMail.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 06.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MimeBody.h"

@interface VirgilDecryptedMail : NSObject
- (void) clear;
- (BOOL) isEmpty;
- (void) setCurrentMailHash:(id)hash;
- (BOOL) isCurrentMail:(id)someMail;
- (void) addPart:(id)part partHash:(id)partHash;
- (id) partByHash:(id)partHash;

- (NSString *) hashVal:(id)someId;
- (NSString *) invalidHashVal;

@property (readonly) NSString * curMailHash;
@property (readonly) NSMutableDictionary * mailParts;
//@property (readonly) NSString * subject;

@end
