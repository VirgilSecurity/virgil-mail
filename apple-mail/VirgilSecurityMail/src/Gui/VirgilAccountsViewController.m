/**
 * Copyright (C) 2015 Virgil Security Inc.
 *
 * Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     (1) Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *     (2) Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *     (3) Neither the name of the copyright holder nor the names of its
 *     contributors may be used to endorse or promote products derived from
 *     this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "VirgilAccountsViewController.h"
#import "VirgilAccountItem.h"
#import "VirgilProcessingManager.h"
#import "VirgilActionsViewController.h"
#import "NSViewController+VirgilView.h"
#import "VirgilLog.h"

@implementation VirgilAccountsViewController

@synthesize items = _items;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self items];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return  self.items.count;
}

- (NSInteger)numberOfColumns:(NSTableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 45.0f;
}

- (VirgilAccountItem *) info2item : (VirgilAccountInfo *)info {
    VirgilAccountItem * item = [VirgilAccountItem new];
    item.userImage = [NSImage imageNamed:@"account"];
    item.name = info.name;
    item.account = info.account;
    item.status = info.status;
    
    if (statusAllDone == info.status) item.accountImage = [NSImage imageNamed:@"ok"];
    else if (statusPublicKeyNotPresent == info.status) item.accountImage = [NSImage imageNamed:@"problem"];
    else if (statusPublicKeyPresent == info.status) item.accountImage = [NSImage imageNamed:@"attention"];
    else if (statusWaitActivation == info.status) item.accountImage = [NSImage imageNamed:@"attention"];
    return item;
}

- (void) updateAccountInfo : (VirgilAccountInfo *)newInfo {
    NSMutableArray * ar = [_items mutableCopy];
    for (VirgilAccountItem * item in ar) {
        if ([item.account isEqualToString:newInfo.account]) {
            VirgilAccountItem * newItem = [self info2item:newInfo];
            item.userImage = [NSImage imageNamed:@"account"];
            item.name = newItem.name;
            item.account = newItem.account;
            item.status = newItem.status;
            item.accountImage = newItem.accountImage;
            break;
        }
    }
    _items = [ar copy];
    NSString * updateAccount = _selectedAccount;
    [_arrayController setContent:_items];
    [self selectAccount:updateAccount];
}

- (void) updateSelection {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC),
                   dispatch_get_main_queue(), ^{
                       [self selectAccount:_selectedAccount];
                   });

}

- (NSArray *)items {
    if (nil == _items) {
        NSArray * accounts = [VirgilProcessingManager accountsList];
        
        NSMutableArray * ar = [NSMutableArray new];
        for (NSString * account in accounts) {
            VirgilAccountInfo * info = [[VirgilProcessingManager sharedInstance] accountInfo:account checkInCloud:NO];
            VirgilAccountItem * item = [self info2item:info];
            [ar addObject:item];
            
            if (statusUnknown == item.status) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    VirgilAccountInfo * infoCloud =
                        [[VirgilProcessingManager sharedInstance] accountInfo:account checkInCloud:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateAccountInfo:infoCloud];
                    });
                });
            }
            
            if (_selectedAccount && [_selectedAccount isEqualToString:info.account]) {
                [self updateSelection];
            }
        }
        _items = [ar copy];
        if (nil == _selectedAccount && _items && _items.count) {
            VirgilAccountInfo * info = [_items objectAtIndex:0];
            _selectedAccount = info.account;
            [self updateSelection];
        }
    }
    return _items;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    VirgilAccountItem * selectedItem = self.arrayController.selectedObjects[0];
    VirgilActionsViewController * controller = (VirgilActionsViewController *)[self showAccountActions:selectedItem];
    controller.account = selectedItem.account;
    controller.delegate = self;
    _selectedAccount = selectedItem.account;
}

- (NSViewController *) showAccountActions : (VirgilAccountItem *)accountItem {
    _accountName.stringValue = accountItem.name;
    _accountEmail.stringValue = accountItem.account;
    
    if (statusAllDone == accountItem.status) return [self switchEmbedViewTo : @"viewAccountPresent"];
    else if (statusPublicKeyNotPresent == accountItem.status) return [self switchEmbedViewTo : @"viewNoAccount"];
    else if (statusPublicKeyPresent == accountItem.status) return [self switchEmbedViewTo : @"viewGetKey"];
    else if (statusWaitActivation == accountItem.status) return [self switchEmbedViewTo : @"viewWaitConfirmation"];
    else if (statusWaitActivation == accountItem.status) return [self switchEmbedViewTo : @"viewNoStatus"];
    
    return nil;
}

- (NSViewController *) switchEmbedViewTo : (NSString *)viewName {
    NSStoryboard * storyboard = [self storyboard];
    
    if (nil == storyboard) return nil;
    NSViewController * controller = [storyboard instantiateControllerWithIdentifier : viewName];
    
    if (nil == controller) return nil;
    
    [[[_embedView subviews] lastObject] removeFromSuperview];
    [_embedView addSubview : controller.view];
    return controller;
}

- (IBAction)onCloseClicked:(id)sender {
    [self closeWindow];
}

- (void) selectAccount : (NSString *) account {
    for (VirgilAccountItem * item in [_arrayController content]) {
        if ([item.account isEqualToString:account]) {
            [_arrayController setSelectedObjects:[NSArray arrayWithObject:item]];
            break;
        }
    }
    [self tableViewSelectionDidChange:nil];
}


- (void) askRefresh {
    NSString * updateAccount = _selectedAccount;
    _items = nil;
    [self items];
    [_arrayController setContent:_items];
    [self selectAccount:updateAccount];
}

@end
