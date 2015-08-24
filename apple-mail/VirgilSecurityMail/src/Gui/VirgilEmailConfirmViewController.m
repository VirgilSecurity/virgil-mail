//
//  VirgilEmailConfirmViewController.m
//  TestGUI
//
//  Created by Роман Куташенко on 22.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilEmailConfirmViewController.h"
#import "VirgilKeyManager.h"
#import "VirgilReplaceAnimator.h"

@interface VirgilEmailConfirmViewController ()

@end

@implementation VirgilEmailConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)onAcceptClicked : (id)sender {
    NSTextField * emailField = [self.view viewWithTag : 1000];
    if (!emailField) return;
    if ([VirgilKeyManager confirmAccountCreationWithCode : [emailField stringValue]]) {
        [self changeView : @"viewSignIn"];
    }
}

- (BOOL) changeView : (NSString *) newViewName {
    NSStoryboard * storyboard = [self storyboard];
    if (nil == storyboard) return NO;
    NSViewController * controller =
    (NSViewController*)[storyboard instantiateControllerWithIdentifier : newViewName];
    if (nil == controller) return NO;
    [self presentViewController : controller
                       animator : [[VirgilReplaceAnimator alloc] init]];
    return YES;
}

@end
