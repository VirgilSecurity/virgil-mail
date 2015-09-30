//
//  VirgilMessageListCell.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 9/28/15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMessageListCell.h"
#import "VirgilLog.h"

#define LogRect(RECT) NSLog(@"%s: (%0.0f, %0.0f) %0.0f x %0.0f", #RECT, RECT.origin.x, RECT.origin.y, RECT.size.width, RECT.size.height)

@implementation VirgilMessageListCell

- (void)MASetObjectValue:(id)arg1 {
    [self MASetObjectValue:arg1];
    VLogInfo(@" >>>>>>>>>>>>>> MASetObjectValue : %@", arg1);
}

- (void)MADrawInteriorWithFrame:(struct CGRect)arg1 inView:(id)arg2 {
    [self MADrawInteriorWithFrame:arg1 inView:arg2];
    VLogInfo(@" >>>>>>>>>>>>>> MASetObjectValue");
    LogRect(arg1);
}

@end
