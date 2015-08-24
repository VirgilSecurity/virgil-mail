//
//  VirgilReplaceSegue.m
//  TestGUI
//
//  Created by Роман Куташенко on 22.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilReplaceSegue.h"
#import "VirgilReplaceAnimator.h"

@implementation VirgilReplaceSegue

- (void)perform {
    NSViewController * fromViewController = self.sourceController;
    NSViewController * toViewController = self.destinationController;
    
    if (nil != fromViewController && nil != toViewController) {
        [fromViewController presentViewController : toViewController
                                         animator : [[VirgilReplaceAnimator alloc] init]];
    }
}

@end
