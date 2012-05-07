//
//  FBRequest+SPBlocks.m
//  LikeMVP
//
//  Created by Philip Dow on 5/6/12.
//  Copyright (c) 2012 Philip Dow /Sprouted. All rights reserved.
//

/*
Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
   to endorse or promote products derived from this software without specific
   prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "FBRequest+SPBlocks.h"

@implementation FBRequest (SPBlocks)

static char completionHandlerKey;
static char originalDelegateKey;

@dynamic completionHandler;
@dynamic originalDelegate;

#pragma mark -

// category iVars through associative storage
// come'on -- objective-c is cool

- (FBRequestBlock)completionHandler
{
    return objc_getAssociatedObject(self, &completionHandlerKey);
}

- (void)setCompletionHandler:(FBRequestBlock)completionHandler
{
    objc_setAssociatedObject(self, &completionHandlerKey, completionHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id)originalDelegate
{
    return objc_getAssociatedObject(self, &originalDelegateKey);
}

- (void)setOriginalDelegate:(id)originalDelegate
{
    objc_setAssociatedObject(self, &originalDelegateKey, originalDelegate, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark -

// delegate callbacks pass on to the original delegate and also the
// block handler where specified

- (void)requestLoading:(FBRequest *)request
{
    id originalDelegate = self.originalDelegate;
    if ([originalDelegate respondsToSelector:@selector(requestLoading:)]) {
        [originalDelegate requestLoading:request];
    }
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    id originalDelegate = self.originalDelegate;
    if ([originalDelegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [originalDelegate request:request didReceiveResponse:response];
    }
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    id originalDelegate = self.originalDelegate;
    if ([originalDelegate respondsToSelector:@selector(request:didLoadRawResponse:)]) {
        [originalDelegate request:request didLoadRawResponse:data];
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    id originalDelegate = self.originalDelegate;
    if ([originalDelegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [originalDelegate request:request didFailWithError:error];
    }
    
    FBRequestBlock handler = self.completionHandler;
    if (handler) {
        handler(NO,nil,error);
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    id originalDelegate = self.originalDelegate;
    if ([originalDelegate respondsToSelector:@selector(request:didLoad:)]) {
        [originalDelegate request:request didLoad:result];
    }
    
    FBRequestBlock handler = self.completionHandler;
    if (handler) {
        handler(YES,result,nil);
    }
}

@end
