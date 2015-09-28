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

#import "VirgilLog.h"

@implementation VirgilLog

+ (VirgilLog *) sharedInstance {
    static VirgilLog * singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[VirgilLog alloc] init];
    });
    
    return singletonObject;
}

- (id) init {
    if ([super init]) {
        [VirgilLog moveOldLog];
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath : [VirgilLog logFileFullPath]];
        [self writeToLogFile:(@"------------------------------- START -----------------------------")];
    }
    return self;
}

- (NSInteger) currentThreadNumber {
    NSString    *threadString;
    NSRange      numRange;
    NSUInteger   numLength;
    threadString = [NSString stringWithFormat:@"%@", [NSThread currentThread]];
    numRange = [threadString rangeOfString:@"number = "];
    numLength = [threadString length] - numRange.location - numRange.length;
    numRange.location = numRange.location + numRange.length;
    numRange.length   = numLength - 1;
    
    threadString = [threadString substringWithRange:numRange];
    return [threadString integerValue];
}

- (void) myLog : (NSString * ) type
          file : (char *) file
    lineNumber : (int) lineNumber
        format : (NSString *) format, ... {

    va_list      listOfArguments;
    NSString    *formattedString;
    NSString    *sourceFile;
    NSString    *logString;
    
    va_start(listOfArguments, format);
    formattedString = [[NSString alloc] initWithFormat:format
                                             arguments:listOfArguments];
    va_end(listOfArguments);
    
    sourceFile = [[NSString alloc] initWithBytes:file
                                          length:strlen(file)
                                        encoding:NSUTF8StringEncoding];
    
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    
    logString = [NSString stringWithFormat:@"[%@] %f Thread <%li:%@> | %s:%d %@",
                 type,
                 timeInMiliseconds,
                 (long)[self currentThreadNumber],
                 [[NSThread currentThread] name],
                 [[sourceFile lastPathComponent] UTF8String],
                 lineNumber,
                 formattedString];

    
    NSLog(@"%@", logString);
    [self writeToLogFile : logString];
}

+ (NSString *) logFileFullPath {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * cacheDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    return [NSString stringWithFormat : @"%@/virgilsecurity.log", cacheDirectory];
}

+ (void) moveOldLog {
    NSString * oldPath = [VirgilLog logFileFullPath];
    NSString * newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent : @"prev_virgilsecurity.log"];
    [[NSFileManager defaultManager] removeItemAtPath:newPath error:nil];
    [[NSFileManager defaultManager] moveItemAtPath : oldPath
                                            toPath : newPath
                                             error : nil];
    [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
    [[NSFileManager defaultManager] createFileAtPath:oldPath contents:nil attributes:nil];
}

- (void) writeToLogFile : (NSString *) string {
        NSString * logStr = [string stringByAppendingString : @"\n"];
        @synchronized(_fileHandle) {
            [_fileHandle seekToEndOfFile];
            [_fileHandle writeData:[logStr dataUsingEncoding:NSUTF8StringEncoding]];
        }
}

- (void) dealloc {
    if (nil != _fileHandle) {
        @synchronized(_fileHandle) {
            [_fileHandle closeFile];
        }
    }
}

@end
