//
//  SPDetailViewController.h
//  SPFacebookClient
//
//  Created by Philip Dow on 5/7/12.
//  Copyright (c) 2012 Sprouted. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
