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

#import "VirgilPreferences.h"
#import "VirgilPreferencesContainer.h"
#import "VirgilPreferencesWorker.h"

@implementation VirgilPreferences

-(id)init {
	self = [super init];
	if (self) {
//		NSDictionary *defaults = [[NSDictionary alloc] initWithContentsOfFile:[[GPGMailBundle bundle] pathForResource:@"SparkleDefaults" ofType:@"plist"]];
//		GPGOptions *options = [GPGOptions sharedOptions];
//		[options registerDefaults:defaults];
	}
	
	return self;
}

- (IBAction)onOptionChanged:(id)sender {
// 1000 - Ask before decrypt
// 1001 - Use encryption
// 1002 - Auto check updates
// 1003 - Install automaticaly
    BOOL isOn = NSOnState == [sender state];
    switch ([sender tag]) {
        case 1000:
            [VirgilPreferencesContainer setNeedAskToDecrypt : isOn];
            break;
            
        case 1001:
            [VirgilPreferencesContainer setUseEncryption : isOn];
            break;
            
        case 1002:
            break;
            
        case 1003:
            break;
            
        default:
            return;
    }

}

- (IBAction)onCheckNowClick:(id)sender {
}

- (void)willBeDisplayed {
    // 1000 - Ask before decrypt
    // 1001 - Use encryption
    // 1002 - Auto check updates
    // 1003 - Install automaticaly
    
    [self loadStateForTag : 1000
                    state :
                    [VirgilPreferencesContainer isNeedAskToDecrypt] ? NSOnState :
                                                                      NSOffState];
    [self loadStateForTag : 1001
                    state :
                    [VirgilPreferencesContainer isUseEncryption] ? NSOnState :
                                                                   NSOffState];
}

- (void) loadStateForTag : (NSInteger) tag
                   state : (BOOL) state {
    NSString * ourPrefName = [NSPreferences virgilPreferencesName];
    NSBox * ourPrefView = [self viewForPreferenceNamed : ourPrefName];
    if (nil == ourPrefView) return;
    
    NSButton * element = [ourPrefView viewWithTag : tag];
    [element setState : state];
}


- (BOOL)isResizable {
	return NO;
}



- (void)checkForUpdates:(id)sender {
	// NSString *updaterPath = @"/Library/Application Support/GPGTools/GPGMail_Updater.app/Contents/MacOS/GPGMail_Updater";
	// [GPGTask launchGeneralTask:updaterPath withArguments:@[@"checkNow"]];
}

@end
