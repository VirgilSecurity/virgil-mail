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

#import "VirgilImageProcessing.h"

#define MAX3(a, b, c) ( MAX((a), MAX((b), (c))) )

@implementation VirgilImageProcessing

+ (NSImage *) imageWithStatusPicture : (NSImage *) userImage
                     statusImageName : (NSString *) statusImageName
                            minWidth : (NSUInteger) minWidth
                           minHeight : (NSUInteger) minHeight {
    if (nil == userImage) return nil;
    NSImage * statusImage = [NSImage imageNamed : statusImageName];
    if (nil == statusImage) return userImage;
    
    NSInteger w = MAX3(statusImage.size.width, userImage.size.width, minWidth);
    NSInteger h = MAX3(statusImage.size.height, userImage.size.height, minHeight);
    
    NSImage * resImage = [[NSImage alloc] initWithSize : NSMakeSize(w, h)];
    
    [resImage lockFocus];
    
    [userImage drawAtPoint : NSMakePoint(0, 0)
                  fromRect : NSZeroRect
                 operation : NSCompositeSourceOver
                  fraction : 1.0];
    
    NSInteger dx = w - statusImage.size.width;
    
    [statusImage drawAtPoint : NSMakePoint(dx, 0)
                    fromRect : NSZeroRect
                   operation : NSCompositeSourceOver
                    fraction : 1.0];
    
    [resImage unlockFocus];
    
    return resImage;
}

+ (NSImage *)resize : (NSImage *) anImage
            newSize : (NSSize) newSize {
    NSImage *sourceImage = anImage;
    [sourceImage setScalesWhenResized:YES];
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid]){
        NSLog(@"Invalid Image");
    } else {
        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositeCopy fraction:1.0];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}

@end
