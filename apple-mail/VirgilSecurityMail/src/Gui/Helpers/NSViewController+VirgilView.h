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
#import <Cocoa/Cocoa.h>

/**
 * @category Category to extend NSViewController for add ViewControllers change, error show and etc.
 */

@interface NSViewController (VirgilView)

/**
 * @brief Replace current view by newViewName using VirgilReplaceAnimator
 * @param newViewName - view name to show
 * @return YES - success | NO - can't show need view
 */
- (BOOL) changeView : (NSString *) newViewName;

/**
 * @brief Show error message in sheet view
 * @param errorText - text to show
 * @return YES - success | NO - can't show need view
 */
- (BOOL) showErrorView : (NSString *) errorText;

/**
 * @brief Show error message in popover view at right edge of neew view element
 * @param errorText - text to show
 * @param atView - NSView instance near which popover will be shown
 * @return YES - success | NO - can't show need view
 */
- (BOOL) showCompactErrorView : (NSString *) errorText
                       atView : (NSView *) atView;

/**
 * @brief Close window (not view only) and send return code
 */
- (void) closeWindow;

- (void) preventUserActivity : (BOOL) prevent;
- (void) externalActionDone;
- (void) setProgressVisible : (BOOL) visible;

@end