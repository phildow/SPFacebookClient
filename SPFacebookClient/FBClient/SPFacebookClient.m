//
//  SPFacebookClient.m
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

#import "SPFacebookClient.h"

static NSString * SPFacebookClientValidationError = @"SPFacebookClientValidationError";

static NSString * SPFacebookClientError = @"SPFacebookClientError";
static NSInteger SPFacebookClientLoginFailed = 1;
static NSInteger SPFacebookClientLoginCancelled = 2;

@interface SPFacebookClient()

@property (nonatomic,readwrite,copy) FBRequestBlock sessionHandler;
@property (nonatomic,readwrite,retain) NSArray *permissions;

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt;
- (void)removeAuthData;

- (void)validateApplicationSettings;

@end

#pragma mark -

@implementation SPFacebookClient

@synthesize facebook = _facebook;
@synthesize sessionHandler = _sessionHandler;
@synthesize permissions = _permissions;

#pragma mark -

+ (SPFacebookClient *)sharedClient {
    static SPFacebookClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
    });
    
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // ensure application url handling is set up correctly
    [self validateApplicationSettings];
    
    // facebook permissions
    _permissions = [[[self class] permissions] retain];
    
    // initialize the facebook object
    _facebook = [[Facebook alloc] initWithAppId:[[self class] applicationIdentifier] andDelegate:self];
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    return self;
}

- (void)dealloc
{
    [_facebook release];
    [_permissions release];
    [_sessionHandler release];
    [super dealloc];
}

#pragma mark -

// override to provide your custom application identifier
+ (NSString*)applicationIdentifier
{
    return nil;
}

// override to provide a custom set of initial permissions
+ (NSArray*)permissions
{
    NSArray *permissions = [NSArray arrayWithObjects: @"offline_access", nil];
    return permissions;
}

#pragma mark -
#pragma mark Graph API Proxy

- (FBRequest*)requestWithPath:(NSString *)graphPath params:(NSMutableDictionary *)params method:(NSString *)httpMethod delegate:(id)delegate completionHandler:(FBRequestBlock)handler
{
    if (!params) params = [NSMutableDictionary dictionary];
    FBRequest *request = [self.facebook requestWithGraphPath:graphPath andParams:params andHttpMethod:httpMethod andDelegate:nil];
    
    request.completionHandler = handler;
    request.originalDelegate = delegate;
    request.delegate = request;
    
    return request;
}

- (FBRequest*)requestWithPath:(NSString *)graphPath params:(NSMutableDictionary *)params delegate:(id)delegate completionHandler:(FBRequestBlock)handler
{
    return [self requestWithPath:graphPath params:params method:@"GET" delegate:delegate completionHandler:handler];
}

- (FBRequest*)requestWithPath:(NSString *)graphPath delegate:(id)delegate completionHandler:(FBRequestBlock)handler
{
    return [self requestWithPath:graphPath params:nil method:@"GET" delegate:delegate completionHandler:handler];
}

- (FBRequest*)requestWithPath:(NSString *)graphPath completionHandler:(FBRequestBlock)handler
{
    return [self requestWithPath:graphPath params:nil method:@"GET" delegate:nil completionHandler:handler];
}

#pragma mark -
#pragma mark FQL Query Proxy

- (FBRequest*)requestWithQuery:(NSString*)query delegate:(id)delegate completionHandler:(FBRequestBlock)handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:query, @"q",nil];
    return [self requestWithPath:@"fql" params:params delegate:delegate completionHandler:handler];
}

- (FBRequest*)requestWithQuery:(NSString*)query completionHandler:(FBRequestBlock)handler
{
    return [self requestWithQuery:query delegate:nil completionHandler:handler];
}

#pragma mark -
#pragma mark Deprecated REST API Proxy

- (FBRequest*)requestWithName:(NSString *)methodName params:(NSMutableDictionary *)params method:(NSString *)httpMethod delegate:(id <FBRequestDelegate>)delegate completionHandler:(FBRequestBlock)handler
{
    if (!params) params = [NSMutableDictionary dictionary]; // who the hell wrote this api?
    FBRequest *request = [self.facebook requestWithMethodName:methodName andParams:params andHttpMethod:httpMethod andDelegate:delegate];
    
    request.completionHandler = handler;
    request.originalDelegate = delegate;
    request.delegate = request;
    
    return request;
}

- (FBRequest*)requestWithName:(NSString *)methodName params:(NSMutableDictionary *)params method:(NSString *)httpMethod completionHandler:(FBRequestBlock)handler
{
    return [self requestWithName:methodName params:params method:methodName delegate:nil completionHandler:handler];
}

- (FBRequest*)requestWithParams:(NSMutableDictionary *)params delegate:(id <FBRequestDelegate>)delegate completionHandler:(FBRequestBlock)handler
{
    if (!params) params = [NSMutableDictionary dictionary];
    FBRequest *request = [self.facebook requestWithParams:params andDelegate:delegate];
    
    request.completionHandler = handler;
    request.originalDelegate = delegate;
    request.delegate = request;
    
    return request;
}

- (FBRequest*)requestWithParams:(NSMutableDictionary *)params completionHandler:(FBRequestBlock)handler
{
    return [self requestWithParams:params delegate:nil completionHandler:handler];
}

#pragma mark -
#pragma mark Session Management

- (void) login:(FBRequestBlock)completionHandler
{
    if (![self.facebook isSessionValid]) {
        self.sessionHandler = completionHandler;
        [self.facebook authorize:self.permissions];
    } 
    else {
        completionHandler(YES,nil,nil);
    }
}

- (void) logout:(FBRequestBlock)completionHandler
{
    self.sessionHandler = completionHandler;
    [self.facebook logout];
}

#pragma mark -
#pragma mark FBSession Callbacks

- (void)fbDidLogin
{
    [self storeAuthData:[self.facebook accessToken] expiresAt:[self.facebook expirationDate]];
    FBRequestBlock completionHandler = self.sessionHandler;
    if (completionHandler) {
        completionHandler(YES,nil,nil);
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    FBRequestBlock completionHandler = self.sessionHandler;
    if (completionHandler) {
        NSInteger code = (cancelled?SPFacebookClientLoginCancelled:SPFacebookClientLoginFailed);
        NSError *error = [NSError errorWithDomain:SPFacebookClientError code:code userInfo:nil];
        completionHandler(NO,nil,error);
    }
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt
{
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

- (void)fbDidLogout
{
    FBRequestBlock completionHandler = self.sessionHandler;
    if (completionHandler) {
        completionHandler(YES,nil,nil);
    }
}

- (void)fbSessionInvalidated
{
    NSLog(@"fbSessionInvalidated");
}

#pragma mark -

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt 
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)removeAuthData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

#pragma mark -
#pragma mark Utilities

- (void)validateApplicationSettings
{
    // Check App ID:
    // This is really a warning for the developer, this should not
    // happen in a completed app
    if (![[self class] applicationIdentifier]) {
        [NSException raise:SPFacebookClientValidationError format:@"Missing app ID. You cannot run the app until you provide this in the code."];
    } 
    else {
        // Now check that the URL scheme fb[app_id]://authorize is in the .plist and can
        // be opened, doing a simple check without local app id factored in here
        NSString *url = [NSString stringWithFormat:@"fb%@://authorize",[[self class] applicationIdentifier]];
        BOOL bSchemeInPlist = NO; // find out if the sceme is in the plist file.
        NSArray* aBundleURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
        
        if ([aBundleURLTypes isKindOfClass:[NSArray class]] && ([aBundleURLTypes count] > 0)) {
            NSDictionary* aBundleURLTypes0 = [aBundleURLTypes objectAtIndex:0];
            if ([aBundleURLTypes0 isKindOfClass:[NSDictionary class]]) {
                NSArray* aBundleURLSchemes = [aBundleURLTypes0 objectForKey:@"CFBundleURLSchemes"];
                if ([aBundleURLSchemes isKindOfClass:[NSArray class]] && ([aBundleURLSchemes count] > 0)) {
                    NSString *scheme = [aBundleURLSchemes objectAtIndex:0];
                    if ([scheme isKindOfClass:[NSString class]] &&
                        [url hasPrefix:scheme]) {
                        bSchemeInPlist = YES;
                    }
                }
            }
        }
        
        // Check if the authorization callback will work
        BOOL bCanOpenUrl = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: url]];
        if (!bSchemeInPlist || !bCanOpenUrl) {
            [NSException raise:SPFacebookClientValidationError format:@"Invalid or missing URL scheme. You cannot run the app until you set up a valid URL scheme in your .plist."];
        }
    }
}

@end
