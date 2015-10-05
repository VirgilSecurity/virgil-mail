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

#import "VirgilComposeViewController.h"
#import <ComposeViewController.h>
#import "VirgilLog.h"

@implementation VirgilComposeViewController

- (void)MAFinishUICustomization:(id)arg1 {
    [self MAFinishUICustomization:arg1];
}

- (void)MA_newComposeViewControllerCommonInit {
    [self MA_newComposeViewControllerCommonInit];
}

- (id)MAInitWithCoder:(id)arg1 {
    id res = [self MAInitWithCoder:arg1];
    
    VLogInfo(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> MAInitWithCoder");
    
    NSTextField * fromLabel = [self valueForKey:@"fromLabel"];
    [fromLabel setBackgroundColor:[NSColor yellowColor]];
    [fromLabel setEditable:NO];
    [fromLabel setEditable:YES];
    return res;
}

- (id)MAInitWithNibName:(id)arg1 bundle:(id)arg2 {
    id res = [self MAInitWithNibName:arg1 bundle:arg2];
    
    VLogInfo(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> MAInitWithNibName");
    
    NSTextField * fromLabel = [self valueForKey:@"fromLabel"];
    [fromLabel setBackgroundColor:[NSColor yellowColor]];
    [fromLabel setEditable:NO];
    [fromLabel setEditable:YES];
    return res;
}

@end
