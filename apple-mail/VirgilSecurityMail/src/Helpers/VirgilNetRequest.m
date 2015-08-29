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

#import "VirgilNetRequest.h"
#import "VirgilErrorCodesParser.h"

@implementation VirgilNetRequest

//! _lastError - contains user friendly error string
static NSString * _lastError = nil;

//! _lastData - contains result of last NSURLConnection request
static NSData * _lastData = nil;

/**
 * @brief Send POST request and wait for response
 * @param url - url to request
 * @param headers - dictionary of pairs "header name" : "value"
 * @param data - data for send
 * @return YES - done without error | NO - error present Check with [VirgilNetRequest lastError]
 */
+ (BOOL) post : (NSString *) url
      headers : (NSDictionary *) headers
         data : (NSData *) data {
    return [VirgilNetRequest synchronousRequest : @"POST"
                                            url : url
                                        headers : headers
                                           data : data];
}

/**
 * @brief Send GET request and wait for response
 * @param url - url to request
 * @param headers - dictionary of pairs "header name" : "value"
 * @return YES - done without error | NO - error present Check with [VirgilNetRequest lastError]
 */
+ (BOOL) get : (NSString *) url
     headers : (NSDictionary *) headers {
    return [VirgilNetRequest synchronousRequest : @"GET"
                                            url : url
                                        headers : headers
                                           data : nil];
}

/**
 * @brief Send DELETE request and wait for response
 * @param url - url to request
 * @param headers - dictionary of pairs "header name" : "value"
 * @param data - data for send
 * @return YES - done without error | NO - error present Check with [VirgilNetRequest lastError]
 */
+ (BOOL) del : (NSString *) url
     headers : (NSDictionary *) headers
        data : (NSData *) data {
    return [VirgilNetRequest synchronousRequest : @"DELETE"
                                            url : url
                                        headers : headers
                                           data : data];
}

/**
 * @brief Send PUT request and wait for response
 * @param url - url to request
 * @param headers - dictionary of pairs "header name" : "value"
 * @param data - data for send
 * @return YES - done without error | NO - error present Check with [VirgilNetRequest lastError]
 */
+ (BOOL) put : (NSString *) url
     headers : (NSDictionary *) headers
        data : (NSData *) data {
    return [VirgilNetRequest synchronousRequest : @"PUT"
                                            url : url
                                        headers : headers
                                           data : data];
}

/**
 * @brief [Internal use] Send net request and wait for response
 * @param requestType - one of {GET, POST, PUT, DELETE}
 * @param url - url to request
 * @param headers - dictionary of pairs "header name" : "value"
 * @return YES - done without error | NO - error present Check with [VirgilNetRequest lastError]
 */
+ (BOOL) synchronousRequest : (NSString *) requestType
             url : (NSString *) url
         headers : (NSDictionary *) headers
            data : (NSData *) data {
    
    // Reset request results
    _lastError = nil;
    _lastData = nil;
    
    // Prepare request
    NSURLRequest * request = [self prepareRequest : requestType
                                              url : url
                                          headers : headers
                                             data : data];
    
    // Check possible errors
    if (nil == request) {
        NSString * error =
            [[NSString alloc] initWithFormat : @"url : %@ type : %@", url, requestType];
        [VirgilNetRequest setErrorString : error];
        return NO;
    }
    
    // Send synchronous net request
    NSError * error = nil;
    NSURLResponse * response = nil;
    _lastData = [NSURLConnection sendSynchronousRequest : request
                                      returningResponse : &response
                                                  error : &error];
    if (nil != error) {
        [VirgilNetRequest setErrorString : [error localizedDescription]];
        return NO;
    }
    
    if (nil == data) return YES;
    
    if ([VirgilNetRequest isHTMLResponse : _lastData]) {
        [VirgilNetRequest setErrorString : @"Response is html page"];
        return NO;
    }
    
    id resultJSON = [NSJSONSerialization JSONObjectWithData : _lastData
                                                    options : 0
                                                      error : &error];
    if (nil != error) {
        [VirgilNetRequest setErrorString : [error localizedDescription]];
        return NO;
    }

    if ([VirgilNetRequest isVirgilErrorResponse : resultJSON]) {
        NSString * errorString = [VirgilErrorCodesParser readableErrorFromJSON : _lastData];
        [VirgilNetRequest setErrorString : errorString];
        return NO;
    }
    
    return YES;
}


/**
 * @brief [Internal use] Creator net request
 * @param requestType - one of {GET, POST, PUT, DELETE}
 * @param url - url to request
 * @param headers - dictionary of pairs "header name" : "value"
 * @return class NSURLRequest or nil if error occured
 */
+ (NSURLRequest *) prepareRequest : (NSString *) requestType
                              url : (NSString *) url
                          headers : (NSDictionary *) headers
                             data : (NSData *) data {
    
    // Check possible errors
    if (nil == requestType || nil == url) return nil;
    
    // Create request
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL : [NSURL URLWithString : url]];
    
    [request setHTTPMethod : requestType];
    
    for (NSString * key in [headers allKeys]) {
        [request addValue : [headers valueForKey : key]
       forHTTPHeaderField : key];
    }
    
    if (nil != data) {
        [request setHTTPBody : data];
    }
    
    [request setTimeoutInterval : 5.0];
    [request setCachePolicy : NSURLRequestReloadIgnoringCacheData];
    
    return [request copy];
}

/**
 * @brief [Internal use] Set last error string
 * @param errorStr - error description
 */
+ (void) setErrorString : (NSString *) errorStr {
    _lastError = [[NSString alloc] initWithFormat : @"Net request error : %@", errorStr];
}

/**
 * @brief Get last error user friendly string
 */
+ (NSString *) lastError {
    return _lastError;
}

/**
 * @brief [Internal use] Chech for html in response
 * @param response - response data.
 */
+ (BOOL) isHTMLResponse : (NSData *) response {
    if (nil == response) return NO;
    NSString * strData = [[NSString alloc] initWithData : response
                                               encoding : NSUTF8StringEncoding];
    return [strData containsString : @"<html"];
}

/**
 * @brief [Internal use] Chech for Virgil Error in response
 * @param response - json dictionary of response.
 */
+ (BOOL) isVirgilErrorResponse : (NSDictionary *) response {
    @try {
        NSString * res = [response objectForKey : @"error"];
        return nil != res;
    } @catch (NSException *exception) {
    } @finally {
    }
    return NO;
}

/**
 * @brief Get data from last request
 */
+ (NSData *) lastData {
    return _lastData;
}

@end
