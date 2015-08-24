//
//  VirgilSignInViewController.m
//  TestGUI
//
//  Created by Роман Куташенко on 22.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilSignInViewController.h"
#import "NSAttributedString+Hyperlink.h"
#import "VirgilReplaceAnimator.h"
#import "VirgilKeyManager.h"

@implementation VirgilSignInViewController

HyperlinkTextField * linkForgotPassword = nil;
HyperlinkTextField * linkRegister = nil;

- (IBAction)onSignInClicked:(id)sender {
    VirgilPrivateKey * res = [VirgilKeyManager getPrivateKey : @"test-1914@yandex.ru"//@"kutashenko@gmail.com"
                                                    password : @"ram12345"];
    NSLog(@"VirgilPrivateKey = %@", res);
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString * resetPasswordLink = @"https://virgilsecurity.com/reset";
    
    linkForgotPassword = [self.view viewWithTag : 1000];
    linkRegister = [self.view viewWithTag : 1001];
    
    [linkForgotPassword setAttributedStringValue :
     [NSAttributedString hyperlinkFromString : @"Forgot password"
                                     withURL : [NSURL URLWithString : resetPasswordLink]]];
    
    [linkRegister setAttributedStringValue :
     [NSAttributedString hyperlinkFromString : @"Sign up for free."
                                     withURL : nil]];
    
    linkRegister.linkDelegate = self;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void) linkClicked:(id)sender {
    if (linkRegister == (HyperlinkTextField *)sender) {
        [self changeView : @"viewRegister"];
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
