//
//  VirgilHelpers.h
//  TestGUI
//
//  Created by Роман Куташенко on 24.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <string>

@interface VirgilHelpers : NSObject

+ (std::string) _strNS2Std : (NSString *)string;
+ (NSString *) _strStd2NS : (std::string)string;
+ (std::string) _uuid;
+ (NSString *) _nsuuid;

+ (NSString *) applicationToken;
+ (NSString *) keysURLBase;
+ (NSString *) privateKeysURLBase;

@end
