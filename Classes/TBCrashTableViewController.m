//
//  TBCrashTableViewController.m
//  TBCrashKit
//
//  Created by ChenHao on 11/24/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import "TBCrashTableViewController.h"
#import "SqlService.h"
#import "DetailTableViewController.h"

@interface TBCrashTableViewController ()

@property (nonatomic, strong)   NSArray *dataSource;

@end

@implementation TBCrashTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[[SqlService alloc] init] getCreashModels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CrashCellIdentifer"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CrashCellIdentifer"];
    }
    CrashModel *model = self.dataSource[indexPath.row];
    cell.textLabel.text = model.exceptionName;
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailTableViewController *detailViewController = [[DetailTableViewController alloc] init];
    detailViewController.model = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [[[SqlService alloc] init] deleteCreashModel:self.dataSource[indexPath.row]];
    }];
    return @[action];
}

@end
