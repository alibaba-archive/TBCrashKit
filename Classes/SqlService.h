//
//  sqlService.h
//  TBCrashKit
//
//  Created by ChenHao on 11/24/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "CrashModel.h"

@interface SqlService : NSObject

@property (nonatomic) sqlite3 *database;

-(BOOL )createTestList:(sqlite3 *)db;//创建数据库
-(BOOL )insertCreashModel:(CrashModel *)model;//插入数据
-(BOOL )updateCreashModel:(CrashModel *)model;//更新数据
-(NSArray *)getCreashModels;//获取全部数据
- (BOOL )deleteCreashModel:(CrashModel *)model;//删除数据：

@end
