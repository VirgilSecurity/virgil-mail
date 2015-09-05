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

#import "VirgilPrivateKeyManager.h"
#import "VirgilPrivateKeyEndpoints.h"
#import "VirgilHelpers.h"
#import "VirgilPrivateKey.h"
#import "VirgilCryptoLibWrapper.h"
#import "VirgilNetRequest.h"
#import "NSData+Base64.h"

@implementation VirgilPrivateKeyManager

//! _lastError - contains user friendly error string
static NSString * _lastError = nil;

//! _endpoints - helper object for getting endpoints strings
static VirgilPrivateKeyEndpoints * _endpoints =
[[VirgilPrivateKeyEndpoints alloc] initWithBaseURL : [VirgilHelpers privateKeysURLBase]];

/**
 * @brief [Internal use] Remove escaping of slashes. (Workaround of bug KRS-10)
 * @param jsonData - serialized json data
 * @return jsonData with removed escape of slashes
 */
+ (NSData *) fixJSONEscaping : (NSData *) jsonData {
    NSString * jsonStr = [[NSString alloc] initWithData : jsonData
                                               encoding : NSUTF8StringEncoding];
    return [[jsonStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"]
            dataUsingEncoding : NSUTF8StringEncoding];
}

/**
 * @brief [Internal use] Prepare data for send from json dictionary
 * @param jsonDictionary - json data placed to dictionary
 * @return jsonData with removed escape of slashes
 */
+ (NSData *) prepareJSONDataForSend : (NSDictionary *) jsonDictionary {
    if (nil == jsonDictionary) return  nil;
    NSError * error = nil;
    NSData * requestData = [NSJSONSerialization dataWithJSONObject : jsonDictionary
                                                           options : 0
                                                             error : &error];
    if (nil != error) return nil;
    return [VirgilPrivateKeyManager fixJSONEscaping : requestData];
}

/**
 * @brief [Internal use] Create BASE64 signature for given data
 * @param data - data to sign
 * @param privateKey - VirgilPrivateKey instance
 * @return base64 encoded signature
 */
+ (NSString *) signData : (NSData *) data
             privateKey : (VirgilPrivateKey *) privateKey {
    if (nil == data || nil == privateKey) return nil;
    NSData * signatureData =
    [VirgilCryptoLibWrapper signatureForData : data
                              withPrivateKey : privateKey.key
                           privatKeyPassword : privateKey.keyPassword];
    if (nil == signatureData) return nil;
    return [signatureData base64EncodedStringWithSeparateLines : NO];
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
    _lastError = [[NSString alloc] initWithFormat : @"VirgilPrivateKeyManager error : %@", errorStr];
}

/**
 * @brief [Internal use] Create container for private key at Private Key Service
 * @param publicKeyID - public key id for key pair verification
 * @param privateKey - VirgilPrivateKey instance
 * @return YES - success creation | NO - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (BOOL) createContainerForPublicKeyID : (NSString *) publicKeyID
                        withPrivateKey : (VirgilPrivateKey *) privateKey {
    _lastError = nil;
    if (nil == publicKeyID || nil == privateKey) {
        [VirgilPrivateKeyManager setErrorString : @"wrong data for container creation"];
        return NO;
    }
    // Prepare request data
    NSString * containerType = (VirgilContainerEasy == privateKey.containerType ? @"easy" : @"normal");
    NSDictionary * dictRequestData = @{@"container_type" : containerType,
                                       @"password" : privateKey.containerPassword,
                                       @"request_sign_uuid" : [VirgilHelpers _nsuuid]
                                       };
    NSData * data = [VirgilPrivateKeyManager prepareJSONDataForSend : dictRequestData];
    NSString * signature = [VirgilPrivateKeyManager signData : data
                                                  privateKey : privateKey];
    NSDictionary * headers = @{@"Content-Type" : @"application/json",
                               @"X-VIRGIL-APPLICATION-TOKEN" : [VirgilHelpers applicationToken],
                               @"X-VIRGIL-REQUEST-SIGN" : signature,
                               @"X-VIRGIL-REQUEST-SIGN-PK-ID" : publicKeyID};
    
    if ([VirgilNetRequest post : [_endpoints getContainer]
                       headers : headers
                          data : data]) {
        return YES;
    }
    [VirgilPrivateKeyManager setErrorString : [VirgilNetRequest lastError]];
    return NO;
}

/**
 * @brief [Internal use] Create session with Private Key Service and get autentification token
 * @param account - email
 * @param containerPassword - Container's password
 * @return Autentification token | nil - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (NSString *) createSession : (NSString *) account
           containerPassword : (NSString *) containerPassword {
    _lastError = nil;
    if (nil == account || nil == containerPassword) {
        [VirgilPrivateKeyManager setErrorString : @"wrong data for session creation"];
        return nil;
    }
    // Prepare request data
    NSDictionary * dictRequestData = @{
                                       @"password" : containerPassword,
                                       @"user_data" : @{
                                               @"class" : @"user_id",
                                               @"type" : @"email",
                                               @"value" : account},
                                       @"request_sign_uuid" : [VirgilHelpers _nsuuid]
                                       };
    NSData * data = [VirgilPrivateKeyManager prepareJSONDataForSend : dictRequestData];
    
    NSDictionary * headers = @{@"Content-Type" : @"application/json",
                               @"X-VIRGIL-APPLICATION-TOKEN" : [VirgilHelpers applicationToken]};
    
    if ([VirgilNetRequest post : [_endpoints getToken]
                       headers : headers
                          data : data]) {
        NSError * error = nil;
        id resultJSON = [NSJSONSerialization JSONObjectWithData : [VirgilNetRequest lastData]
                                                        options : 0
                                                          error : &error];
        if(nil != error) {
            [VirgilPrivateKeyManager setErrorString : @"wrong response"];
            return nil;
        }
        @try {
            NSString * res = [resultJSON objectForKey : @"auth_token"];
            return res;
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        [VirgilPrivateKeyManager setErrorString : @"wrong response"];
        return nil;
    }
    [VirgilPrivateKeyManager setErrorString : [VirgilNetRequest lastError]];
    return nil;
}

/**
 * @brief [Internal use] Request private key from Private Key Service
 * @param publicKeyID - public key ID for request verification
 * @param authToken - Autentification token received from "createSession"
 * @return BASE64 encoded private key | nil - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (NSString *) requestKeyWithPublicID : (NSString *) publicKeyID
                            authToken : (NSString *) authToken {
    _lastError = nil;
    if (nil == publicKeyID || nil == authToken) {
        [VirgilPrivateKeyManager setErrorString : @"wrong data for private key request"];
        return nil;
    }
    NSDictionary * headers = @{@"Content-Type" : @"application/json",
                               @"X-VIRGIL-APPLICATION-TOKEN" : [VirgilHelpers applicationToken],
                               @"X-VIRGIL-AUTHENTICATION" : authToken};
    
    if ([VirgilNetRequest get : [_endpoints getPrivateKeyByPublicID : publicKeyID]
                      headers : headers]) {
        NSError * error = nil;
        id resultJSON = [NSJSONSerialization JSONObjectWithData : [VirgilNetRequest lastData]
                                                        options : 0
                                                          error : &error];
        if(nil != error) {
            [VirgilPrivateKeyManager setErrorString : @"wrong response"];
            return nil;
        }
        @try {
            NSString * res = [resultJSON objectForKey : @"private_key"];
            return res;
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        [VirgilPrivateKeyManager setErrorString : @"wrong response"];
        return nil;
    }
    [VirgilPrivateKeyManager setErrorString : [VirgilNetRequest lastError]];
    return nil;
}

/**
 * @brief Get private key (paranoic mode not supported yet)
 * @param account - email
 * @param containerPassword - Container's password
 * @param publicKeyID - public key ID for request verification
 * @return VirgilPrivateKey instance | nil - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (VirgilPrivateKey *) getPrivateKey : (NSString *) account
                   containerPassword : (NSString *) containerPassword
                         publicKeyID : (NSString *) publicKeyID {
    _lastError = nil;
    
    if (nil == account) return nil;
    
    if (nil == containerPassword || nil == publicKeyID) return nil;
    
    // Get auth token
    NSString * authToken = [VirgilPrivateKeyManager createSession:account
                                                containerPassword:containerPassword];
    if (nil == authToken) return nil;
    
    NSString * privateKey = [VirgilPrivateKeyManager requestKeyWithPublicID : publicKeyID
                                                                  authToken : authToken];
    if (nil == privateKey) return nil;
    
    // TODO: get container type
    VirgilContainerType containerType = VirgilContainerEasy;
    
    VirgilPrivateKey * encryptedKey =
          [[VirgilPrivateKey alloc] initAccount : account
                                  containerType : containerType
                                     privateKey : privateKey
                                    keyPassword : nil
                              containerPassword : containerPassword];
    
    VirgilPrivateKey * res = [VirgilPrivateKeyManager decryptKey : encryptedKey];
    if (nil == res) return nil;
    
    return res;
}

/**
 * @brief [Internal use] Decrypt key from Private Key Service.
 * @param key - VirgilPrivateKey instance
 * @return Decrypted key | nil - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (VirgilPrivateKey *) decryptKey : (VirgilPrivateKey *) encryptedKey {
    if (VirgilContainerEasy == encryptedKey.containerType) {
        
        NSData * encryptedKeyData = [NSData dataFromBase64String : encryptedKey.key];
        NSData * decryptedKeyData = [VirgilCryptoLibWrapper decryptData : encryptedKeyData
                                                           withPassword : encryptedKey.containerPassword];
        if (nil == decryptedKeyData) return nil;
        
        return [[VirgilPrivateKey alloc] initAccount : encryptedKey.account
                                       containerType : encryptedKey.containerType
                                          privateKey : [[NSString alloc] initWithData : decryptedKeyData
                                                                             encoding : NSUTF8StringEncoding]
                                         keyPassword : encryptedKey.keyPassword
                                   containerPassword : encryptedKey.containerPassword];
    } else {
        // TODO: support "normal" container type
        [VirgilPrivateKeyManager setErrorString : @"try to decrypt not supported container type"];
    }
    return nil;
}

/**
 * @brief [Internal use] Encrypt key before push to Private Key Service.
 * @param key - VirgilPrivateKey instance
 * @return encrypted and BASE64 encoded private key | nil - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (NSString *) prepareKeyToPush : (VirgilPrivateKey *) key {
    if (VirgilContainerEasy == key.containerType) {
        NSData * keyData = [key.key dataUsingEncoding : NSUTF8StringEncoding];
        NSData * encryptedKey = [VirgilCryptoLibWrapper encryptData : keyData
                                                           password : key.containerPassword];
        return [encryptedKey base64EncodedStringWithSeparateLines : NO];
    } else {
        // TODO: support "normal" container type
        [VirgilPrivateKeyManager setErrorString : @"try to create not supported container type"];
    }
    return nil;
}

/**
 * @brief Push private key (paranoic mode not supported yet)
 * @param key - VirgilPrivateKey instance
 * @param publicKeyID - public key ID for request verification
 * @return YES - success | nil - error occured, get error with [VirgilPrivateKeyManager lastError]
 */
+ (BOOL) pushPrivateKey : (VirgilPrivateKey *) key
        withPublicKeyID : (NSString * ) publicKeyID {
    _lastError = nil;
    
    if (nil == key || nil == publicKeyID) {
        [VirgilPrivateKeyManager setErrorString : @"wrong data for private key push to container"];
        return NO;
    }
    
    if (![VirgilPrivateKeyManager createContainerForPublicKeyID : publicKeyID
                                                 withPrivateKey : key]) {
        return NO;
    }
    
    // Get auth token
    NSString * authToken = [VirgilPrivateKeyManager createSession : key.account
                                                containerPassword : key.containerPassword];
    if (nil == authToken) return NO;
    
    // Prepare key for push
    NSString * encryptedKey = [VirgilPrivateKeyManager prepareKeyToPush : key];
    
    // Prepare request data
    NSDictionary * dictRequestData = @{@"private_key" : encryptedKey,
                                       @"request_sign_uuid" : [VirgilHelpers _nsuuid]
                                       };
    NSData * data = [VirgilPrivateKeyManager prepareJSONDataForSend : dictRequestData];
    NSString * signature = [VirgilPrivateKeyManager signData : data
                                                  privateKey : key];
    NSDictionary * headers = @{@"Content-Type" : @"application/json",
                               @"X-VIRGIL-APPLICATION-TOKEN" : [VirgilHelpers applicationToken],
                               @"X-VIRGIL-AUTHENTICATION" : authToken,
                               @"X-VIRGIL-REQUEST-SIGN" : signature,
                               @"X-VIRGIL-REQUEST-SIGN-PK-ID" : publicKeyID};
    
    if ([VirgilNetRequest post : [_endpoints getKeyPush]
                       headers : headers
                          data : data]) {
        return YES;
    }
    [VirgilPrivateKeyManager setErrorString : [VirgilNetRequest lastError]];
    return NO;
}

@end
