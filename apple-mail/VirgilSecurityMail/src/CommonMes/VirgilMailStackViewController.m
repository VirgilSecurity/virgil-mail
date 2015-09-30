//
//  VirgilMailStackViewController.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 9/28/15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilMailStackViewController.h"
#import "VirgilLog.h"

@implementation VirgilMailStackViewController

- (id)MA_messageViewForItem:(id)arg1 createIfNeeded:(BOOL)arg2 {
    VLogInfo(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>> MA_messageViewForItem %@   %hhd", arg1, arg2);
    return [self MA_messageViewForItem:arg1 createIfNeeded:arg2];
}

@end
