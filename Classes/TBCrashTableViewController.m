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
#import "SortViewController.h"

@interface TBCrashTableViewController ()<SortViewControllerDelegate>

@property (nonatomic, strong)   NSArray *dataSource;
@property (nonatomic, strong)   NSArray *filterDataSource;
@property (nonatomic, strong)   NSArray *sortArray;

@end

@implementation TBCrashTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"崩溃列表";
    self.dataSource = [[[SqlService alloc] init] getCreashModels];
    self.filterDataSource = self.dataSource;
    NSMutableSet *set = [NSMutableSet new];
    [self.dataSource enumerateObjectsUsingBlock:^(CrashModel  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [set addObject:obj.exceptionName];
    }];
    
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    self.sortArray = [[set copy] sortedArrayUsingDescriptors:sortDesc];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:UIBarButtonItemStyleDone target:self action:@selector(sortButtonTouch)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)sortButtonTouch {
    SortViewController *sortViewController = [[SortViewController alloc] init];
    sortViewController.sortArray = self.sortArray;
    sortViewController.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:sortViewController] animated:YES completion:nil];
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
    return self.filterDataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CrashCellIdentifer"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CrashCellIdentifer"];
    }
    CrashModel *model = self.filterDataSource[indexPath.row];
    cell.textLabel.text = model.exceptionName;
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailTableViewController *detailViewController = [[DetailTableViewController alloc] init];
    detailViewController.model = self.filterDataSource[indexPath.row];
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

#pragma mark - SortViewController Delegate

- (void)sortViewController:(SortViewController *)sortViewController
             didSelectType:(NSString *)type {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exceptionName == %@" argumentArray:@[type]];
    self.filterDataSource = [self.dataSource filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

- (void)sortViewControllerFilterAll:(SortViewController *)sortViewController {
    self.filterDataSource = self.dataSource;
    [self.tableView reloadData];
}

@end
