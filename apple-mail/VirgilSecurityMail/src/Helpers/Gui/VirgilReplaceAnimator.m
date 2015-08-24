//
//  VirgilReplaceAnimator.m
//  TestGUI
//
//  Created by Роман Куташенко on 22.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilReplaceAnimator.h"

@implementation VirgilReplaceAnimator

#define kPushAnimationDuration 0.3f

- (void)animatePresentationOfViewController : (NSViewController *)viewController
                         fromViewController : (NSViewController *)fromViewController {
    NSWindow * window = fromViewController.view.window;
    if (nil != window) {
        [NSAnimationContext runAnimationGroup : ^(NSAnimationContext *context) {
            fromViewController.view.animator.alphaValue = 0;
        } completionHandler:^{
            viewController.view.alphaValue = 0;
            window.contentViewController = viewController;
            viewController.view.animator.alphaValue = 1.0;
        }];
    }
}

- (void)animateDismissalOfViewController : (NSViewController *)viewController
                      fromViewController : (NSViewController *)fromViewController {
    NSWindow * window = fromViewController.view.window;
    if (nil != window) {
        [NSAnimationContext runAnimationGroup : ^(NSAnimationContext *context) {
            viewController.view.animator.alphaValue = 0;
        } completionHandler:^{
            fromViewController.view.alphaValue = 0;
            window.contentViewController = fromViewController;
            fromViewController.view.animator.alphaValue = 1.0;
        }];
    }
}

@end
