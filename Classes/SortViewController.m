//
//  SortViewController.m
//  TBCrashKit
//
//  Created by ChenHao on 11/25/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import "SortViewController.h"

@interface SortViewController ()

@end

@implementation SortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"异常类别";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"全部" style:UIBarButtonItemStyleDone target:self action:@selector(filterAllButton)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)filterAllButton {
    if (_delegate && [self.delegate respondsToSelector:@selector(sortViewControllerFilterAll:)]) {
        [_delegate sortViewControllerFilterAll:self];
        [self dismissViewControllerAnimated:self completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.sortArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SortCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SortCell"];
    }
    cell.textLabel.text = self.sortArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate && [self.delegate respondsToSelector:@selector(sortViewController:didSelectType:)]) {
        [_delegate sortViewController:self didSelectType: self.sortArray[indexPath.row]];
        [self dismissViewControllerAnimated:self completion:nil];
    }
}

@end
