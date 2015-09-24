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
#import <Foundation/Foundation.h>


//----------------------------------------------------------------------
// Interface
//----------------------------------------------------------------------
@interface HTMLConverter : NSObject

/**
 * Convert some characters into entity references.
 * The default value is YES.
 *
 * To be concrete, &, <, >, " and ' are converted into
 * &amp;amp; &amp;lt;, &amp;gt;, &amp;quot; and &amp;apos;,
 * respectively.
 */
@property (nonatomic, assign) BOOL entityReferenceFlag;


/**
 * Convert newlines into 'br' tag.
 * The default value is YES.
 *
 * "\n", "\r\n" and "\r" are converted into <br/>.
 */
@property (nonatomic, assign) BOOL newLineFlag;


/**
 * Convert HTTP(S) URLs into 'a' tag.
 * The default value is YES.
 */
@property (nonatomic, assign) BOOL hyperLinkFlag;


/**
 * Cut scheme parts ('http://' and 'https://') from
 * displayed texts of 'a' tag.
 * The default value is NO.
 *
 * For example, if this flag is YES, http://example.com
 * is converted into:
 * @code
 * <a href='http://example.com'>example.com</a>
 * @endcode
 */
@property (nonatomic, assign) BOOL cutSchemeFlag;


/**
 * Convert Twitter hashes and mentions into 'a' tag.
 * The default value is NO.
 *
 * If this flag is YES, '#hash' is converted into:
 * @code
 * <a href='https://twitter.com/search?q=%23hash'>#hash</a>
 * @endcode
 *
 * And '@mention' is converted into:
 * @code
 * <a href='https://twitter.com/mention'>@mention</a>
 * @endcode
 */
@property (nonatomic, assign) BOOL twitterFlag;


/**
 * Embed "data-link-type='twitter-hash'" and
 * "data-link-type='twitter-name'" attribute tags
 * into 'a' tags.
 * The default value is NO.
 */
@property (nonatomic, assign) BOOL customAttributeForTwitterLinkFlag;


/**
 * Convert the given plain text into an HTML text.
 */
- (NSString *)toHTML:(NSString *)text;


@end
