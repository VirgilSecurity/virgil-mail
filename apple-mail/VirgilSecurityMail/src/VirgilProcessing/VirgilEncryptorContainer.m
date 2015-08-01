//
//  VirgilEncryptorContainer.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 01.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilEncryptorContainer.h"

@implementation VirgilEncryptorContainer

+(id)alloc{
    return [super alloc];
}

-(id)init{
    self.isEncrypted = NO;
    return [super init];
}
@end
