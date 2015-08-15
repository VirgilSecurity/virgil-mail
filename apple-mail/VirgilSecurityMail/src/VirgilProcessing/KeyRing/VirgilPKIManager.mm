//
//  VirgilPKIManager.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 01.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilPKIManager.h"
#include <iostream>
#include <fstream>
#include <algorithm>
#include <iterator>
#include <string>
#include <stdexcept>

#include <virgil/crypto/VirgilByteArray.h>
using virgil::crypto::VirgilByteArray;

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


//------------ Static variables -------------
static NSMutableDictionary * _publicKeyCache = [[NSMutableDictionary alloc] init];
static const std::string VIRGIL_PKI_URL_BASE = "https://pki-stg.virgilsecurity.com/v1/";
static const std::string VIRGIL_PKI_APP_TOKEN = "e88c4106cfddb959d62afb14a767c3e9";
//------------ ~Static variables -------------

@implementation VirgilPKIManager

+ (VirgilPublicKey *) getPublicKey:(NSString *) account {
    if (nil == account) return nil;
    try {
        // Search for key in cache
        VirgilPublicKey * res([_publicKeyCache objectForKey:account]);
        if (nil != res) {
            return res;
        }
        
        // Key in cache not present, lets download it
        
        const std::string _account([account UTF8String]);
        KeysClient keysClient(std::make_shared<Connection>(VIRGIL_PKI_APP_TOKEN, VIRGIL_PKI_URL_BASE));
        std::vector<PublicKey> publicKeys =
        keysClient.publicKey().search(_account, UserDataType::emailId);
        if (publicKeys.empty()) {
            return nil;
        }
        const PublicKey publicKey(publicKeys.front());
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
        NSLog(@"decryptData ERROR %s", _error.c_str());
    }
    return nil;
}

@end
