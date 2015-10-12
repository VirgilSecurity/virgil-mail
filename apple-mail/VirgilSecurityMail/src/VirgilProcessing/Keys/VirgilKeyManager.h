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
#import "VirgilPublicKey.h"
#import "VirgilPrivateKey.h"
#import "VirgilDataTypes.h"

/**
 * @brief Class for working with Private and Public keys
 */

@interface VirgilKeyManager : NSObject

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
     containerPassword : (NSString *) containerPassword;

/**
 * @brief Confirm account creation with received (by email) code
 * @param account - email
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) confirmAccountCreation : (NSString *) account
                           code : (NSString *) code;

/**
 * @brief Resend confirmation email
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) resendConfirmEMail : (NSString *) account;

/**
 * @brief Resend confirmation email
 * @param publicKey - public key
 * @param privateKey - private key
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
+ (BOOL) resendConfirmEMail : (VirgilPublicKey *) publicKey
                 privateKey : (VirgilPrivateKey *) privateKey;

/**
 * @brief Get public key by account (email)
 * @param account - email
 * @return VirgilPublicKey - instance | nil - error occured, get error with [VirgilKeyManager lastError]
 */
+ (VirgilPublicKey *) getPublicKey : (NSString *) account;

/**
 * @brief Get private key by account (email) and container password from Private Keys Service without decryption
 * @param account - email
 * @param containerPassword - password to Private Keys Service' container
 * @return VirgilPrivateKey - instance | nil - error occured, get error with [VirgilKeyManager lastError]
 */

+ (VirgilPrivateKey *) getEncryptedPrivateKeyFromCloud : (NSString *) account
                                     containerPassword : (NSString *) containerPassword;

/**
 * @brief Encrypt private key by password
 * @param encryptedKey - encrypted private key
 * @param keyPassword - password for private key decryption
 * @return VirgilPrivateKey - decrypted private key | nil - error occured, get error with [VirgilKeyManager lastError]
 */
+ (VirgilPrivateKey *) decryptedPrivateKey : (VirgilPrivateKey *) encryptedKey
                               keyPassword : (NSString *) keyPassword;
 
/**
 * @brief Get last error user friendly string
 */
+ (NSString *) lastError;

@end
