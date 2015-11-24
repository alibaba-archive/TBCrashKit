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

//-(BOOL )createTestList:(sqlite3 *)db;//创建数据库
- (BOOL )insertCreashModel:(CrashModel *)model;
- (BOOL )updateCreashModel:(CrashModel *)model;

/**
 *  delete the crash model by ID
 *
 *  @param model model
 *
 *  @return is successful
 */
- (BOOL )deleteCreashModel:(CrashModel *)model;
- (NSArray *)getCreashModels;
@end
