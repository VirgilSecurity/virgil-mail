/**
 * Copyright (C) 2016 Virgil Security Inc.
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

#import "VirgilVersion.h"
#import "VirgilLog.h"

@implementation VirgilVersion

#define kElementsCount 4

NSString * rssURL = @"https://cdn.virgilsecurity.com/apps/virgil-mail/apple-mail/updates/virgilmailcast.xml";

NSXMLParser * rssParser = nil;
NSString * latestVersion = nil;
BOOL inAction = NO;

+ (VirgilVersion *) sharedInstance {
    static VirgilVersion * singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
        [singletonObject requestLatestVersion];
    });
    
    return singletonObject;
}

- (NSString *) currentVersion {
    NSDictionary * info = [[NSBundle bundleForClass : NSClassFromString(@"VirgilVersion")] infoDictionary];
    return [info objectForKey:@"CFBundleVersion"];
}

- (NSString *) cachedLatestVersion {
    return latestVersion;
}

- (NSArray *) splitVersion : (NSString *) version {
    if (version == nil || ![version containsString:@"."]) return nil;
    
    NSArray * splitStr = [version componentsSeparatedByString:@"."];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSMutableArray * resAr = [NSMutableArray new];
    if (splitStr.count == kElementsCount) {
        for (NSString * el in splitStr) {
            NSNumber *elNumber = [f numberFromString:el];
            if (elNumber == nil) return nil;
            [resAr addObject:elNumber];
        }
    }
    
    return [resAr copy];
}

- (BOOL) isNeedUpdate {
    if (latestVersion == nil) return NO;
    
    NSArray * curElements = [self splitVersion:[self currentVersion]];
    if (curElements == nil || curElements.count != kElementsCount) return NO;
    
    NSArray * latestElements = [self splitVersion:latestVersion];
    if (latestVersion == nil || latestElements.count != kElementsCount) return NO;
    
    for (NSInteger i = 0; i < kElementsCount; ++i) {
        if (latestElements[i] > curElements[i]) {
            return YES;
        }
    }
    
    return NO;
}

- (void) requestLatestVersion {
    if (inAction) return;
    inAction = YES;
    [self parseXMLFileAtURL:rssURL];
}

- (void) repeatRequestLatest {
    double delayInSeconds = 1800;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self requestLatestVersion];
    });
}

- (void) parseXMLFileAtURL:(NSString *)URL {
    NSURL *xmlURL = [NSURL URLWithString:URL];
    rssParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [rssParser setDelegate:self];
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
    [rssParser parse];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"error parsing XML: %@", [parseError localizedDescription]);
    inAction = NO;
    [self repeatRequestLatest];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSString * mailName = @"Virgil Security Mail ";
    if ([string containsString:mailName] &&
        [string containsString:@"."] &&
        ![string containsString:@"Changelog"]) {
        latestVersion = [string stringByReplacingOccurrencesOfString : mailName
                                                          withString : @""];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    inAction = NO;
    if (_delegate != nil) {
        [_delegate versionUpdated:latestVersion];
    }
    [self repeatRequestLatest];
    VLogInfo(@"Received latest version : '%@'", latestVersion ? latestVersion : @"nil");
}

@end
