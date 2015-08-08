//
//  VirgilDecryptedContent.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 08.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilDecryptedContent.h"

@implementation VirgilDecryptedContent
+ (id) alloc {
    return [super alloc];
}

- (id) init {
    if ([super init]) {
        self.subject = @"";
        self.body = @"";
        self.htmlBody = @"";
    }
    return self;
}

- (id) initWithSubject:(NSString *)asubject
                  body:(NSString *)abody
              htmlBody:(NSString *)ahtmlBody {
    if ([super init]) {
        self.subject = [[NSString alloc] initWithString:asubject];
        self.body = [[NSString alloc] initWithString:abody];
        self.htmlBody = [[NSString alloc] initWithString:ahtmlBody];
    }
    return self;
}

@end
