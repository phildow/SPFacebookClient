//
//  SPExampleFacebookClient.m
//  SPFacebookClient
//
//  Created by Philip Dow on 5/7/12.
//  Copyright (c) 2012 Sprouted. All rights reserved.
//

#import "SPExampleFacebookClient.h"

@implementation SPExampleFacebookClient

// override to provide your custom application identifier
+ (NSString*)applicationIdentifier
{
    
    // Your Facebook APP Id must be set before running this example
    // See http://www.facebook.com/developers/createapp.php
    // Also, your application must bind to the fb[app_id]:// URL
    // scheme (substitue [app_id] for your real Facebook app id).
        
    // We're using the Hackbook ID here
    
    static NSString * kApplicationId = @"210849718975311";
    return kApplicationId;
}

// override to provide a custom set of initial permissions
+ (NSArray*)permissions
{
    NSArray *permissions = [NSArray arrayWithObjects: @"offline_access", nil];
    return permissions;
}

@end
