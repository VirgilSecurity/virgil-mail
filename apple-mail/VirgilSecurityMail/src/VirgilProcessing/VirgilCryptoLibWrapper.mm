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

#undef verify
#include <virgil/crypto/VirgilSigner.h>
using virgil::crypto::VirgilSigner;

#include <virgil/crypto/foundation/VirgilBase64.h>
using virgil::crypto::foundation::VirgilBase64;

@implementation VirgilCryptoLibWrapper

#undef verify
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

+ (NSData *) encryptData : (NSData *) data
                password : (NSString *) password {
    try {
        VirgilCipher cipher;
        const std::string _passwordData([password UTF8String]);
        VirgilByteArray baPassword(_passwordData.begin(), _passwordData.end());
        cipher.addPasswordRecipient(baPassword);
        
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
        
        // Create signature
        const VirgilByteArray _signature(VirgilSigner().sign(baData, baPrivateKey, baPrivateKeyPassword));
        
        return [[NSData alloc] initWithBytes : _signature.data()
                                      length : _signature.size()];
        
    } catch (std::exception& exception) {
        const std::string _error(exception.what());
        NSLog(@"signatureForData ERROR %s", _error.c_str());
    }
    return nil;
}

@end
