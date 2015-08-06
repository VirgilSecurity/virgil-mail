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

@implementation VirgilCryptoLibWrapper

+ (BOOL) decryptContainer:(VirgilEncryptorContainer **) container {
    if (!(*container)->isEncrypted) return NO;

    try {
        VirgilCipher cipher;

        // Prepare public key id
        const std::string _publicKeyIdData([(*container)->publicKeyID UTF8String]);
        VirgilByteArray publicKeyID(_publicKeyIdData.begin(), _publicKeyIdData.end());
        
        // Prepare private key
        const std::string _privateKeyData([(*container)->privateKey UTF8String]);
        VirgilByteArray privateKey(_privateKeyData.begin(), _privateKeyData.end());
        
        
        // Parse json email body, get EmailData and Signature
        // result in emailDictionary
        NSError *error = nil;
        id mailJSON = [NSJSONSerialization
                     JSONObjectWithData:(*container)->content
                     options:0
                     error:&error];
        
        if(error) {
            NSLog(@"Can't read e-mail JSON");
            return NO;
        }
        
        NSDictionary * emailDictionary = nil;
        if([mailJSON isKindOfClass:[NSDictionary class]]) {
            emailDictionary = mailJSON;
        } else {
            NSLog(@"Can't read e-mail JSON (not a dictionary)");
            return NO;
        }
        
        // Prepare byte array of EmailData
        NSData * dataArray = [NSData dataFromBase64String:[emailDictionary objectForKey:@"EmailData"]];
        VirgilByteArray data;
        data.assign(reinterpret_cast<const unsigned char*>([dataArray bytes]),
                 reinterpret_cast<const unsigned char*>([dataArray bytes]) + [dataArray length]);

        
        // Decrypt EmailData
        const VirgilByteArray _readyData(cipher.decryptWithKey(data,
                                                               publicKeyID,
                                                               privateKey));
        
        NSLog(@"decryptWithKey done : %s", virgil::crypto::bytes2str(_readyData).c_str());
        
        // Verify Email signature
        //TODO:
        
    } catch (std::exception& exception) {
        std::cerr << "Error: " << exception.what() << std::endl;
        const std::string _error(exception.what());
        NSLog(@"decryptWithKey ERROR %s", _error.c_str());
    }
    return NO;
}

@end
