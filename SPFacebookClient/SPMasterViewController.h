//
//  SPMasterViewController.h
//  SPFacebookClient
//
//  Created by Philip Dow on 5/7/12.
//  Copyright (c) 2012 Sprouted. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPDetailViewController;

@interface SPMasterViewController : UITableViewController

@property (strong, nonatomic) SPDetailViewController *detailViewController;

@end
