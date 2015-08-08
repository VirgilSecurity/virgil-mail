//
//  VirgilCryptoLibWrapper.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 03.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilCryptoLibWrapper.h"
#import "NSData+Base64.h"

#include <iostream>
#include <algorithm>
#include <iterator>
#include <string>
#include <stdexcept>
#include <list>

#include <virgil/crypto/VirgilByteArray.h>
using virgil::crypto::VirgilByteArray;

#include <virgil/crypto/VirgilCryptoException.h>
using virgil::crypto::VirgilCryptoException;

#include <virgil/crypto/VirgilCipher.h>
using virgil::crypto::VirgilCipher;

#include <virgil/crypto/foundation/VirgilBase64.h>
using virgil::crypto::foundation::VirgilBase64;

@implementation VirgilCryptoLibWrapper

+ (NSData *) decryptData : (NSData *) data
             publicKeyId : (NSString *) publicKeyId
              privateKey : (NSString *) privateKey
       privateKeyPassword: (NSString *) privateKeyPassword {
    try {
        VirgilCipher cipher;
        
        // Prepare public key id
        const std::string _publicKeyIdData([publicKeyId UTF8String]);
        VirgilByteArray baPublicKeyId(_publicKeyIdData.begin(), _publicKeyIdData.end());
        
        // Prepare private key
        const std::string _privateKeyData([privateKey UTF8String]);
        VirgilByteArray baPrivateKey(_privateKeyData.begin(), _privateKeyData.end());
        
        // Prepare private key password
        VirgilByteArray baPrivateKeyPassword;
        if (nil != privateKeyPassword) {
            const std::string _privateKeyPasswordData([privateKeyPassword UTF8String]);
            baPrivateKeyPassword.assign(_privateKeyPasswordData.begin(), _privateKeyPasswordData.end());
        }
        
        // Prepare data
        VirgilByteArray baData;
        baData.assign(reinterpret_cast<const unsigned char*>([data bytes]),
                    reinterpret_cast<const unsigned char*>([data bytes]) + [data length]);

        
        
        // Decrypt private key if need
        if (!baPrivateKeyPassword.empty()) {
            VirgilByteArray decryptedKey (
                                cipher.decryptWithPassword(
                                                           VirgilBase64::decode(_privateKeyData),
                                                           baPrivateKeyPassword
                                                        ));
            baPrivateKey.assign(decryptedKey.begin(), decryptedKey.end());
        }
        
        // Decrypt
        const VirgilByteArray _readyData(cipher.decryptWithKey(baData,
                                                               baPublicKeyId,
                                                               baPrivateKey));
        return [[NSData alloc] initWithBytes:_readyData.data() length:_readyData.size()];
        
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        NSLog(@"decryptData ERROR %s", _error.c_str());
    }
    return nil;
}

@end
