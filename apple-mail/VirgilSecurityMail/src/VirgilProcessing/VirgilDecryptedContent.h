//
//  VirgilDecryptedContent.h
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 08.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirgilDecryptedContent : NSObject {
@public
    NSString * subject;
    NSString * body;
    NSString * htmlBody;
}

- (id) init;
- (id) initWithSubject:(NSString *)asubject
                  body:(NSString *)abody
              htmlBody:(NSString *)ahtmlBody;

@property (retain) NSString * subject;
@property (retain) NSString * body;
@property (retain) NSString * htmlBody;

@end
