//
//  SPFacebookClient.h
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

#import <Foundation/Foundation.h>
#import "FBRequest+SPBlocks.h"
#import "Facebook.h"

@interface SPFacebookClient : NSObject <FBSessionDelegate>

@property (nonatomic,readonly,retain) Facebook *facebook;

+ (SPFacebookClient *)sharedClient;

#pragma mark -

// override to provide your custom application identifier
+ (NSString*)applicationIdentifier;

// override to provide a custom set of initial permissions
+ (NSArray*)permissions;

#pragma mark -

// session management

- (void)login:(FBRequestBlock)completionHandler;
- (void)logout:(FBRequestBlock)completionHandler;

#pragma mark -
#pragma mark Graph API

// facebook requests with support for completion handlers
// make requests through the client object rather than the facebook object

// use these methods to access the facebook graph

- (FBRequest*)requestWithPath:(NSString *)graphPath params:(NSMutableDictionary *)params
    method:(NSString *)httpMethod delegate:(id)delegate completionHandler:(FBRequestBlock)handler;

- (FBRequest*)requestWithPath:(NSString *)graphPath params:(NSMutableDictionary *)params delegate:(id)delegate completionHandler:(FBRequestBlock)handler;

- (FBRequest*)requestWithPath:(NSString *)graphPath delegate:(id)delegate completionHandler:(FBRequestBlock)handler;

- (FBRequest*)requestWithPath:(NSString *)graphPath completionHandler:(FBRequestBlock)handler;

#pragma mark -
#pragma mark FQL Query

// convenience methods for executing an FQL query

- (FBRequest*)requestWithQuery:(NSString*)query delegate:(id)delegate completionHandler:(FBRequestBlock)handler;

- (FBRequest*)requestWithQuery:(NSString*)query completionHandler:(FBRequestBlock)handler;

#pragma mark -
#pragma mark Deprecated REST API

// i believe these named methods use the deprecated "REST" apis. avoid them

- (FBRequest*)requestWithName:(NSString *)methodName params:(NSMutableDictionary *)params method:(NSString *)httpMethod delegate:(id <FBRequestDelegate>)delegate completionHandler:(FBRequestBlock)handler;

- (FBRequest*)requestWithName:(NSString *)methodName params:(NSMutableDictionary *)params method:(NSString *)httpMethod completionHandler:(FBRequestBlock)handler;

- (FBRequest*)requestWithParams:(NSMutableDictionary *)params delegate:(id <FBRequestDelegate>)delegate completionHandler:(FBRequestBlock)handler;

- (FBRequest*)requestWithParams:(NSMutableDictionary *)params completionHandler:(FBRequestBlock)handler;

@end
