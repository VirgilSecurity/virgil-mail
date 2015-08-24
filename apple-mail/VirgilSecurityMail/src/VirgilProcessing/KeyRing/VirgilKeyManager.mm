//
//  VirgilKeyManager.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 01.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

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

//------------ Static variables -------------
static NSMutableDictionary * _publicKeyCache = [[NSMutableDictionary alloc] init];

struct {
    VirgilPublicKey * publicKeyInfo;
    VirgilPrivateKey * privateKeyInfo;
    PublicKey keyWithUserData;
} newAccountInfo;

//------------ ~Static variables -------------

@implementation VirgilKeyManager : NSObject 

+ (VirgilPublicKey *) getPublicKey:(NSString *) account {
    if (nil == account) return nil;
    try {
        // Search for key in cache
        VirgilPublicKey * res([_publicKeyCache objectForKey:account]);
        if (nil != res) {
            return res;
        }
        
        // Key in cache not present, lets download it
        
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
        
        res = [[VirgilPublicKey alloc] initAccountID:nsAccountID
                                         publicKeyID:nsKeyID
                                           publicKey:nsKey];
        // Add new key to cache
        [_publicKeyCache setValue:res
                           forKey:account];
        return res;
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        NSLog(@"getPublicKey ERROR %s", _error.c_str());
    }
    return nil;
}

+ (BOOL) createAccount : (NSString *) account
          withPassword : (NSString *) password {
    newAccountInfo.publicKeyInfo = nil;
    if (nil == account || nil == password) return NO;
    
    // Prepare account
    const std::string _accountData([VirgilHelpers _strNS2Std : account]);
    VirgilByteArray baAccount(_accountData.begin(), _accountData.end());
    
    // Prepare password
    const std::string _passwordData(/*[password UTF8String]*/"");
    VirgilByteArray baPassword(_passwordData.begin(), _passwordData.end());
    
    try {
        // Generate keys
        const VirgilKeyPair _keyPair;//(/*baPassword*/);
        const VirgilByteArray _publicKey(_keyPair.publicKey());
        const VirgilByteArray _privateKey(_keyPair.privateKey());
        
        NSString * nsPrivateKey = [VirgilHelpers _strStd2NS : virgil::crypto::bytes2str(_privateKey)];
        newAccountInfo.privateKeyInfo =
            [[VirgilPrivateKey alloc] initAccount : account
                                         password : password
                                       privateKey : nsPrivateKey];
        
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
        NSLog(@"getPublicKey ERROR %s", _error.c_str());
    }
        
    return NO;
}

+ (BOOL) confirmAccountCreationWithCode : (NSString *) code {
    if (nil == code ||
        nil == newAccountInfo.publicKeyInfo ||
        newAccountInfo.keyWithUserData.userData().empty()) return NO;
    try {
        const std::string userDataId(newAccountInfo.keyWithUserData.userData().front().userDataId());
        const std::string confirmationCode([VirgilHelpers _strNS2Std : code]);
        
        KeysClient keysClient(
                              [VirgilHelpers _strNS2Std : [VirgilHelpers applicationToken]],
                              [VirgilHelpers _strNS2Std : [VirgilHelpers keysURLBase]]
                              );
        keysClient.userData().confirm(userDataId, confirmationCode);
        
        return [VirgilPrivateKeyManager pushPrivateKey : newAccountInfo.privateKeyInfo];
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        NSLog(@"confirmAccountCreation ERROR %s", _error.c_str());
    }
    return NO;
}

+ (VirgilPrivateKey *) getPrivateKey : (NSString *) account
                            password : (NSString *) password {
    VirgilPublicKey * publicKey = [VirgilKeyManager getPublicKey : account];
    
    if (nil == publicKey) return nil;
    
    return [VirgilPrivateKeyManager getPrivateKey : account
                                         password : password
                                      publicKeyID : publicKey.publicKeyID];
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
