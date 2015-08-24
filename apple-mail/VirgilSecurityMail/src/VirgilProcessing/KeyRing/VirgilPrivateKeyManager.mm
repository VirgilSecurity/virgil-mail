//
//  VirgilPrivateKeyManager.m
//  TestGUI
//
//  Created by Роман Куташенко on 24.08.15.
//  Copyright (c) 2015 Virgil Security. All rights reserved.
//

#import "VirgilPrivateKeyManager.h"
#import "VirgilPrivateKeyEndpoints.h"
#import "VirgilHelpers.h"
#import "VirgilPrivateKey.h"
#import "VirgilCryptoLibWrapper.h"
#import "NSData+Base64.h"

//------------ Static variables -------------
static NSMutableDictionary * _privateKeyCache = [[NSMutableDictionary alloc] init];
VirgilPrivateKeyEndpoints * endpoints =
        [[VirgilPrivateKeyEndpoints alloc] initWithBaseURL : [VirgilHelpers privateKeysURLBase]];
//------------ ~Static variables -------------

@implementation VirgilPrivateKeyManager

+ (NSString *) createSession : (NSString *) account
                    password : (NSString *) password {
    // Prepare JSON data
    NSDictionary * dictRequestData = @{
                                       @"password" : password,
                                       @"user_data" : @{
                                               @"class" : @"user_id",
                                               @"type" : @"email",
                                               @"value" : account}
                                       };
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject : dictRequestData
                                                          options : 0
                                                            error : &error];
    // Create request
    NSURL *url = [NSURL URLWithString : [endpoints getToken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setURL : url];
    [request setHTTPMethod : @"POST"];
    [request addValue : [VirgilHelpers applicationToken]
   forHTTPHeaderField : @"X-VIRGIL-APPLICATION-TOKEN"];
    [request setValue : @"application/json"
   forHTTPHeaderField : @"Content-Type"];
    [request setHTTPBody : requestData];
    [request setTimeoutInterval : 5.0];
    [request setCachePolicy : NSURLRequestReloadIgnoringCacheData];
    
    NSURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest : request
                                               returningResponse : &response
                                                           error : &error];
    
    if (nil == error && nil != returnData) {
        id resultJSON = [NSJSONSerialization JSONObjectWithData : returnData
                                                        options : 0
                                                          error : &error];
        if(nil != error) return nil;
        
        NSLog(@"response = %@", response);
        
        if([resultJSON isKindOfClass:[NSDictionary class]]) {
            NSString * res = [resultJSON objectForKey : @"auth_token"];
            return res;
        }
    }
    
    return nil;
}

+ (NSString *) requestKeyWithPublicID : (NSString *) publicKeyID
                            authToken : (NSString *) authToken {
    if (nil == publicKeyID || nil == authToken) return nil;
    
    // Create request
    NSURL *url = [NSURL URLWithString : [endpoints getPrivateKeyByPublicID : publicKeyID]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setURL : url];
    [request setHTTPMethod : @"GET"];
    [request addValue : [VirgilHelpers applicationToken]
   forHTTPHeaderField : @"X-VIRGIL-APPLICATION-TOKEN"];
    [request addValue : authToken
   forHTTPHeaderField : @"X-VIRGIL-AUTHENTICATION"];
    [request setTimeoutInterval : 5.0];
    [request setCachePolicy : NSURLRequestReloadIgnoringCacheData];
    
     NSLog(@"NSURLRequest : %@", request);
    
    NSError *error;
    NSURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest : request
                                               returningResponse : &response
                                                           error : &error];
    
    if (nil == error && nil != returnData) {
        id resultJSON = [NSJSONSerialization JSONObjectWithData : returnData
                                                        options : 0
                                                          error : &error];
        if(nil != error) return nil;
        
        if([resultJSON isKindOfClass:[NSDictionary class]]) {
            NSLog(@"resultJSON = %@", resultJSON);
            NSString * res = [resultJSON objectForKey : @"private_key"];
            return res;
        }
    }
    
    return nil;
}

+ (VirgilPrivateKey *) getPrivateKey : (NSString *) account
                            password : (NSString *) password
                         publicKeyID : (NSString *) publicKeyID {
    // Search for key in cache
    VirgilPrivateKey * res([_privateKeyCache objectForKey : account]);
    if (nil != res) {
        return res;
    }
    
    // Key in cache not present, lets download it
    
    // Get auth token
    NSString * authToken = [VirgilPrivateKeyManager createSession : account
                                                         password : password];
    if (nil == authToken) return nil;
    
    NSLog(@"authToken = %@", authToken);
    
    NSString * privateKey = [VirgilPrivateKeyManager requestKeyWithPublicID : publicKeyID
                                                                  authToken : authToken];
    if (nil == privateKey) return nil;
    
    res = [[VirgilPrivateKey alloc] initAccount : account
                                       password : password
                                     privateKey : privateKey];
    
    // Add new key to cache
    [_privateKeyCache setObject : res
                         forKey : account];
    
    NSLog(@"Private key : %@", res);
    
    return res;
}

+ (BOOL) pushPrivateKey : (VirgilPrivateKey *) key {
    if (nil == key) return NO;
    
    // Get auth token
    NSString * authToken = [VirgilPrivateKeyManager createSession : key.account
                                                         password : key.password];
    if (nil == authToken) return NO;
    
    // Prepare request data
    NSData * keyData = [key.key dataUsingEncoding : NSUTF8StringEncoding];
    NSDictionary * dictRequestData = @{@"private_key" : [keyData base64EncodedString]};
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject : dictRequestData
                                                          options : 0
                                                            error : &error];
    NSData * signatureData =
    [VirgilCryptoLibWrapper signatureForData : requestData
                              withPrivateKey : key.key
                           privatKeyPassword : key.password];
    NSString * signature = [signatureData base64EncodedString];
    
    // Create request
    NSURL *url = [NSURL URLWithString : [endpoints getKeyPush]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setURL : url];
    [request setHTTPMethod : @"POST"];
    
    [request addValue : [VirgilHelpers applicationToken]
   forHTTPHeaderField : @"X-VIRGIL-APPLICATION-TOKEN"];
    
    [request addValue : authToken
   forHTTPHeaderField : @"X-VIRGIL-AUTHENTICATION"];
    
    [request addValue : signature
   forHTTPHeaderField : @"X-VIRGIL-REQUEST-SIGN"];
    
    [request addValue : [VirgilHelpers _nsuuid]
   forHTTPHeaderField : @"X-VIRGIL-REQUEST-SIGN-PK-ID"];
    
    [request setValue : @"application/json"
   forHTTPHeaderField : @"Content-Type"];
    
    [request setHTTPBody : requestData];
    [request setTimeoutInterval : 5.0];
    [request setCachePolicy : NSURLRequestReloadIgnoringCacheData];
    
    NSLog(@"NSURLRequest : %@", request);
    
    NSURLResponse *response;
    [NSURLConnection sendSynchronousRequest : request
                          returningResponse : &response
                                      error : &error];
    NSLog(@"response : %@", response);
    if (nil == error) {
        return YES;
    }
    
    return NO;
}

@end
