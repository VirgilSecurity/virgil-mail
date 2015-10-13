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

#import <Foundation/Foundation.h>
#import "VirgilPrivateKey.h"
#import "VirgilDataTypes.h"

/**
 * @class Class for working with Private Keys Service
 */

@interface VirgilPrivateKeyManager : NSObject

/**
 * @brief Get private key (paranoic mode not supported yet)
 * @param account - email
 * @param password - Container's password
 * @param publicKeyID - public key ID for request verification
 * @return VirgilPrivateKey instance | nil - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (VirgilPrivateKey *) getPrivateKey : (NSString *) account
                   containerPassword : (NSString *) containerPassword
                         publicKeyID : (NSString *) publicKeyID;

/**
 * @brief Push private key (paranoic mode not supported yet)
 * @param key - VirgilPrivateKey instance
 * @param publicKeyID - public key ID for request verification
 * @return YES - success | nil - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (BOOL) pushPrivateKey : (VirgilPrivateKey *) key
        withPublicKeyID : (NSString * ) publicKeyID;


/**
 * @brief Decrypt key from Private Key Service.
 * @param key - VirgilPrivateKey instance
 * @param password - password for key decription
 * @return Decrypted key | nil - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (VirgilPrivateKey *) decryptKey : (VirgilPrivateKey *) encryptedKey
                     withPassword : (NSString *) password;

/**
 * @brief Check is correct private key.
 * @return boolean is key correct
 */
+ (BOOL) isCorrectPrivateKey : (NSString *) privateKey;

/**
 * @brief Check is correct encrypted private key.
 * @return boolean is key correct
 */
+ (BOOL) isCorrectEncryptedPrivateKey : (NSString *) privateKey;

/**
 * @brief Get last error user friendly string
 */
+ (NSString *) lastError;

@end
