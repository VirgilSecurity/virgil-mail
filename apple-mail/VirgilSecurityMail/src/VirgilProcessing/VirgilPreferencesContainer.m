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

#import "VirgilPreferencesContainer.h"
#import "VirgilPreferencesHelper.h"

@implementation VirgilPreferencesContainer

static NSString * _NeedAskToDecrypt = @"_NeedAskToDecrypt";
static NSString * _UseEncryption = @"_UseEncryption";
static NSString * _SaveDecriptionAccept = @"_SaveDecriptionAccept";
static NSString * _SaveDecriptionAcceptTime = @"_SaveDecriptionAcceptTime";
static NSString * _NeedShowWellcome = @"_NeedShowWellcome";

+ (BOOL) isNeedAskToDecrypt {
    if (NO == [VirgilPreferencesHelper isKeyPresent : _NeedAskToDecrypt]) {
        return NO;
    }
    return [VirgilPreferencesHelper getBoolForKey : _NeedAskToDecrypt];
}

+ (void) setNeedAskToDecrypt : (BOOL)needAsk {
    [VirgilPreferencesHelper setBoolForKey : needAsk
                                       key : _NeedAskToDecrypt];
}

+ (BOOL) isUseEncryption {
    if (NO == [VirgilPreferencesHelper isKeyPresent : _UseEncryption]) {
        return YES;
    }
    return [VirgilPreferencesHelper getBoolForKey : _UseEncryption];
}

+ (void) setUseEncryption : (BOOL)use {
    [VirgilPreferencesHelper setBoolForKey : use
                                       key : _UseEncryption];
}

+ (BOOL) isSaveDecryptionAccept {
    if (NO == [VirgilPreferencesHelper isKeyPresent : _SaveDecriptionAccept]) {
        return NO;
    }
    return [VirgilPreferencesHelper getBoolForKey : _SaveDecriptionAccept];
}

+ (void) setSaveDecryptionAccept : (BOOL)use {
    [VirgilPreferencesHelper setBoolForKey : use
                                       key : _SaveDecriptionAccept];
}

+ (BOOL) isNeedShowWellcome {
    if (NO == [VirgilPreferencesHelper isKeyPresent : _NeedShowWellcome]) {
        return YES;
    }
    return [VirgilPreferencesHelper getBoolForKey : _NeedShowWellcome];
}
+ (void) setNeedShowWellcome : (BOOL)use {
    [VirgilPreferencesHelper setBoolForKey : use
                                       key : _NeedShowWellcome];
}

+ (NSInteger) acceptSaveTimeMin {
    if (NO == [VirgilPreferencesHelper isKeyPresent : _SaveDecriptionAcceptTime]) {
        return 1;
    }
    return [VirgilPreferencesHelper getIntForkey : _SaveDecriptionAcceptTime];
}

+ (void) setSaveAcceptTimeMin : (NSInteger) timeInMin {
    [VirgilPreferencesHelper setIntForKey : timeInMin
                                      key : _SaveDecriptionAcceptTime];
}

@end