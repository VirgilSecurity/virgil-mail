//
//  VirgilHelpers.m
//  TestGUI
//
//  Created by Роман Куташенко on 24.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilHelpers.h"

#include <chrono>
#include <random>

//------------ Static variables -------------
//NSString * VIRGIL_APPLICATION_TOKEN = @"e88c4106cfddb959d62afb14a767c3e9";
NSString * VIRGIL_APPLICATION_TOKEN = @"1fab311f9ae38a416e84980256cd5878";
NSString * VIRGIL_KEYS_URL_BASE = @"https://keys-stg.virgilsecurity.com/";
NSString * VIRGIL_KEYS_PRIVATE_URL_BASE = @"https://keyring-stg.virgilsecurity.com/";
//------------ ~Static variables -------------

@implementation VirgilHelpers

+ (std::string) _strNS2Std : (NSString *)string {
    if (!string) return std::string();
    return [string UTF8String];
}

+ (NSString *) _strStd2NS : (std::string)string {
    return [NSString stringWithCString : string.c_str()
                              encoding : NSUTF8StringEncoding];
}

+ (std::string) _uuid {
    auto seed(std::chrono::system_clock::now().time_since_epoch().count());
    std::default_random_engine generator(seed);
    
    uint32_t time_low = ((generator() << 16) & 0xffff0000) | (generator() & 0xffff);
    uint16_t time_mid = generator() & 0xffff;
    uint16_t time_high_and_version = (generator() & 0x0fff) | 0x4000;
    uint16_t clock_seq = (generator() & 0x3fff) | 0x8000;
    uint8_t node [6];
    for (size_t i = 0; i < 6; ++i) {
        node[i] = generator() & 0xff;
    }
    
    char buffer[37] = {0x0};
    sprintf(buffer, "%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
            time_low, time_mid, time_high_and_version, clock_seq >> 8, clock_seq & 0xff,
            node[0], node[1], node[2], node[3], node[4], node[5]);
    
    return std::string(buffer);
}

+ (NSString *) _nsuuid {
    return [VirgilHelpers _strStd2NS : [VirgilHelpers _uuid]];
}

+ (NSString *) applicationToken {
    return VIRGIL_APPLICATION_TOKEN;
}

+ (NSString *) keysURLBase {
    return VIRGIL_KEYS_URL_BASE;
}

+ (NSString *) privateKeysURLBase {
    return VIRGIL_KEYS_PRIVATE_URL_BASE;
}

@end
