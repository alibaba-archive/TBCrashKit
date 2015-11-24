//
//  DetailTableViewController.h
//  TBCrashKit
//
//  Created by ChenHao on 11/24/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrashModel.h"

@interface DetailTableViewController : UITableViewController

@property (nonatomic, strong) CrashModel *model;

@end
