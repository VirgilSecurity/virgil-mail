//
//  VirgilEncryptedContent.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 01.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilEncryptedContent : NSObject {
@public
    NSData * emailData;
    NSData * signature;
}

- (id) init;
- (id) initWithEmailData:(NSData *)emailData andSignature:(NSData *)signature;

@property (retain) NSData * emailData;
@property (retain) NSData * signature;

@end
