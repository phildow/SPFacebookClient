# SPFacebookClient

## Overview

SPFacebookClient is a singleton wrapper around the FBConnect classes. It offers a single point of access to the Facebook iOS API. It also adds support for calls to the FBRequest API using block callbacks.

The additions bootstrap Facebook App development for 3rd party developers on iOS.

The code is based on sample code from the Facebook iOS SDK:
<https://github.com/facebook/facebook-ios-sdk>

## Setup

Subclass the SPFacebookClient class and override the class methods +applicationIdentifier and +permissions:

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

Don't forget to add a custom URL handler per the API's requirements.

##Usage

Make calls to your shared custom subclass directly, including Graph API calls as well as FQL queries.

####Session Management
	[[SPExampleFacebookClient sharedClient] login:^(BOOL success, id result, NSError *error) {
        NSLog(@"%i,%@,%@",success,result,error);
    }];

####Graph API: Friends
	[[SPExampleFacebookClient sharedClient] requestWithPath:@"me/friends" completionHandler:^(BOOL success, id result, NSError *error) {
		NSLog(@"%i,%@,%@",success,result,error);
	}

####FQL Query: My Info
	[[SPExampleFacebookClient sharedClient] requestWithQuery:@"SELECT uid, name, pic FROM user WHERE uid=me()" completionHandler:^(BOOL success, id result, NSError *error) {
	        NSLog(@"%i,%@,%@",success,result,error);
	    }];

##Platform    
I've tested SPFacebookClient on iOS 5.1. The code does not use ARC, so if you're running an ARC project make sure you set the -fno-objc-arc compiler flag on the files.