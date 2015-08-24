//
//  VirgilRegisterViewController.m
//  TestGUI
//
//  Created by Роман Куташенко on 22.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilRegisterViewController.h"
#import "VirgilKeyManager.h"
#import "VirgilReplaceAnimator.h"

@implementation VirgilRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onSignUpClicked:(id)sender {
    NSTextField * emailField = [self.view viewWithTag : 1000];
    NSSecureTextField * passwordField = [self.view viewWithTag : 1001];
    NSSecureTextField * passwordRetypeField = [self.view viewWithTag : 1002];
    
    if (!emailField || !passwordField || !passwordRetypeField) return;
    
    NSString * email = [emailField stringValue];
    NSString * password = [passwordField stringValue];
    NSString * passwordRetype = [passwordRetypeField stringValue];
    
    // TODO: Need validation
    
    NSLog(@"onSignUpClicked for %@:%@", email, password);
    
    if ([VirgilKeyManager createAccount : email
                           withPassword : password]) {
        [self changeView : @"viewEmailConfirm"];
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

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

@end
