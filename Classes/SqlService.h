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

/**
 *  insert crashModel instance to the databse
 *
 *  @param model crashModel
 *
 *  @return is successful
 */
- (BOOL )insertCreashModel:(CrashModel *)model;

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
