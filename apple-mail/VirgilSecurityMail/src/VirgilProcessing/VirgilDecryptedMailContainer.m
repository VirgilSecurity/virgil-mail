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

#import "VirgilDecryptedMailContainer.h"
#import "VirgilDecryptedMail.h"
#import "VirgilLog.h"
#import "Message.h"

@implementation VirgilDecryptedMailContainer

+(id)alloc{
    return [super alloc];
}

-(id)init{
    _mails = [[NSMutableDictionary alloc] init];
    return [super init];
}

- (void) clear {
    _mails = [[NSMutableDictionary alloc] init];
}

- (BOOL) isMailPresent : (id)email {
    return nil != [_mails valueForKey:[self emailHash:email]];
}

- (VirgilDecryptedMail *) createdEmail : (id)email {
    VirgilDecryptedMail * res = nil;
    @synchronized(self) {
        if (NO == [self isMailPresent:email]) {
            VirgilDecryptedMail * newMail = [[VirgilDecryptedMail alloc] init];
            newMail.decryptStatus = decryptUnknown;
            newMail.timeStamp = [self curTime];
            [_mails setValue:newMail forKey:[self emailHash:email]];
        }
        res = [_mails valueForKey:[self emailHash:email]];
    }
    return res;
}

- (NSTimeInterval) curTime {
    return [[NSDate date] timeIntervalSince1970];
}

- (void) setStatus:(DecryptStatus) status forEmail:(id)email {
    VirgilDecryptedMail * curMail = [self createdEmail:email];
    if (nil == curMail) return;
    curMail.decryptStatus = status;
    curMail.timeStamp = [self curTime];
    [self clearOldMails];
}

- (DecryptStatus) statusForEmail:(id)email {
    VirgilDecryptedMail * curMail = nil;
    @try {
        curMail = [_mails valueForKey:[self emailHash:email]];
    }
    @catch (NSException *exception) {}
    if (nil == curMail) return decryptUnknown;
    return curMail.decryptStatus;
}

- (void) clearOldMails {
    VLogInfo(@"");
    @synchronized(self) {
        NSMutableArray * delAr = [NSMutableArray new];
        for (NSString * mailKey in _mails.allKeys) {
            VirgilDecryptedMail * mail = [_mails valueForKey:mailKey];
            if (([self curTime] - mail.timeStamp) > 30.0) {
                [delAr addObject:mailKey];
            }
        }
        
        for (NSString * key in delAr) {
            [_mails removeObjectForKey:key];
        }
    }
}

- (NSString *) emailHash : (Message *)message {
    return [NSString stringWithFormat:@"%@_%@_%f", message.sender, message.subject, message.dateReceivedAsTimeIntervalSince1970];
}

- (void) addPart:(id)part partHash:(id)partHash forEmail:(id)email {
    VirgilDecryptedMail * curMail = [self createdEmail:email];
    if (nil != curMail) {
        [curMail addPart:part partHash:partHash];
    }
}

- (void) addAttachement:(id)attach attachHash:(id)attachHash forEmail:(id)email {
    VirgilDecryptedMail * curMail = [self createdEmail:email];
    if (nil != curMail) {
        [curMail addAttachement:attach attachHash:attachHash];
    }
}

- (id) partByHash:(id)partHash forEmail:(id)email {
    VirgilDecryptedMail *  needEmail = [_mails valueForKey:[self emailHash:email]];
    if (nil == needEmail) return nil;
    return [needEmail partByHash:partHash];
}

- (id) attachementByHash:(id)attachHash forEmail:(id)email {
    VirgilDecryptedMail *  needEmail = [_mails valueForKey:[self emailHash:email]];
    if (nil == needEmail) return nil;
    return [needEmail attachementByHash:attachHash];
}

@end
