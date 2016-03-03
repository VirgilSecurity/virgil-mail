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
#import "VirgilKeyChainContainer.h"

#define kCreateAction       @"create_action"
#define kDeleteAction       @"delete_action"
#define kKeyRequestAction   @"key_request_action"


typedef NS_ENUM(NSUInteger, VirgilSetPrivateKeyResult) {
    kSaveDone,
    kSaveError,
    kSaveTerminated
};

/**
 * @brief Class for working with Private and Public keys
 */

@interface VirgilKeyManager : NSObject

+ (VirgilKeyManager *) sharedInstance;

/**
 * @brief Create key pair, register at Key service
 * @param account - email
 * @param keyPassword - password for keys encryption
 * @param containerType - container type {easy, normal, paranoic}
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) createAccount : (NSString *) account
           keyPassword : (NSString *) keyPassword
         containerType : (VirgilContainerType) containerType;

/**
 * @brief Confirm account creation with received (by email) code
 * @param account - email
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) confirmAccountCreation : (NSString *) account
                           code : (NSString *) code;

/**
 * @brief Request account deletion
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) requestAccountDeletion : (NSString *)account;

/**
 * @brief Terminate account deletion
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) terminateAccountDeletion : (NSString *)account;

/**
 * @brief Terminate provate key request
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) terminatePrivateKeyRequest : (NSString *)account;

/**
 * @brief Confirm account deletion with received (by email) code
 * @param account - email
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) confirmAccountDeletion : (NSString *) account
                           code : (NSString *) code;

/**
 * @brief Confirm private key request with received (by email) code
 * @param account - email
 * @param code - code from email
 * @return VirgilSetPrivateKeyResult
 */
- (VirgilSetPrivateKeyResult) confirmPrivateKeyRequest : (NSString *) account
                                                  code : (NSString *) code;

/**
 * @brief Resend confirmation email for account creation
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) resendConfirmEMail : (NSString *) account;

/**
 * @brief Resend confirmation email
 * @param publicKey - public key
 * @param privateKey - private key
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) resendConfirmEMail : (VirgilPublicKey *) publicKey
                 privateKey : (VirgilPrivateKey *) privateKey;

/**
 * @brief Get public key by account (email)
 * @param account - email
 * @return VirgilPublicKey - instance | nil - error occured, get error with [VirgilKeyManager lastError]
 */
- (VirgilPublicKey *) getPublicKey : (NSString *) account;

/**
 * @brief Request private key by account (email) from Private Keys Service
 * @param account - email
 * @return boolean YES if resuest was sent correctly
 */
- (BOOL) requestPrivateKeyFromCloud : (NSString *) account;

/**
 * @brief Set private key for account
 * @param key - private key
 * @param account - account
 * @return BOOL YES - set done | NO - error was occured
 */
- (BOOL) setPrivateKey : (VirgilPrivateKey *) key
            forAccount : (NSString *) account;

/**
 * @brief Export account to file
 * @param account - account
 * @param fileName - result file
 * @param passwordForEncryption - password which used to encrypt result file
 * @return BOOL YES - set done | NO - error was occured
 */
- (BOOL) exportAccountData : (NSString *) account
                    toFile : (NSString *) fileName
              withPassword : (NSString *) passwordForEncryption;


/**
 * @brief Import account from file
 * @param account - account
 * @param fileName - source file
 * @param passwordForDecryption - password which used to decrypt source file
 * @return container with loaded data
 */
- (VirgilKeyChainContainer *) importAccountData : (NSString *) account
                                       fromFile : (NSString *) fileName
                                   withPassword : (NSString *) passwordForDecryption;

- (VirgilSetPrivateKeyResult) prepareAndSaveLoadedPrivateKey : (NSString *) base64PrivateKey
                                               containerType : (VirgilContainerType) containerType
                                                     account : (NSString *) account;

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

+ (BOOL) isCorrectKeys : (NSString *)publicKey
            privateKey : (NSString *)privateKey
              password : (NSString *)password;

/**
 * @brief Get last error user friendly string
 */
- (NSString *) lastError;

@end
