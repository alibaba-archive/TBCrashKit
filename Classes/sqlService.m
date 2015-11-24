//
//  sqlService.m
//  TBCrashKit
//
//  Created by ChenHao on 11/24/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import "SqlService.h"

@implementation SqlService

/**
 *  get the document menu
 *
 *  @return the database menu
 */
- (NSString *)dataFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"tbcrash.db"];
}


/**
 *  open the database
 *
 *  @return if open success it will return YES and return NO when faild
 */
- (BOOL )openDB {
    NSString *path = [self dataFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:path];
    //如果数据库存在，则用sqlite3_open直接打开（不要担心，如果数据库不存在sqlite3_open会自动创建）
    if (exist) {
        NSLog(@"Database file have already existed.");
        if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
            sqlite3_close(self.database);
            NSLog(@"Error: open database file.");
            return NO;
        }
        [self createTable:self.database];
        return YES;
    }
    if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
        [self createTable:self.database];
        return YES;
    } else {
        sqlite3_close(self.database);
        NSLog(@"Error: open database file.");
        return NO;
    }
    return NO;
}

- (BOOL )createTable:(sqlite3 *)db {
    char *sql = "create table if not exists crashTable(\
    ID INTEGER PRIMARY KEY AUTOINCREMENT, \
    bundleName TEXT,\
    bundleVersion TEXT,\
    exceptionName TEXT,\
    exceptionReason TEXT,\
    stackTree TEXT,\
    timeStamp INTEGER)";
    
    sqlite3_stmt *statement;
    NSInteger sqlReturn = sqlite3_prepare_v2(_database, sql, -1, &statement, nil);
    if(sqlReturn != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement:create test table");
        return NO;
    }
    int success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    if ( success != SQLITE_DONE) {
        NSLog(@"Error: failed to dehydrate:create table test");
        return NO;
    }
    NSLog(@"Create table 'crashTable' successed.");
    return YES;
}

-(BOOL ) insertCreashModel:(CrashModel *)model{
    if ([self openDB]) {
        sqlite3_stmt *statement;
        static char *sql = "INSERT INTO crashTable(ID, bundleName,bundleVersion,exceptionName,\
        exceptionReason, stackTree, timeStamp) VALUES(NULL, ?, ?, ?, ?, ?, ?)";
        int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success2 != SQLITE_OK) {
            NSLog(@"Error: failed to insert:testTable");
            sqlite3_close(_database);
            return NO;
        }
        sqlite3_bind_text(statement, 1, [model.bundleName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [model.bundleVersion UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [model.exceptionName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [model.exceptionReason UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [model.stackTree UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int (statement, 6, [model.timeStamp timeIntervalSince1970]);
        success2 = sqlite3_step(statement);
        sqlite3_finalize(statement);
        if (success2 == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
            sqlite3_close(_database);
            return NO;
        }
        sqlite3_close(_database);
        return YES;
    }
    return NO;
}

-(NSArray *)getCreashModels{
    NSMutableArray *array = [NSMutableArray new];
    if ([self openDB]) {
        sqlite3_stmt *statement = nil;
        char *sql = "SELECT * FROM crashTable";
        if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message:get testValue.");
            return nil;
        }
        else {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                CrashModel *model = [[CrashModel alloc] init];
                model.ID    = sqlite3_column_int(statement,0);
                char* bundleName   = (char*)sqlite3_column_text(statement, 1);
                model.bundleName = [NSString stringWithUTF8String:bundleName];
                char *bundleVersion = (char*)sqlite3_column_text(statement, 2);
                model.bundleVersion = [NSString stringWithUTF8String:bundleVersion];
                char *exceptionName = (char*)sqlite3_column_text(statement, 3);
                model.exceptionName = [NSString stringWithUTF8String:exceptionName];
                char *exceptionReason = (char*)sqlite3_column_text(statement, 4);
                model.exceptionReason = [NSString stringWithUTF8String:exceptionReason];
                char *stackTree = (char*)sqlite3_column_text(statement, 5);
                model.stackTree = [NSString stringWithUTF8String:stackTree];
                model.timeStamp = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_int(statement, 6)];
                [array addObject:model];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(_database);
    }
    return [array copy];
}


- (BOOL )deleteCreashModel:(CrashModel *)model {
    if ([self openDB]) {
        sqlite3_stmt *statement;//这相当一个容器，放转化OK的sql语句
        char *sql = "DELETE FROM crashTable where ID = ?";
        int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to delete");
            sqlite3_close(_database);
            return NO;
        }
        sqlite3_bind_int(statement, 1, model.ID);
        success = sqlite3_step(statement);
        sqlite3_finalize(statement);
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to delete the database with message.");
            sqlite3_close(_database);
            return NO;
        }
        sqlite3_close(_database);
        return YES;
    }
    return NO;
}

@end
