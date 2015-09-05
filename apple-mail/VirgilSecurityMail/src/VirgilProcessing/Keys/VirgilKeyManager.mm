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

#import "VirgilKeyManager.h"
#import "VirgilPrivateKeyManager.h"
#import "VirgilHelpers.h"

#include <iostream>
#include <fstream>
#include <algorithm>
#include <iterator>
#include <string>
#include <stdexcept>
#include <map>

#include <virgil/crypto/VirgilByteArray.h>
using virgil::crypto::VirgilByteArray;

#include <virgil/crypto/VirgilKeyPair.h>
using virgil::crypto::VirgilKeyPair;

#include <virgil/crypto/foundation/VirgilBase64.h>
using virgil::crypto::foundation::VirgilBase64;

#include <virgil/sdk/keys/model/PublicKey.h>
using virgil::sdk::keys::model::PublicKey;

#include <virgil/sdk/keys/model/UserDataType.h>
using virgil::sdk::keys::model::UserDataType;

#include <virgil/sdk/keys/http/Connection.h>
using virgil::sdk::keys::http::Connection;

#include <virgil/sdk/keys/client/KeysClient.h>
using virgil::sdk::keys::client::KeysClient;

#include <virgil/sdk/keys/client/Credentials.h>
using virgil::sdk::keys::client::Credentials;

#include <virgil/sdk/keys/model/UserData.h>
using virgil::sdk::keys::model::UserData;

@implementation VirgilKeyManager : NSObject

//! _lastError - contains user friendly error string
static NSString * _lastError = nil;

//! newAccountInfo - holder of data for account creation
struct {
    VirgilPublicKey * publicKeyInfo;
    VirgilPrivateKey * privateKeyInfo;
    PublicKey keyWithUserData;
} newAccountInfo;

/**
 * @brief Get public key by account (email)
 * @param account - email
 * @return VirgilPublicKey - instance | nil - error occured, get error with [VirgilKeyManager lastError]
 */
+ (VirgilPublicKey *) getPublicKey:(NSString *) account {
    _lastError = nil;
    
    if (nil == account) return nil;
    try {
        
        const std::string _account([VirgilHelpers _strNS2Std : account]);
        KeysClient keysClient([VirgilHelpers _strNS2Std : [VirgilHelpers applicationToken]],
                              [VirgilHelpers _strNS2Std : [VirgilHelpers keysURLBase]]);
        const PublicKey publicKey(keysClient.publicKey().grab(_account));
        
        const std::string _key(virgil::crypto::bytes2str(publicKey.key()));
        
        NSString *nsAccountID = [NSString stringWithCString:publicKey.accountId().c_str()
                                                   encoding:NSUTF8StringEncoding];
        NSString *nsKey = [NSString stringWithCString:_key.c_str()
                                             encoding:NSUTF8StringEncoding];
        NSString *nsKeyID = [NSString stringWithCString:publicKey.publicKeyId().c_str()
                                               encoding:NSUTF8StringEncoding];
        
        VirgilPublicKey * res = [[VirgilPublicKey alloc] initAccountID:nsAccountID
                                         publicKeyID:nsKeyID
                                           publicKey:nsKey];
        return res;
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        [VirgilKeyManager setErrorString : [NSString stringWithFormat:@"getPublicKey : %s", _error.c_str()]];
    }
    return nil;
}

/**
 * @brief Create key pair, register at Key service
 * @param account - email
 * @param keyPassword - password for keys encryption
 * @param containerType - container type {easy, normal, paranoic}
 * @param containerPassword - Container's password
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) createAccount : (NSString *) account
           keyPassword : (NSString *) keyPassword
         containerType : (VirgilContainerType) containerType
     containerPassword : (NSString *) containerPassword {
    _lastError = nil;
    newAccountInfo.publicKeyInfo = nil;
    if (nil == account) {
        [VirgilKeyManager setErrorString : @"wrong params for account creation"];
        return NO;
    }
    
    // Prepare account
    const std::string _accountData([VirgilHelpers _strNS2Std : account]);
    VirgilByteArray baAccount(_accountData.begin(), _accountData.end());
    
    // Prepare password
    std::string _passwordData;
    if (nil != keyPassword) {
        _passwordData = std::string([keyPassword UTF8String]);
    }
    VirgilByteArray baPassword(_passwordData.begin(), _passwordData.end());
    
    try {
        // Generate keys
        const VirgilKeyPair _keyPair(baPassword);
        const VirgilByteArray _publicKey(_keyPair.publicKey());
        const VirgilByteArray _privateKey(_keyPair.privateKey());
        
        NSString * nsPrivateKey = [VirgilHelpers _strStd2NS : virgil::crypto::bytes2str(_privateKey)];
        newAccountInfo.privateKeyInfo =
        [[VirgilPrivateKey alloc] initAccount : account
                                containerType : containerType
                                   privateKey : nsPrivateKey
                                  keyPassword : keyPassword
                            containerPassword : containerPassword];
        
        // Register user
        Credentials credentials(_privateKey, _passwordData);
        const std::string uuid([VirgilHelpers _uuid]);
        KeysClient keysClient(
                              [VirgilHelpers _strNS2Std : [VirgilHelpers applicationToken]],
                              [VirgilHelpers _strNS2Std : [VirgilHelpers keysURLBase]]
                              );
        const UserData userData = UserData::email(_accountData);
        PublicKey publicKey = keysClient.publicKey().add(_publicKey, {userData}, credentials, uuid);
        newAccountInfo.keyWithUserData = publicKey;
        
        const std::string _key(virgil::crypto::bytes2str(publicKey.key()));
        
        newAccountInfo.publicKeyInfo =
        [[VirgilPublicKey alloc] initAccountID : [VirgilHelpers _strStd2NS : publicKey.accountId()]
                                   publicKeyID : [VirgilHelpers _strStd2NS : publicKey.publicKeyId()]
                                     publicKey : [VirgilHelpers _strStd2NS : _key]];
        return YES;
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        [VirgilKeyManager setErrorString : [NSString stringWithFormat:@"getPublicKey : %s", _error.c_str()]];
    }
    
    return NO;
}

/**
 * @brief Confirm account creation with received (by email) code
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) confirmAccountCreationWithCode : (NSString *) code {
    _lastError = nil;
    if (nil == code ||
        nil == newAccountInfo.publicKeyInfo ||
        newAccountInfo.keyWithUserData.userData().empty()) {
        [VirgilKeyManager setErrorString : @"wrong params for account confirmation"];
        return NO;
    }
    try {
        const std::string userDataId(newAccountInfo.keyWithUserData.userData().front().userDataId());
        const std::string confirmationCode([VirgilHelpers _strNS2Std : code]);
        
        KeysClient keysClient(
                              [VirgilHelpers _strNS2Std : [VirgilHelpers applicationToken]],
                              [VirgilHelpers _strNS2Std : [VirgilHelpers keysURLBase]]
                              );
        keysClient.userData().confirm(userDataId, confirmationCode);
        
        if (![VirgilPrivateKeyManager pushPrivateKey : newAccountInfo.privateKeyInfo
                                     withPublicKeyID : newAccountInfo.publicKeyInfo.publicKeyID]) {
            [VirgilKeyManager setErrorString : [VirgilPrivateKeyManager lastError]];
            return NO;
        }
        return YES;
        
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        [VirgilKeyManager setErrorString : [NSString stringWithFormat:@"confirmAccountCreation : %s", _error.c_str()]];
    }
    return NO;
}

/**
 * @brief Get private key by account (email) and container password from Private Keys Service
 * @param account - email
 * @param containerPassword - password to Private Keys Service' container
 * @return VirgilPrivateKey - instance | nil - error occured, get error with [VirgilKeyManager lastError]
 */
+ (VirgilPrivateKey *) getPrivateKey : (NSString *) account
                   containerPassword : (NSString *) containerPassword {
    _lastError = nil;
    
    VirgilPublicKey * publicKey = [VirgilKeyManager getPublicKey : account];
    
    if (nil == publicKey) return nil;
    
    VirgilPrivateKey * privateKey =
    [VirgilPrivateKeyManager getPrivateKey : account
                         containerPassword : containerPassword
                               publicKeyID : publicKey.publicKeyID];
    if (nil == privateKey) {
        [VirgilKeyManager setErrorString : [VirgilPrivateKeyManager lastError]];
    }
    return privateKey;
}

/**
 * @brief Get last error user friendly string
 */
+ (NSString *) lastError {
    return _lastError;
}

/**
 * @brief [Internal use] Set last error string
 * @param errorStr - error description
 */
+ (void) setErrorString : (NSString *) errorStr {
    _lastError = [[NSString alloc] initWithFormat : @"VirgilKeyManager error : %@", errorStr];
}

+ (VirgilPrivateKey *) newAccountPrivateKey {
    return newAccountInfo.privateKeyInfo;
}

#if 0
+ (BOOL) deletePublicKey : (NSString *) account
                password : (NSString *) password {
    if (nil == account) return NO;
    
    VirgilPrivateKey * privateKey = [VirgilKeyManager getPrivateKey : account
                                                           password : password];
    if (nil == privateKey) return NO;
    
    VirgilPublicKey * publicKey = [VirgilKeyManager getPublicKey : account];
    if (nil == publicKey) return NO;
    
    try {
        std::cout << "Read virgil public key..." << std::endl;
        std::ifstream publicKeyFile("virgil_public.key", std::ios::in | std::ios::binary);
        if (!publicKeyFile.good()) {
            throw std::runtime_error("can not read virgil public key: virgil_public.key");
        }
        std::string publicKeyData;
        std::copy(std::istreambuf_iterator<char>(publicKeyFile), std::istreambuf_iterator<char>(),
                  std::back_inserter(publicKeyData));
        
        PublicKey publicKey = Marshaller<PublicKey>::fromJson(publicKeyData);
        
        std::cout << "Read private key..." << std::endl;
        std::ifstream keyFile("private.key", std::ios::in | std::ios::binary);
        if (!keyFile.good()) {
            throw std::runtime_error("can not read private key: private.key");
        }
        VirgilByteArray privateKey;
        std::copy(std::istreambuf_iterator<char>(keyFile), std::istreambuf_iterator<char>(),
                  std::back_inserter(privateKey));
        
        Credentials credentials(publicKey.publicKeyId(), privateKey);
        
        std::cout << "Remove public key with id (" << publicKey.publicKeyId() << ")." << std::endl;
        KeysClient keysClient(VIRGIL_PKI_APP_TOKEN, VIRGIL_PKI_URL_BASE);
        keysClient.publicKey().del(credentials, uuid());
    } catch (std::exception& exception) {
        std::cerr << "Error: " << exception.what() << std::endl;
    }
    return 0;
}
#endif

@end
