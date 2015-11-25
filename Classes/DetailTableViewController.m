//
//  DetailTableViewController.m
//  TBCrashKit
//
//  Created by ChenHao on 11/24/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import "DetailTableViewController.h"

@interface DetailTableViewController ()

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonIdentifer"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommonIdentifer"];
    }
    
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = [NSString stringWithFormat:@"APP Name:%@",self.model.bundleName];
        }
            break;
        case 1: {
            cell.textLabel.text = [NSString stringWithFormat:@"bundleVersion:%@",self.model.bundleVersion];
        }
            break;
        case 2: {
            cell.textLabel.text = self.model.exceptionName;
        }
            break;
        case 3: {
            [self configAutoLayoutCell:cell text:self.model.exceptionReason textColor:[UIColor redColor]];
        }
            break;
        case 4: {
            [self configAutoLayoutCell:cell text:self.model.stackTree textColor:[UIColor blackColor]];
        }
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)configAutoLayoutCell:(UITableViewCell *)cell
                        text:(NSString *)text
                   textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = textColor;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:14];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:label];
    [cell.contentView addConstraints:@[
                                       [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:5],
                                       [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-5],
                                       [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:15],
                                       [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-15],
                                       
                                       ]];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
