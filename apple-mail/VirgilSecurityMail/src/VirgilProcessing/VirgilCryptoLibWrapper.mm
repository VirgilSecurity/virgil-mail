//
//  VirgilCryptoLibWrapper.m
//  VirgilSecurityMail
//
//  Created by Роман Куташенко on 03.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#undef verify

#import "VirgilCryptoLibWrapper.h"
#import "NSData+Base64.h"
#import "VirgilPublicKey.h"

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

#include <virgil/crypto/VirgilSigner.h>
using virgil::crypto::VirgilSigner;

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

+ (BOOL) isSignatureCorrect:(NSData *) signature
                       data:(NSData *) data
                 publicKey :(NSString *) publicKey {
    try {
        // Prepare signature
        VirgilByteArray baSignature;
        baSignature.assign(reinterpret_cast<const unsigned char*>([signature bytes]),
                      reinterpret_cast<const unsigned char*>([signature bytes]) + [signature length]);
        
        // Prepare data
        VirgilByteArray baData;
        baData.assign(reinterpret_cast<const unsigned char*>([data bytes]),
                      reinterpret_cast<const unsigned char*>([data bytes]) + [data length]);
        
        // Prepare public key
        const std::string _publicKeyData([publicKey UTF8String]);
        VirgilByteArray baPublicKey(_publicKeyData.begin(), _publicKeyData.end());
        
        // Verify signature

        if (VirgilSigner().verify(baData, baSignature, baPublicKey)) {
            return YES;
        }
        
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        NSLog(@"decryptData ERROR %s", _error.c_str());
    }
    return NO;
}

+ (NSData *) encryptData : (NSData *) data
              publicKeys : (NSArray *) publicKeys {
    
    try {
        VirgilCipher cipher;
        
        for (VirgilPublicKey * publicKey in publicKeys) {
            const std::string _publicKeyIdData([publicKey.publicKeyID UTF8String]);
            VirgilByteArray baPublicKeyId(_publicKeyIdData.begin(), _publicKeyIdData.end());
            
            const std::string _publicKeyData([publicKey.publicKey UTF8String]);
            VirgilByteArray baPublicKey(_publicKeyData.begin(), _publicKeyData.end());
            
            cipher.addKeyRecipient(baPublicKeyId, baPublicKey);
        }
        
        VirgilByteArray baData;
        baData.assign(reinterpret_cast<const unsigned char*>([data bytes]),
                      reinterpret_cast<const unsigned char*>([data bytes]) + [data length]);
        
        const VirgilByteArray _encryptedData(cipher.encrypt(baData, true));
        
        return [[NSData alloc] initWithBytes : _encryptedData.data()
                                      length : _encryptedData.size()];
        
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        NSLog(@"encryptData ERROR %s", _error.c_str());
    }
    return nil;
}

+ (NSData *) signatureForData : (NSData *) data
               withPrivateKey : (NSString *) privateKey
            privatKeyPassword : (NSString *) privateKeyPassword {
    try {
        // Prepare data
        VirgilByteArray baData;
        baData.assign(reinterpret_cast<const unsigned char*>([data bytes]),
                      reinterpret_cast<const unsigned char*>([data bytes]) + [data length]);
        
        
        // Prepare private key
        const std::string _privateKeyData([privateKey UTF8String]);
        VirgilByteArray baPrivateKey(_privateKeyData.begin(), _privateKeyData.end());
        
        // Prepare private key password
        VirgilByteArray baPrivateKeyPassword;
        if (nil != privateKeyPassword) {
            const std::string _privateKeyPasswordData([privateKeyPassword UTF8String]);
            baPrivateKeyPassword.assign(_privateKeyPasswordData.begin(), _privateKeyPasswordData.end());
        }
        
        // Decrypt private key if need
        if (!baPrivateKeyPassword.empty()) {
            VirgilByteArray decryptedKey (
                                          VirgilCipher().decryptWithPassword(
                                                                     VirgilBase64::decode(_privateKeyData),
                                                                     baPrivateKeyPassword
                                                                     ));
            baPrivateKey.assign(decryptedKey.begin(), decryptedKey.end());
        }
        
        // Create signature
        const VirgilByteArray _signature(VirgilSigner().sign(baData, baPrivateKey));

        return [[NSData alloc] initWithBytes : _signature.data()
                                      length : _signature.size()];

    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        NSLog(@"signatureForData ERROR %s", _error.c_str());
    }
    return nil;
}

@end
