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
#import "VirgilCryptoLibWrapper.h"
#import "VirgilLog.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"

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
                                                            userDataID:@"00000000-0000-0000-0000-000000000000"];
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
    VirgilPrivateKey * decryptedKey = nil;
    if ([VirgilPrivateKeyManager isCorrectPrivateKey : encryptedKey.key]) {
        return encryptedKey;
    } else if ([VirgilPrivateKeyManager isCorrectPrivateKey : [encryptedKey.key stripBase64]]) {
        decryptedKey = [[VirgilPrivateKey alloc] initAccount : encryptedKey.account
                                               containerType : encryptedKey.containerType
                                                  privateKey : [encryptedKey.key stripBase64]
                                                 keyPassword : encryptedKey.keyPassword
                                           containerPassword : encryptedKey.containerPassword];
    } else {
        decryptedKey = [VirgilPrivateKeyManager decryptKey:encryptedKey withPassword:keyPassword];
    }
    
    if (nil == decryptedKey) return nil;
    
    if ([VirgilPrivateKeyManager isCorrectPrivateKey : decryptedKey.key]) {
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
 * @brief Set private key for account
 * @param key - private key
 * @param account - account
 * @return BOOL YES - set done | NO - error was occured
 */
+ (BOOL) setPrivateKey : (VirgilPrivateKey *) key
            forAccount : (NSString *) account {
    if (nil == key || nil == account) return NO;
    
    VirgilPublicKey * publicKey = nil;
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    
    if (nil == keyChainContainer || nil == keyChainContainer.publicKey) {
        publicKey = [VirgilKeyManager getPublicKey : account];
        keyChainContainer = [VirgilKeyChain loadContainer : account];
    } else {
        publicKey = keyChainContainer.publicKey;
    }
    
    if (nil == publicKey) return NO;
    
    VirgilKeyChainContainer * container = [[VirgilKeyChainContainer alloc] initWithPrivateKey : key
                                                                                 andPublicKey : publicKey
                                                                                     isActive : YES];
    [VirgilKeyChain saveContainer:container forAccount:account];
    return YES;
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
    _lastError = [[NSString alloc] initWithFormat : @"%@", errorStr];
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
        return YES;
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        [VirgilKeyManager setErrorString : [NSString stringWithFormat:@"deletePublicKey : %s", _error.c_str()]];
    }
    return NO;
}

/**
 * @brief Export account to file
 * @param account - account
 * @param fileName - result file
 * @param passwordForEncryption - password which used to encrypt result file
 * @return BOOL YES - set done | NO - error was occured
 */
+ (BOOL) exportAccountData : (NSString *) account
                    toFile : (NSString *) fileName
              withPassword : (NSString *) passwordForEncryption {
    
    NSString * errorString = [NSString stringWithFormat:@"Can't save data to %@", [fileName lastPathComponent]];
    
    VirgilKeyChainContainer * container = [VirgilKeyChain loadContainer : account];
    if (nil == container) {
        [self setErrorString:errorString];
        return NO;
    }
    
    NSMutableDictionary * userDataDict = [NSMutableDictionary new];
    NSString * userDataID = @"00000000-0000-0000-0000-000000000000";
    if (container.publicKey.userDataID && container.publicKey.userDataID.length) {
        userDataID = container.publicKey.userDataID;
    }
    
    [userDataDict setObject : userDataID forKey:@"user_data_id"];
    [userDataDict setObject : @"EmailId" forKey:@"class"];
    [userDataDict setObject : @"EmailId" forKey:@"type"];
    [userDataDict setObject : @"true" forKey:@"confirmed"];
    [userDataDict setObject : container.privateKey.account forKey:@"value"];
    
    NSArray * userDataArray = [NSArray arrayWithObjects:[userDataDict copy], nil];
    
    NSMutableDictionary * publicKeyDict = [NSMutableDictionary new];
    [publicKeyDict setObject : userDataArray forKey:@"tickets"];
    [publicKeyDict setObject : container.publicKey.publicKeyID forKey:@"public_key_id"];
    [publicKeyDict setObject : [container.publicKey.publicKey base64Wrap] forKey:@"public_key"];
    
    NSString * isUploaded = (VirgilContainerParanoic == container.privateKey.containerType) ? @"false" : @"true";
    NSMutableDictionary * bundle = [NSMutableDictionary new];
    [bundle setObject : [publicKeyDict copy] forKey:@"public_key"];
    [bundle setObject : [container.privateKey.key base64Wrap] forKey:@"private_key"];
    [bundle setObject : isUploaded forKey:@"uploaded"];

    NSArray * bundles = [NSArray arrayWithObjects:[bundle copy], nil];
    
    NSMutableDictionary * jsonDict = [NSMutableDictionary new];
    
    NSString * isProtectedStr = (container.privateKey.keyPassword && container.privateKey.keyPassword.length) ? @"true" : @"false";
    [jsonDict setObject : bundles forKey:@"bundles"];
    [jsonDict setObject : [NSNumber numberWithInt:0] forKey:@"mode"];
    [jsonDict setObject : @"true" forKey:@"user_selected_store_mode"];
    [jsonDict setObject : isProtectedStr forKey:@"is_protected"];
    [jsonDict setObject : container.publicKey.accountID forKey:@"account_id"];
    

    NSArray * jsonArray = [NSArray arrayWithObjects:jsonDict, nil];
    
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject : jsonArray
                                                        options : 0
                                                          error : &error];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\"true\"" withString:@"true"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\"false\"" withString:@"false"];
    jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData * preparedData = nil;
    if (passwordForEncryption && passwordForEncryption.length) {
        preparedData = [VirgilCryptoLibWrapper encryptData : jsonData
                                                  password : passwordForEncryption];
    } else {
        preparedData = jsonData;
    }
    
    NSString * base64Str = [preparedData base64EncodedStringWithSeparateLines : NO];
    
    return [[NSFileManager defaultManager] createFileAtPath:fileName
                                            contents:[base64Str dataUsingEncoding:NSUTF8StringEncoding]
                                          attributes:nil];
}

/**
 * @brief Import account from file
 * @param account - account
 * @param fileName - source file
 * @param passwordForDecryption - password which used to decrypt source file
 * @return container with loaded data
 */
+ (VirgilKeyChainContainer *) importAccountData : (NSString *) account
                                       fromFile : (NSString *) fileName
                                   withPassword : (NSString *) passwordForDecryption {
    NSString * errorString = [NSString stringWithFormat:@"Can't load data from %@ or wrong password", [fileName lastPathComponent]];
    
    NSError *error;

    // Check file size before read
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil] fileSize];
    if (error || fileSize > 10240) {
        [self setErrorString:errorString];
        return nil;
    }
    
    // Read file data
    NSString * fileContent = [NSString stringWithContentsOfFile : fileName
                                                       encoding : NSUTF8StringEncoding
                                                          error : &error];
    if (error) {
        [self setErrorString:errorString];
        return nil;
    }
    
    // Decrypt content if need
    NSData * jsonData = nil;
    
    if (passwordForDecryption && passwordForDecryption.length) {
        NSData * encryptedData = [NSData dataFromBase64String:fileContent];
        jsonData = [VirgilCryptoLibWrapper decryptData : encryptedData
                                          withPassword : passwordForDecryption];
    } else {
        jsonData = [NSData dataFromBase64String:fileContent];
    }
    
    if (nil == jsonData) {
        [self setErrorString:errorString];
        return nil;
    }
    
    // Parse JSON data
    id resultJSON = [NSJSONSerialization JSONObjectWithData : jsonData
                                                    options : 0
                                                      error : &error];
    if (error) {
        [self setErrorString:errorString];
        return nil;
    }
    
    NSDictionary * jsonDict = nil;
    
    if ([resultJSON isKindOfClass:[NSDictionary class]]) {
        jsonDict = (NSDictionary *) resultJSON;
    } else if ([resultJSON isKindOfClass:[NSArray class]]) {
        jsonDict = [(NSArray *)resultJSON objectAtIndex:0];
    }
    
    
    if (jsonDict) {
        NSArray * bundles = [jsonDict objectForKey:@"bundles"];
        NSDictionary * bundle = [bundles objectAtIndex:0];
        NSString * privateKey = [bundle objectForKey:@"private_key"];
        
        NSDictionary * userDataDict = [bundle objectForKey : @"public_key"];
        NSArray * userDataAr = [userDataDict objectForKey : @"tickets"];
        
        NSString * importAccount = nil;
        for (NSDictionary * dict in userDataAr) {
            NSString * type = [dict objectForKey:@"type"];
            if ([type isEqualTo:@"EmailId"]) {
                importAccount = [dict objectForKey:@"value"];
                break;
            }
        }
        
        if ([importAccount isEqualTo:account]) {
            VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
            if (keyChainContainer) {
                VirgilPrivateKey * updatedPrivateKey = [[VirgilPrivateKey alloc] initAccount : account
                                                                               containerType : VirgilContainerEasy
                                                                                  privateKey : privateKey
                                                                                 keyPassword : nil
                                                                           containerPassword : nil];
                VirgilKeyChainContainer * updatedConteiner = [[VirgilKeyChainContainer alloc] initWithPrivateKey : updatedPrivateKey
                                                                                                    andPublicKey : keyChainContainer.publicKey
                                                                                                        isActive : YES];
                [VirgilKeyChain saveContainer:updatedConteiner forAccount:account];
                return updatedConteiner;
            }
        } else {
            [self setErrorString:@"These virgil keys belong to another user"];
        }
        
        return nil;
    }
    
    [self setErrorString:errorString];
    return nil;
}

@end
