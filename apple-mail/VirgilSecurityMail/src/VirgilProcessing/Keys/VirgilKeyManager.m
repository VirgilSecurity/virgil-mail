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
#import "VirgilKeyChain.h"
#import "VirgilLog.h"
#import "VirgilGui.h"
#import "VirgilServiceConfigStg.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"

#import "VSSClient.h"
#import "VSSCard.h"
#import "VSSPublicKey.h"
#import "VSSIdentity.h"
#import "VSSKeyPair.h"
#import "VSSPrivateKey.h"
#import "VSSModelCommons.h"
#import "VSSCryptor.h"

#if !defined(VIRGIL_STAGING_SERVICES)
#define VIRGIL_STAGING_SERVICES
#endif

@interface VirgilKeyManager ()

//! _lastError - contains user friendly error string
@property (nonatomic) NSString * lastError;
@property (nonatomic, strong) VSSClient * client;

@end

@implementation VirgilKeyManager : NSObject

@synthesize lastError = _lastError;
@synthesize client = _client;

+ (VirgilKeyManager *) sharedInstance {
    static VirgilKeyManager * singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    
    return singletonObject;
}

+ (id) alloc{
    return [super alloc];
}

- (id) init{
    _lastError = nil;
    _client =
#if defined(VIRGIL_STAGING_SERVICES)
    [[VSSClient alloc] initWithApplicationToken : @"eyJpZCI6Ijc1MmMyMzM3LTM0YTYtNGRhOS04NzUwLTZhMjZlYWUzOWU2NSIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiIxMDEwMDBiNS02MDRlLTQ1ZWMtODMzMi00MWFmOTE1MGYzYWUiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MIGZMA0GCWCGSAFlAwQCAgUABIGHMIGEAkBd0GMYg9I2H/cQz7jbL1EPJLLUnWePpGfc5LyjNgidAq9z/4rYDFRYyv6wPKJDx6KysCqLIWgH2YfmMTCtBYL1AkArX14rnAYP63brY3QMP01z2c/zf3K06O+jr9eDshETGRxIoumhqTcbRP/00KjBlEGb8Ip7KX0wo/vPYNpzqf91"
                                  serviceConfig : [VirgilServiceConfigStg new]];
#else
    [[VSSClient alloc] initWithApplicationToken : @"eyJpZCI6IjU4Y2YxMTQzLTNhOTEtNGEzOS04Y2RkLTI2N2FlNWFiZTliMiIsImFwcGxpY2F0aW9uX2NhcmRfaWQiOiI0Mjc3ZDNjYy05YzdmLTQzNWMtYmNmYy0wNjE1YzkxZTg4ZmUiLCJ0dGwiOi0xLCJjdGwiOi0xLCJwcm9sb25nIjowfQ==.MIGZMA0GCWCGSAFlAwQCAgUABIGHMIGEAkBzWJSyG43LBzfPusOg4XG4xYG5xPqXjfOi+/ax1xgzMNqrVhTxrNWoeOFh8FnAqcD5vkakSqqMPB7oztd2Fsw9AkAJCa5DAxNvbwL9fpT88VKNPAmrVClKj8n8lJbZWSIIpNBrbY/bDze3pmY/7YyJsgo9JdzGq8B8FXk2d3BZXowM"
                                  serviceConfig : nil];
#endif
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [_client setupClientWithCompletionHandler:^(NSError * _Nullable error) {
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, [self timeout]);
    return [super init];
}

- (dispatch_time_t) timeout {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC));
}

- (VSSCard *) cardForAccount : (NSString *) account {
    if (nil == account) return nil;
    
    __block VSSCard * res = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [_client searchCardWithIdentityValue : account
                                    type : VSSIdentityTypeEmail
                               relations : nil
                             unconfirmed : @NO
                       completionHandler :^(NSArray<VSSCard *> * _Nullable cards, NSError * _Nullable error) {
                           if (error == nil && cards != nil && [cards count] > 0) {
                               res = cards[0];
                           }
                           dispatch_semaphore_signal(semaphore);
                       }];
    dispatch_semaphore_wait(semaphore, [self timeout]);
    return res;
}

/**
 * @brief Get public key by account (email)
 * @param account - email
 * @return VirgilPublicKey - instance | nil - error occured, get error with [VirgilKeyManager lastError]
 */
- (VirgilPublicKey *) getPublicKey:(NSString *) account {
    _lastError = nil;
    
    if (nil == account) return nil;
    
    // Try to load public key from key chain
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    if (keyChainContainer != nil) {
        return keyChainContainer.publicKey;
    }
    
    // Request key from net
    VSSCard * card = [self cardForAccount:account];
    if (card == nil) return nil;
    
    NSString * keyStr = [[NSString alloc] initWithData : card.publicKey.key
                                              encoding : NSASCIIStringEncoding];
    VirgilPublicKey *resPubKey = [[VirgilPublicKey alloc] initCardID : card.Id
                                                         publicKeyID : card.publicKey.Id
                                                           publicKey : keyStr
                                                          identityID : card.identity.Id];
    // Save received key to keychain
    keyChainContainer = [[VirgilKeyChainContainer alloc] initWithPrivateKey : nil
                                                               andPublicKey : resPubKey
                                                                   isActive : YES
                                                           isWaitPrivateKey : NO
                                                          isWaitForDeletion : NO];
    [VirgilKeyChain saveContainer : keyChainContainer
                       forAccount : account];
    return resPubKey;
}

- (GUID *) requestIdentityVerificationForAccount : (NSString *)account {
    if (nil == account) {
        [self setErrorString : @"wrong params for account creation"];
        return nil;
    }
    
    __block GUID * res = nil;
    _lastError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [_client verifyIdentityWithType : VSSIdentityTypeEmail
                              value : account
                  completionHandler : ^(GUID * _Nullable actionId, NSError * _Nullable error) {
                      if (error == nil) {
                          res = actionId;
                      } else {
                          _lastError = error.localizedDescription;
                      }
                      dispatch_semaphore_signal(semaphore);
                  }];
    dispatch_semaphore_wait(semaphore, [self timeout]);
    
    return res;
}

/**
 * @brief Create key pair, register at Key service
 * @param account - email
 * @param keyPassword - password for keys encryption
 * @param containerType - container type {easy, normal, paranoic}
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) createAccount : (NSString *) account
           keyPassword : (NSString *) keyPassword
         containerType : (VirgilContainerType) containerType {
    
    GUID * actionId = [self requestIdentityVerificationForAccount:account];
    
    if (actionId == nil) return NO;
    
    // Generate keys
    VSSKeyPair * keyPair = [[VSSKeyPair alloc] initWithPassword : keyPassword];
    
    NSString * pubKey = [[NSString alloc] initWithData : keyPair.publicKey
                                              encoding : NSUTF8StringEncoding];
    NSString * privKey = [[NSString alloc] initWithData : keyPair.privateKey
                                               encoding : NSUTF8StringEncoding];
    VirgilPrivateKey * privateKeyInfo =
    [[VirgilPrivateKey alloc] initAccount : account
                            containerType : containerType
                               privateKey : privKey
                              keyPassword : keyPassword];
    
    VirgilPublicKey * publicKeyInfo =
    [[VirgilPublicKey alloc] initCardID : @"000"
                            publicKeyID : @"000"
                              publicKey : pubKey
                             identityID : @"000"];
    publicKeyInfo.actionID = actionId;
    
    VirgilKeyChainContainer * container =
    [[VirgilKeyChainContainer alloc] initWithPrivateKey : privateKeyInfo
                                           andPublicKey : publicKeyInfo
                                               isActive : NO
                                       isWaitPrivateKey : NO
                                      isWaitForDeletion : NO];
    [VirgilKeyChain saveContainer : container
                       forAccount : account];
    
    return YES;
}

/**
 * @brief Request account deletion
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) requestAccountDeletion : (NSString *)account {
    GUID * actionId = [self requestIdentityVerificationForAccount:account];
    if (actionId == nil) return NO;
    
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    
    if (keyChainContainer != nil) {
        keyChainContainer.publicKey.actionID = actionId;
        keyChainContainer.isWaitForDeletion = YES;
        [VirgilKeyChain saveContainer : keyChainContainer
                           forAccount : account];
        return YES;
    }
    return NO;
}

- (BOOL) deleteCardWithCardId : (GUID *)cardId
                     identity : (NSDictionary *)identity
                   privateKey : (VirgilPrivateKey *)privateKey {
    _lastError = nil;
    if (nil == cardId ||
        nil == identity ||
        nil == privateKey) {
        [self setErrorString : @"wrong params for card deletion"];
        return NO;
    }
    
    __block BOOL res = NO;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    VSSPrivateKey * vssPrivKey =
    [[VSSPrivateKey alloc] initWithKey : [privateKey.key dataUsingEncoding : NSUTF8StringEncoding]
                              password : privateKey.keyPassword];
    [_client deleteCardWithCardId : cardId
                         identity : identity
                       privateKey : vssPrivKey
                completionHandler : ^(NSError * _Nullable error) {
                    if (error == nil) {
                        res = YES;
                    } else {
                        _lastError = error.localizedDescription;
                    }
                    dispatch_semaphore_signal(semaphore);
                }
     ];
    dispatch_semaphore_wait(semaphore, [self timeout]);
    
    if (res) {
        // Remove keys from keychain
        [VirgilKeyChain removeContainer:privateKey.account];
    }
    
    return res;
}

/**
 * @brief Confirm account deletion with received (by email) code
 * @param account - email
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) confirmAccountDeletion : (NSString *) account
                           code : (NSString *) code {
    if (nil == account) {
        [self setErrorString : @"wrong account for confirmation"];
        return NO;
    }
    
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    if (nil == keyChainContainer) {
        [self setErrorString : @"account not present for confirmation"];
        return NO;
    }
    
    NSDictionary * identity = [self confirmIdentityWithActionId : keyChainContainer.publicKey.actionID
                                                       withCode : code];
    if (identity == nil) return NO;
    
    return [self deleteCardWithCardId : keyChainContainer.publicKey.cardID
                             identity : identity
                           privateKey : keyChainContainer.privateKey];
}

/**
 * @brief Terminate account deletion
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) terminateAccountDeletion : (NSString *)account {
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    
    if (keyChainContainer != nil) {
        keyChainContainer.isWaitForDeletion = NO;
        [VirgilKeyChain saveContainer : keyChainContainer
                           forAccount : account];
        return YES;
    }
    return NO;
}

/**
 * @brief Terminate provate key request
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) terminatePrivateKeyRequest : (NSString *)account {
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    
    if (keyChainContainer != nil) {
        keyChainContainer.isWaitPrivateKey = NO;
        [VirgilKeyChain saveContainer : keyChainContainer
                           forAccount : account];
        return YES;
    }
    return NO;
}

/**
 * @brief Confirm private key request with received (by email) code
 * @param account - email
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) confirmPrivateKeyRequest : (NSString *) account
                             code : (NSString *) code {
    if (nil == account) {
        [self setErrorString : @"wrong account for confirmation"];
        return NO;
    }
    
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    if (nil == keyChainContainer) {
        [self setErrorString : @"account not present for confirmation"];
        return NO;
    }
    
    return [self confirmPrivateKeyRequestWithCode : code
                                          account : account
                                     keyContainer : keyChainContainer];
}

- (NSDictionary *) confirmIdentityWithActionId : (GUID *) actionId
                                      withCode : (NSString *) confirmationCode {
    if (nil == confirmationCode) {
        [self setErrorString : @"wrong params for account confirmation"];
        return nil;
    }
    
    __block NSDictionary * res = nil;
    _lastError = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [_client confirmIdentityWithActionId : actionId
                                    code : confirmationCode
                                     ttl : nil
                                     ctl : nil
                       completionHandler :^(VSSIdentityType type, NSString * _Nullable value, NSString * _Nullable validationToken, NSError * _Nullable error) {
                           if (error == nil) {
                               res = @{kVSSModelType : kVSSIdentityTypeEmail,
                                       kVSSModelValue: value,
                                       kVSSModelValidationToken : validationToken};
                           } else {
                               _lastError = error.localizedDescription;
                           }
                           dispatch_semaphore_signal(semaphore);
                       }];
    dispatch_semaphore_wait(semaphore, [self timeout]);
    
    return res;
}

- (NSString *) grabPrivateKeyWithIdentity : (NSDictionary *)identity
                                   cardId : (GUID *)cardId {
    __block NSString * res = nil;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [_client grabPrivateKeyWithIdentity : identity
                                 cardId : cardId
                               password : @""
                      completionHandler : ^(NSData * _Nullable keyData, GUID * _Nullable cardId, NSError * _Nullable error) {
                          if (error == nil) {
                              res = [[NSString alloc] initWithData:keyData encoding:NSUTF8StringEncoding];
                          } else {
                              _lastError = error.localizedDescription;
                          }
                          dispatch_semaphore_signal(semaphore);
                      }];
    dispatch_semaphore_wait(semaphore, [self timeout]);
    
    return res;
}

/**
 * @brief Confirm private key request with received (by email) code
 * @param code - code from email
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) confirmPrivateKeyRequestWithCode : (NSString *) code
                                  account : (NSString *) account
                             keyContainer : (VirgilKeyChainContainer *) container {
    _lastError = nil;
    if (nil == code ||
        nil == container) {
        [self setErrorString : @"wrong params for private key request confirmation"];
        return NO;
    }
    
    NSDictionary * identity = [self confirmIdentityWithActionId : container.publicKey.actionID
                                                       withCode : code];
    if (identity == nil) return NO;
    
    NSString * key = [self grabPrivateKeyWithIdentity : identity
                                               cardId : container.publicKey.cardID];
    if (key == nil) return NO;
    
    return [self prepareAndSaveLoadedPrivateKey : key
                                  containerType : VirgilContainerNormal
                                        account : account];
}

/**
 * @brief Confirm account creation with received (by email) code
 * @param account - email
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) confirmAccountCreation : (NSString *) account
                           code : (NSString *) code {
    if (nil == account) {
        [self setErrorString : @"wrong account for confirmation"];
        return NO;
    }
    
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    if (nil == keyChainContainer) {
        [self setErrorString : @"account not present for confirmation"];
        return NO;
    }
    
    return [self confirmAccountCreationWithCode : code
                                   keyContainer : keyChainContainer];
}

- (VSSCard *) createCardWithIdentity : (NSDictionary *) identity
                           publicKey : (VirgilPublicKey *) publicKey
                          privateKey : (VirgilPrivateKey *) privateKey {
    if (identity == nil || publicKey == nil || privateKey == nil) {
        [self setErrorString : @"wrong params for card creation"];
        return nil;
    }
    
    __block VSSCard * res = nil;
    
    VSSPrivateKey * vssPrivKey =
    [[VSSPrivateKey alloc] initWithKey : [privateKey.key dataUsingEncoding : NSUTF8StringEncoding]
                              password : privateKey.keyPassword];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [_client createCardWithPublicKey : [publicKey.publicKey dataUsingEncoding : NSUTF8StringEncoding]
                            identity : identity
                                data : nil
                               signs : nil
                          privateKey : vssPrivKey
                   completionHandler : ^(VSSCard * _Nullable card, NSError * _Nullable error) {
                       if (error == nil) {
                           res = card;
                       } else {
                           _lastError = error.localizedDescription;
                       }
                       dispatch_semaphore_signal(semaphore);
                   }];
    dispatch_semaphore_wait(semaphore, [self timeout]);
    
    return res;
}

- (BOOL) storeInCloudPrivateKey : (VirgilPrivateKey *)privateKey
                         cardId : (GUID *) cardId {
    if (privateKey == nil || cardId == nil) {
        [self setErrorString : @"wrong params for card creation"];
        return NO;
    }
    
    __block BOOL res = NO;
    VSSPrivateKey * vssPrivKey =
    [[VSSPrivateKey alloc] initWithKey : [privateKey.key dataUsingEncoding : NSUTF8StringEncoding]
                              password : privateKey.keyPassword];
    dispatch_semaphore_t storeKeySemaphore = dispatch_semaphore_create(0);
    [_client storePrivateKey : vssPrivKey
                      cardId : cardId
           completionHandler : ^(NSError * _Nullable error) {
               if (error == nil) {
                   res = YES;
               } else {
                   NSLog(@"ERROR: Can't store private key : %@", error);
               }
               dispatch_semaphore_signal(storeKeySemaphore);
           }];
    dispatch_semaphore_wait(storeKeySemaphore, [self timeout]);
    
    return res;
}

/**
 * @brief Confirm account creation with received (by email) code
 * @param code - code from email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) confirmAccountCreationWithCode : (NSString *) code
                           keyContainer : (VirgilKeyChainContainer *) container {
    
    _lastError = nil;
    if (nil == code ||
        nil == container) {
        [self setErrorString : @"wrong params for account confirmation"];
        return NO;
    }
    
    NSDictionary * identity = [self confirmIdentityWithActionId : container.publicKey.actionID
                                                       withCode : code];
    if (identity == nil) return NO;
    
    VSSCard * createdCard = [self createCardWithIdentity : identity
                                               publicKey : container.publicKey
                                              privateKey : container.privateKey];
    if (createdCard == nil) return NO;
    
    BOOL res = NO;
    
    // ------------ Update card id in container ------------
    NSString * keyStr = [[NSString alloc] initWithData : createdCard.publicKey.key
                                              encoding : NSUTF8StringEncoding];
    VirgilPublicKey * pubKey = [[VirgilPublicKey alloc]
                                initCardID  : createdCard.Id
                                publicKeyID : createdCard.publicKey.Id
                                publicKey   : keyStr
                                identityID  : createdCard.identity.Id];
    
    VirgilKeyChainContainer * updatedContainer =
    [[VirgilKeyChainContainer alloc] initWithPrivateKey : container.privateKey
                                           andPublicKey : pubKey
                                               isActive : YES
                                       isWaitPrivateKey : NO
                                      isWaitForDeletion : NO];
    [VirgilKeyChain saveContainer : updatedContainer
                       forAccount : updatedContainer.privateKey.account];
    
    // ----------- ~Update card id in container ------------
    
    // --------- Push private key to server if need --------
    if (container.privateKey.containerType != VirgilContainerParanoic) {
        res = [self storeInCloudPrivateKey : container.privateKey
                                    cardId : createdCard.Id];
    } else {
        res = YES;
    }
    // -------- ~Push private key to server if need --------
    
    return res;
}

/**
 * @brief Resend confirmation email for account creation
 * @param account - email
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) resendConfirmEMail : (NSString *) account {
    if (nil == account) {
       [self setErrorString : @"wrong account for resend confirmation email"];
        return NO;
    }
    
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    if (nil == keyChainContainer) {
        [self setErrorString : @"account not present for resend confirmation email"];
        return NO;
    }
    return [self resendConfirmEMail : keyChainContainer.publicKey
                         privateKey : keyChainContainer.privateKey];
}

/**
 * @brief Resend confirmation email
 * @param publicKeyId - public key id
 * @param privateKey - private key
 * @return YES - success | NO - error occured, get error with [VirgilKeyManager lastError]
 */
- (BOOL) resendConfirmEMail : (VirgilPublicKey *) publicKey
                 privateKey : (VirgilPrivateKey *) privateKey {
    
    if (nil == publicKey || nil == privateKey) {
        [self setErrorString : @"wrong params for resend confirmation email"];
        return NO;
    }
    
    return [self createAccount : privateKey.account
                   keyPassword : privateKey.keyPassword
                 containerType : privateKey.containerType];
}

/**
 * @brief Request private key by account (email) from Private Keys Service
 * @param account - email
 * @return boolean YES if resuest was sent correctly
 */
- (BOOL) requestPrivateKeyFromCloud : (NSString *) account {
    _lastError = nil;
    
    if (nil == account) {
        [self setErrorString : @"wrong params for private key request"];
        return NO;
    }
    
    GUID * actionId = [self requestIdentityVerificationForAccount:account];
    if (actionId == nil) return NO;
    
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    
    if (keyChainContainer != nil) {
        keyChainContainer.publicKey.actionID = actionId;
        keyChainContainer.isWaitPrivateKey = YES;
        [VirgilKeyChain saveContainer : keyChainContainer
                           forAccount : account];
        return YES;
    }
    return NO;
}

/**
 * @brief Set private key for account
 * @param key - private key
 * @param account - account
 * @return BOOL YES - set done | NO - error was occured
 */
- (BOOL) setPrivateKey : (VirgilPrivateKey *) key
            forAccount : (NSString *) account {
    if (nil == key || nil == account) return NO;
    
    VirgilPublicKey * publicKey = nil;
    VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
    
    if (nil == keyChainContainer || nil == keyChainContainer.publicKey) {
        publicKey = [self getPublicKey : account];
        keyChainContainer = [VirgilKeyChain loadContainer : account];
    } else {
        publicKey = keyChainContainer.publicKey;
    }
    
    if (nil == publicKey) return NO;
    
    VirgilKeyChainContainer * container = [[VirgilKeyChainContainer alloc] initWithPrivateKey : key
                                                                                 andPublicKey : publicKey
                                                                                     isActive : YES
                                                                             isWaitPrivateKey : NO
                                                                            isWaitForDeletion : NO];
    [VirgilKeyChain saveContainer:container forAccount:account];
    return YES;
}

/**
 * @brief Get last error user friendly string
 */
- (NSString *) lastError {
    return _lastError;
}

/**
 * @brief [Internal use] Set last error string
 * @param errorStr - error description
 */
- (void) setErrorString : (NSString *) errorStr {
    _lastError = [[NSString alloc] initWithFormat : @"%@", errorStr];
}

/**
 * @brief Export account to file
 * @param account - account
 * @param fileName - result file
 * @param passwordForEncryption - password which used to encrypt result file
 * @return BOOL YES - set done | NO - error was occured
 */
- (BOOL) exportAccountData : (NSString *) account
                    toFile : (NSString *) fileName
              withPassword : (NSString *) passwordForEncryption {
    
    NSString * errorString = [NSString stringWithFormat:@"Can't save data to %@", [fileName lastPathComponent]];
    
    VirgilKeyChainContainer * container = [VirgilKeyChain loadContainer : account];
    if (nil == container) {
        [self setErrorString:errorString];
        return NO;
    }
    NSMutableDictionary * idntityDict = [NSMutableDictionary new];
    [idntityDict setObject : container.privateKey.account forKey:@"value"];
    [idntityDict setObject : @"email" forKey:@"type"];
    
    NSMutableDictionary * publicKeyDict = [NSMutableDictionary new];
    [publicKeyDict setObject : container.publicKey.publicKeyID forKey:@"id"];
    [publicKeyDict setObject : [container.publicKey.publicKey base64Wrap] forKey:@"value"];

    NSMutableDictionary * cardDict = [NSMutableDictionary new];
    [cardDict setObject : container.publicKey.cardID forKey:@"id"];
    [cardDict setObject : idntityDict forKey:@"identity"];
    [cardDict setObject : publicKeyDict forKey:@"public_key"];
    
    NSMutableDictionary * jsonDict = [NSMutableDictionary new];
    [jsonDict setObject : cardDict forKey:@"card"];
    [jsonDict setObject : [container.privateKey.key base64Wrap] forKey:@"private_key"];
    
    NSArray * jsonArray = [NSArray arrayWithObjects:jsonDict, nil];
    
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject : jsonArray
                                                        options : 0
                                                          error : &error];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\"true\"" withString:@"true"];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\"false\"" withString:@"false"];
    jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", container);
    
    NSData * preparedData = nil;
    if (passwordForEncryption && passwordForEncryption.length) {
        VSSCryptor * crypto = [VSSCryptor new];
        [crypto addPasswordRecipient : passwordForEncryption];
        preparedData = [crypto encryptData : jsonData
                          embedContentInfo : @YES];
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
- (VirgilKeyChainContainer *) importAccountData : (NSString *) account
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
        jsonData = [[VSSCryptor new] decryptData : encryptedData
                                        password : passwordForDecryption];
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
        NSString * privateKey = [jsonDict objectForKey:@"private_key"];
        
        NSDictionary * cardDict = [jsonDict objectForKey:@"card"];
        NSDictionary * identityDict = [cardDict objectForKey:@"identity"];
        NSString * importAccount = [identityDict objectForKey:@"value"];
        
        if ([importAccount isEqualTo:account]) {
            VirgilKeyChainContainer * keyChainContainer = [VirgilKeyChain loadContainer : account];
            if (keyChainContainer) {
                VirgilPrivateKey * updatedPrivateKey =
                [[VirgilPrivateKey alloc] initAccount : account
                                        containerType : VirgilContainerNormal
                                           privateKey : privateKey
                                          keyPassword : nil // Password will be requested later
                 ];
                VirgilKeyChainContainer * updatedConteiner =
                 [[VirgilKeyChainContainer alloc] initWithPrivateKey : updatedPrivateKey
                                                        andPublicKey : keyChainContainer.publicKey
                                                            isActive : YES
                                                    isWaitPrivateKey : NO
                                                   isWaitForDeletion : NO];
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

- (BOOL) prepareAndSaveLoadedPrivateKey : (NSString *) key
                          containerType : (VirgilContainerType) containerType
                                account : (NSString *) account {
    BOOL res = NO;
    VirgilPrivateKey * decryptedKey = nil;
    
    // Check is need to ask for private key password
    NSString * userPassword = nil;
    
    if ([VirgilKeyManager isCorrectEncryptedPrivateKey : key]) {
        userPassword = [VirgilGui getUserPassword];
        if (nil != userPassword) {
            res = YES;
        }
    }
    
    if (!res) {
        res = [VirgilKeyManager isCorrectPrivateKey : key];
    }
    
    if (res) {
        decryptedKey = [[VirgilPrivateKey alloc] initAccount : account
                                               containerType : containerType
                                                  privateKey : key
                                                 keyPassword : userPassword];
        [[VirgilKeyManager sharedInstance] setPrivateKey : decryptedKey
                                              forAccount : account];
    }
    return res;
}

/**
 * @brief Check is correct private key.
 * @return boolean is key correct
 */
+ (BOOL) isCorrectPrivateKey : (NSString *) privateKey {
    if (!privateKey) return NO;
    return [privateKey containsString:@"-----BEGIN EC PRIVATE KEY-----"];
}

/**
 * @brief Check is correct encrypted private key.
 * @return boolean is key correct
 */
+ (BOOL) isCorrectEncryptedPrivateKey : (NSString *) privateKey {
    if (!privateKey) return NO;
    return [privateKey containsString:@"-----BEGIN ENCRYPTED PRIVATE KEY-----"];
}

@end
