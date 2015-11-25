//
//  SortViewController.h
//  TBCrashKit
//
//  Created by ChenHao on 11/25/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SortViewController;

@protocol SortViewControllerDelegate<NSObject>

- (void)sortViewController:(SortViewController *)sortViewController
             didSelectType:(NSString *)type;

- (void)sortViewControllerFilterAll:(SortViewController *)sortViewController;

@end

@interface SortViewController : UITableViewController

@property (nonatomic, weak)     id<SortViewControllerDelegate>  delegate;
@property (nonatomic, strong)   NSArray *sortArray;

@end
