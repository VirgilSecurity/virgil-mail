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

#import "VirgilKeychainWrapper.h"

@implementation VirgilKeychainWrapper

+ (NSMutableDictionary *) getKeychainQuery : (NSString *)service
                                   account : (NSString *)account {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword, (id)kSecClass,
            service, (id)kSecAttrService,
            account, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock, (id)kSecAttrAccessible,
            nil];
}

+ (void) save : (NSString *)service
      account : (NSString *)account
         data : (id)data {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service account:account];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (id) load : (NSString *)service
    account : (NSString *)account {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service account:account];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        }
        @finally {}
    }
    if (keyData) CFRelease(keyData);
    return ret;
}

+ (void) remove : (NSString *)service
        account : (NSString *)account {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service account:account];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

@end