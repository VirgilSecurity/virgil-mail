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
#import "VirgilKeyChain.h"
#import "VirgilLog.h"

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

/**
 * @brief Get public key by account (email)
 * @param account - email
 * @return VirgilPublicKey - instance | nil - error occured, get error with [VirgilKeyManager lastError]
 */
+ (VirgilPublicKey *) getPublicKey:(NSString *) account {
    _lastError = nil;
    
    if (nil == account) return nil;
    
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    
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
                                                             publicKey:nsKey
                                                            userDataID:@""];
        if (nil == keyChainContainer) {
            keyChainContainer =
            [[VirgilKeyChainContainer alloc] initWithPrivateKey : nil
                                                   andPublicKey : res
                                                       isActive : YES];
            [VirgilKeyChain saveContainer : keyChainContainer
                               forAccount : account];
        }
        
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
        VirgilPrivateKey * privateKeyInfo =
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
        
        const std::string _key(virgil::crypto::bytes2str(publicKey.key()));
        const std::string _userDataId(publicKey.userData().front().userDataId());
        
        
        VirgilPublicKey * publicKeyInfo =
        [[VirgilPublicKey alloc] initAccountID : [VirgilHelpers _strStd2NS : publicKey.accountId()]
                                   publicKeyID : [VirgilHelpers _strStd2NS : publicKey.publicKeyId()]
                                     publicKey : [VirgilHelpers _strStd2NS : _key]
                                    userDataID : [VirgilHelpers _strStd2NS : _userDataId]];
        
        VirgilKeyChainContainer * container =
        [[VirgilKeyChainContainer alloc] initWithPrivateKey : privateKeyInfo
                                               andPublicKey : publicKeyInfo
                                                   isActive : NO];
        [VirgilKeyChain saveContainer : container
                           forAccount : account];
        return YES;
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        [VirgilKeyManager setErrorString : [NSString stringWithFormat:@"getPublicKey : %s", _error.c_str()]];
    }
    
    return NO;
}

/**
 * @brief Confirm account creation with received (by email) code
 * @param account - email
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) confirmAccountCreation : (NSString *) account
                           code : (NSString *) code {
    if (nil == account) {
        [VirgilKeyManager setErrorString : @"wrong account for confirmation"];
        return NO;
    }
    
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    if (nil == keyChainContainer) {
        [VirgilKeyManager setErrorString : @"account not present for confirmation"];
        return NO;
    }
    
    BOOL res = [VirgilKeyManager confirmAccountCreationWithCode : code
                                                   keyContainer : keyChainContainer];
    
    return res;
}

/**
 * @brief Confirm account creation with received (by email) code
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) confirmAccountCreationWithCode : (NSString *) code
                           keyContainer : (VirgilKeyChainContainer *) container {
    _lastError = nil;
    if (nil == code ||
        nil == container) {
        [VirgilKeyManager setErrorString : @"wrong params for account confirmation"];
        return NO;
    }
    try {
        const std::string strUserDataId([VirgilHelpers _strNS2Std : container.publicKey.userDataID]);
        const std::string confirmationCode([VirgilHelpers _strNS2Std : code]);
        
        KeysClient keysClient(
                              [VirgilHelpers _strNS2Std : [VirgilHelpers applicationToken]],
                              [VirgilHelpers _strNS2Std : [VirgilHelpers keysURLBase]]
                              );
        keysClient.userData().confirm(strUserDataId, confirmationCode);
        
        if (VirgilContainerParanoic != container.privateKey.containerType) {
            if (![VirgilPrivateKeyManager pushPrivateKey : container.privateKey
                                         withPublicKeyID : container.publicKey.publicKeyID]) {
                [VirgilKeyManager setErrorString : [VirgilPrivateKeyManager lastError]];
                return NO;
            }
        }
        
        VirgilKeyChainContainer * updatedContainer =
        [[VirgilKeyChainContainer alloc] initWithPrivateKey : container.privateKey
                                               andPublicKey : container.publicKey
                                                   isActive : YES];
        [VirgilKeyChain saveContainer : updatedContainer
                           forAccount : updatedContainer.privateKey.account];
        
        return YES;
        
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        [VirgilKeyManager setErrorString : [NSString stringWithFormat:@"confirmAccountCreation : %s", _error.c_str()]];
    }
    return NO;
}

/**
 * @brief Resend confirmation email
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) resendConfirmEMail : (NSString *) account {
    if (nil == account) {
       [VirgilKeyManager setErrorString : @"wrong account for resend confirmation email"];
        return NO;
    }
    
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    if (nil == keyChainContainer) {
        [VirgilKeyManager setErrorString : @"account not present for resend confirmation email"];
        return NO;
    }
    return [VirgilKeyManager resendConfirmEMail : keyChainContainer.publicKey
                                     privateKey : keyChainContainer.privateKey];
    
}

/**
 * @brief Resend confirmation email
 * @param publicKeyId - public key id
 * @param privateKey - private key
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) resendConfirmEMail : (VirgilPublicKey *) publicKey
                 privateKey : (VirgilPrivateKey *) privateKey {
    
    if (nil == publicKey || nil == privateKey) {
        [VirgilKeyManager setErrorString : @"wrong params for resend confirmation email"];
        return NO;
    }
    
    [VirgilKeyManager deletePublicKey : publicKey
                           privateKey : privateKey];
    
    return [VirgilKeyManager createAccount : privateKey.account
                               keyPassword : privateKey.keyPassword
                             containerType : privateKey.containerType
                         containerPassword : privateKey.containerPassword];
}


/**
 * @brief Get private key by account (email) and container password from Private Keys Service without decryption
 * @param account - email
 * @param containerPassword - password to Private Keys Service' container
 * @return VirgilPrivateKey - instance | nil - error occured, get error with [VirgilKeyManager lastError]
 */
+ (VirgilPrivateKey *) getEncryptedPrivateKeyFromCloud : (NSString *) account
                                     containerPassword : (NSString *) containerPassword {
    _lastError = nil;
    
    VirgilPublicKey * publicKey = nil;
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    
    if (nil == keyChainContainer || nil == keyChainContainer.publicKey) {
        publicKey = [VirgilKeyManager getPublicKey : account];                     // Check
        keyChainContainer = [VirgilKeyChain loadContainer : account];
    } else {
        publicKey = keyChainContainer.publicKey;
    }
    
    if (nil == publicKey) {
        return nil;
    }
    
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
 * @brief Decrypt private key by password
 * @param encryptedKey - encrypted private key
 * @param keyPassword - password for private key decryption
 * @return VirgilPrivateKey - decrypted private key | nil - error occured, get error with [VirgilKeyManager lastError]
 */
+ (VirgilPrivateKey *) decryptedPrivateKey : (VirgilPrivateKey *) encryptedKey
                                           keyPassword : (NSString *) keyPassword {
    if ([VirgilPrivateKeyManager isCorrectPrivateKey : encryptedKey]) {
        return encryptedKey;
    }
    VirgilPrivateKey * decryptedKey = [VirgilPrivateKeyManager decryptKey:encryptedKey withPassword:keyPassword];
    if (nil == decryptedKey) return nil;
    
    VLogInfo(@"encryptedKey :  %@", encryptedKey);
    VLogInfo(@"decryptedKey :  %@", decryptedKey);

    
    if ([VirgilPrivateKeyManager isCorrectPrivateKey : decryptedKey]) {
        VirgilPublicKey * publicKey = [VirgilKeyManager getPublicKey:encryptedKey.account];
        if (nil == publicKey) {
            [self setErrorString:@"There is no public key for this account"];
            return nil;
        }
        VirgilKeyChainContainer * container = [[VirgilKeyChainContainer alloc] initWithPrivateKey : decryptedKey
                                                                                     andPublicKey : publicKey
                                                                                         isActive : YES];
        [VirgilKeyChain saveContainer:container forAccount:encryptedKey.account];
        return decryptedKey;
    }
    [self setErrorString:@"Wrong password for private key"];
    return nil;
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

/**
 * @brief Delete public key
 * @param publicKey - public key
 * @param privateKey - private key
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) deletePublicKey : (VirgilPublicKey *) publicKey
              privateKey : (VirgilPrivateKey *) privateKey {
    
    if (nil == publicKey || nil == privateKey) {
        [VirgilKeyManager setErrorString : @"wrong params for account deletion"];
        return NO;
    }
    
    // Prepare public key id
    const std::string _publicKeyId([VirgilHelpers _strNS2Std : publicKey.publicKeyID]);
    
    // Prepare private key
    const std::string _privateKey([VirgilHelpers _strNS2Std : privateKey.key]);
    VirgilByteArray baPrivateKey(_privateKey.begin(), _privateKey.end());
    
    // Prepare password
    std::string _privateKeyPassword;
    if (nil != privateKey.keyPassword) {
        _privateKeyPassword = std::string([VirgilHelpers _strNS2Std:privateKey.keyPassword]);
    }
    
    try {
        Credentials credentials(_publicKeyId, baPrivateKey, _privateKeyPassword);
        KeysClient keysClient(
                              [VirgilHelpers _strNS2Std : [VirgilHelpers applicationToken]],
                              [VirgilHelpers _strNS2Std : [VirgilHelpers keysURLBase]]
                              );
        const std::string uuid([VirgilHelpers _uuid]);
        keysClient.publicKey().del(credentials, uuid);
        VLogInfo(@"deletePublicKey : DONE");
        return YES;
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        [VirgilKeyManager setErrorString : [NSString stringWithFormat:@"deletePublicKey : %s", _error.c_str()]];
        VLogError(@"%@", [VirgilKeyManager lastError]);
    }
    return NO;
}

@end
