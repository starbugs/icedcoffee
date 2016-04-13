//
//  MasterViewController.h
//  IBIntegrationTest
//
//  Created by Tobias Lensing on 8/4/12.
//  Copyright (C) 2016 Tobias Lensing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
