/*
 * Copyright (C) 2013 Neo Visionaries Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


//----------------------------------------------------------------------
// Headers
//----------------------------------------------------------------------
#import "HTMLConverter.h"


//----------------------------------------------------------------------
// Macros
//----------------------------------------------------------------------
#define UNICHAR_FULL_WIDTH_NUMBER_SIGN      0xFF03
#define UNICHAR_FULL_WIDTH_COMMERCIAL_AT    0xFF20


//----------------------------------------------------------------------
// Static Variables
//----------------------------------------------------------------------
static char _plainChars[] = "&<>\"'";
static NSArray *_entityReferences;


//----------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------
@implementation HTMLConverter
{
    BOOL _entityReferenceFlag;
    BOOL _newLineFlag;
    BOOL _hyperLinkFlag;
    BOOL _cutSchemeFlag;
    BOOL _twitterFlag;
    BOOL _customAttributeForTwitterLinkFlag;
}


@synthesize entityReferenceFlag = _entityReferenceFlag;
@synthesize newLineFlag         = _newLineFlag;
@synthesize hyperLinkFlag       = _hyperLinkFlag;
@synthesize cutSchemeFlag       = _cutSchemeFlag;
@synthesize twitterFlag         = _twitterFlag;
@synthesize customAttributeForTwitterLinkFlag = _customAttributeForTwitterLinkFlag;


+ (void)initialize
{
    @synchronized (self)
    {
        if (_entityReferences != nil)
        {
            return;
        }

        _entityReferences = [[NSArray alloc] initWithObjects:
         @"&amp;", @"&lt;", @"&gt;", @"&quot;", @"&apos;", nil];
    }
}


- (id)init
{
    self = [super init];

    if (self == nil)
    {
        return nil;
    }

    _entityReferenceFlag = YES;
    _newLineFlag         = YES;
    _hyperLinkFlag       = YES;
    _cutSchemeFlag       = NO;
    _twitterFlag         = NO;
    _customAttributeForTwitterLinkFlag = NO;

    return self;
}


- (NSString *)toHTML:(NSString *)text
{
    if (text == nil)
    {
        return nil;
    }

    NSMutableString *html = [[NSMutableString alloc] init];

    // Number of characters.
    int len = [text length];

    for (int i = 0; i < len; ++i)
    {
        unichar ch = [text characterAtIndex:i];
        BOOL twitterHash = NO;
        BOOL twitterMention = NO;

        if ([self tryEntityReference:html character:ch])
        {
            continue;
        }

        switch (ch)
        {
            case '\n':
                [self appendEscapeN:html];
                continue;

            case '\r':
                [self appendEscapeR:html text:text index:&i];
                continue;

            case ' ':
                [self appendSpace:html text:text index:&i];
                continue;

            case '#':
            case UNICHAR_FULL_WIDTH_NUMBER_SIGN:
                if ((twitterHash = [self appendNumberSign:html character:ch]))
                {
                    break;
                }
                continue;

            case '@':
            case UNICHAR_FULL_WIDTH_COMMERCIAL_AT:
                if ((twitterMention = [self appendCommercialAt:html character:ch]))
                {
                    break;
                }
                continue;

            case 'h':
                if (_hyperLinkFlag)
                {
                    // This may be the first letter of a URL.
                    break;
                }
                else
                {
                    [html appendFormat:@"%c", ch];
                    continue;
                }

            default:
                [html appendFormat:@"%C", ch];
                continue;
        }

        // For possible URL candidates. '#', '@' or 'h' has alrady been read,
        // but it has not been added to the NSMutableString yet.
        NSMutableString *link = nil;

        if ([self string:text from:i hasPrefix:@"http://"])
        {
            link = [[NSMutableString alloc] initWithString:@"http://"];
            i += 7;
        }
        else if ([self string:text from:i hasPrefix:@"https://"])
        {
            link = [[NSMutableString alloc] initWithString:@"https://"];
            i += 8;
        }
        else if (twitterHash && (i+1 < len) && [self isValidForTwitterHash:text at:(i+1)] &&
                 (i == 0 || [self isTwitterOpeningHashDelimiter:text at:(i-1)]))
        {
            link = [[NSMutableString alloc] init];
            ++i;
        }
        else if (twitterMention && (i+1 < len) && [self isValidForTwitterUserName:text at:(i+1)] &&
                 (i == 0 || [self isTwitterOpeningUserNameDelimiter:text at:(i-1)]))
        {
            link = [[NSMutableString alloc] init];
            ++i;
        }
        else
        {
            // It's not the first letter of a URL.
            [html appendFormat:@"%C", ch];
            continue;
        }

        // Not change the value of 'ch' after this.

        // Until the end of the URL.
        for (; i < len; ++i)
        {
            unichar c = [text characterAtIndex:i];

            // If TwitterHash.
            if (twitterHash)
            {
                if ([self isValidForTwitterHash:c] == NO)
                {
                    // The end of the twitter hash.
                    break;
                }
            }
            // If TwitterMention.
            else if (twitterMention)
            {
                if ([self isValidForTwitterUserName:c] == NO)
                {
                    // The end of the twitter user name.
                    break;
                }
            }
            // URL
            else
            {
                if ([self isValidForUrl:c] == NO)
                {
                    // The end of the URL.
                    break;
                }
            }

            [link appendFormat:@"%C", c];
        }

        --i;

        NSString *href;
        NSString *displayedText;

        if (twitterHash)
        {
            NSString *encodedUrl = [self encodeUrl:link];
            displayedText = [NSString stringWithFormat:@"#%@", link];
            href = [NSString stringWithFormat:@"https://twitter.com/search?q=%%23%@", encodedUrl];
        }
        else if (twitterMention)
        {
            displayedText = [NSString stringWithFormat:@"@%@", link];
            href = [NSString stringWithFormat:@"https://twitter.com/%@", link];
        }
        else
        {
            href = link;
            displayedText = [self decodeUrl:link];

            if (_cutSchemeFlag)
            {
                displayedText = [self cutScheme:displayedText];
            }
        }

        [html appendFormat:@"<a href='%@'", href];

        if (_customAttributeForTwitterLinkFlag)
        {
            if (twitterHash)
            {
                [html appendString:@" data-link-type='twitter-hash'"];
            }
            else if (twitterMention)
            {
                [html appendString:@" data-link-type='twitter-mention'"];
            }
        }

        [html appendFormat:@">%@</a>", displayedText];
    }

    return html;
}


- (BOOL)tryEntityReference:(NSMutableString *)html character:(unichar)ch
{
    for (int i = 0; i < sizeof(_plainChars) - 1; ++i)
    {
        if (ch != _plainChars[i])
        {
            continue;
        }

        if (_entityReferenceFlag)
        {
            [html appendString:[_entityReferences objectAtIndex:i]];
        }
        else
        {
            [html appendFormat:@"%c", _plainChars[i]];
        }

        return YES;
    }

    return NO;
}


- (void)appendEscapeN:(NSMutableString *)html
{
    if (_newLineFlag)
    {
        [html appendString:@"<br/>"];
    }
    else
    {
        [html appendFormat:@"%c", '\n'];
    }
}


- (void)appendEscapeR:(NSMutableString *)html text:(NSString *)text index:(int *)index
{
    if (_newLineFlag)
    {
        if (*index + 1 < [text length] && [text characterAtIndex:(*index + 1)] == '\n')
        {
            // Consume '\n'.
            *index = *index + 1;
        }

        [html appendString:@"<br/>"];
    }
    else
    {
        [html appendFormat:@"%c", '\r'];
    }
}


- (void)appendSpace:(NSMutableString *)html text:(NSString *)text index:(int *)index
{
    [html appendFormat:@"%c", ' '];

    if (_entityReferenceFlag == NO)
    {
        return;
    }

    if (*index + 1 < [text length] && [text characterAtIndex:(*index + 1)] == ' ')
    {
        // Replace the following space with '&nbsp;' to prevent
        // continuous spaces from being merged into one space.
        [html appendString:@"&nbsp;"];
        *index = *index + 1;
    }
}


- (BOOL)appendNumberSign:(NSMutableString *)html character:(unichar)ch
{
    if (_twitterFlag)
    {
        return YES;
    }
    else
    {
        [html appendFormat:@"%C", ch];
        return NO;
    }
}


- (BOOL)appendCommercialAt:(NSMutableString *)html character:(unichar)ch
{
    if (_twitterFlag)
    {
        return YES;
    }
    else
    {
        [html appendFormat:@"%C", ch];
        return NO;
    }
}


- (BOOL)string:(NSString *)string from:(int)index hasPrefix:(NSString *)prefix
{
    int stringLen = [string length];
    int prefixLen = [prefix length];

    if ((stringLen - index) < prefixLen)
    {
        return NO;
    }

    NSRange range = NSMakeRange(index, prefixLen);

    NSComparisonResult result = [string compare:prefix options:0 range:range];

    if (result == NSOrderedSame)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isValidForTwitterHash:(NSString *)text at:(int)index
{
    unichar ch = [text characterAtIndex:index];

    return [self isValidForTwitterHash:ch];
}


- (BOOL)isValidForTwitterHash:(unichar)ch
{

    // Special case.
    if (ch == '_')
    {
        return YES;
    }
    
    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:ch])
    {
        return NO;
    }

    if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:ch])
    {
        return NO;
    }

    if ([[NSCharacterSet symbolCharacterSet] characterIsMember:ch])
    {
        return NO;
    }

    return YES;
}


- (BOOL)isTwitterOpeningHashDelimiter:(NSString *)text at:(int)index
{
    return [self isTwitterOpeningDelimiter:text at:index];
}


- (BOOL)isTwitterOpeningUserNameDelimiter:(NSString *)text at:(int)index
{
    return [self isTwitterOpeningDelimiter:text at:index];
}


- (BOOL)isTwitterOpeningDelimiter:(NSString *)text at:(int)index
{
    unichar ch = [text characterAtIndex:index];

    return [self isTwitterOpeningDelimiter:ch];
}


- (BOOL)isTwitterOpeningDelimiter:(unichar)ch
{
    // Special cases.
    switch (ch)
    {
        case '?':
        case '!':
        case ',':
        case '.':
            return YES;
    }

    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:ch])
    {
        return YES;
    }

    if (ch <= 0x7F)
    {
        return NO;
    }

    if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:ch])
    {
        return YES;
    }

    return NO;
}


- (BOOL)isValidForTwitterUserName:(NSString *)text at:(int)index
{
    unichar ch = [text characterAtIndex:index];

    return [self isValidForTwitterUserName:ch];
}


- (BOOL)isValidForTwitterUserName:(unichar)ch
{
    if (('0' <= ch && ch <= '9') ||
        ('a' <= ch && ch <= 'z') ||
        ('A' <= ch && ch <= 'Z') ||
        (ch == '_'))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)isValidForUrl:(unichar)ch
{
    if (0x21 <= ch && ch <= 0x7E)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (NSString *)encodeUrl:(NSString *)plainUrl
{
    CFStringRef ref = CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault, (__bridge CFStringRef)(plainUrl), NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);

    return CFBridgingRelease(ref);
}


- (NSString *)decodeUrl:(NSString *)encodedUrl
{
    CFStringRef ref = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
        kCFAllocatorDefault, (__bridge CFStringRef)(encodedUrl), CFSTR(""), kCFStringEncodingUTF8);

    return CFBridgingRelease(ref);
}


- (NSString *)cutScheme:(NSString *)url
{
    if (url == nil)
    {
        return nil;
    }

    if ([url hasPrefix:@"http://"])
    {
        return [url substringFromIndex:7];
    }
    else if ([url hasPrefix:@"https://"])
    {
        return [url substringFromIndex:8];
    }
    else
    {
        return url;
    }
}


@end
