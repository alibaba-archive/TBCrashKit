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
        //打开数据库，这里的[path UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是
        //Objective-C)编写的，它不知道什么是NSString.
        if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
            
            //如果打开数据库失败则关闭数据库
            sqlite3_close(self.database);
            NSLog(@"Error: open database file.");
            return NO;
        }
        
        //创建一个新表
        [self createTable:self.database];
        
        return YES;
    }
    //如果发现数据库不存在则利用sqlite3_open创建数据库（上面已经提到过），与上面相同，路径要转换为C字符串
    if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
        
        //创建一个新表
        [self createTable:self.database];
        return YES;
    } else {
        //如果创建并打开数据库失败则关闭数据库
        sqlite3_close(self.database);
        NSLog(@"Error: open database file.");
        return NO;
    }
    return NO;
}

//创建表
- (BOOL )createTable:(sqlite3 *)db {
    //这句是大家熟悉的SQL语句
    char *sql = "create table if not exists crashTable(\
    ID INTEGER PRIMARY KEY AUTOINCREMENT, \
    bundleName TEXT,\
    bundleVersion TEXT,\
    exceptionName TEXT,\
    exceptionReason TEXT,\
    stackTree TEXT,\
    timeStamp INTEGER)";
    
    sqlite3_stmt *statement;
    //sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
    NSInteger sqlReturn = sqlite3_prepare_v2(_database, sql, -1, &statement, nil);
    //第一个参数跟前面一样，是个sqlite3 * 类型变量，
    //第二个参数是一个 sql 语句。
    //第三个参数我写的是-1，这个参数含义是前面 sql 语句的长度。如果小于0，sqlite会自动计算它的长度（把sql语句当成以\0结尾的字符串）。
    //第四个参数是sqlite3_stmt 的指针的指针。解析以后的sql语句就放在这个结构里。
    //第五个参数是错误信息提示，一般不用,为nil就可以了。
    //如果这个函数执行成功（返回值是 SQLITE_OK 且 statement 不为NULL ），那么下面就可以开始插入二进制数据。
    
    
    //如果SQL语句解析出错的话程序返回
    if(sqlReturn != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement:create test table");
        return NO;
    }
    
    //执行SQL语句
    int success = sqlite3_step(statement);
    //释放sqlite3_stmt
    sqlite3_finalize(statement);
    
    //执行SQL语句失败
    if ( success != SQLITE_DONE) {
        NSLog(@"Error: failed to dehydrate:create table test");
        return NO;
    }
    NSLog(@"Create table 'crashTable' successed.");
    return YES;
}

//插入数据
-(BOOL ) insertCreashModel:(CrashModel *)model{
    //先判断数据库是否打开
    if ([self openDB]) {
        sqlite3_stmt *statement;
        //这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
        static char *sql = "INSERT INTO crashTable(ID, bundleName,bundleVersion,exceptionName,\
        exceptionReason, stackTree, timeStamp) VALUES(NULL, ?, ?, ?, ?, ?, ?)";
        int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success2 != SQLITE_OK) {
            NSLog(@"Error: failed to insert:testTable");
            sqlite3_close(_database);
            return NO;
        }
        
        //这里的数字1，2，3代表上面的第几个问号，这里将三个值绑定到三个绑定变量
        
        sqlite3_bind_text(statement, 1, [model.bundleName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [model.bundleVersion UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [model.exceptionName UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [model.exceptionReason UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [model.stackTree UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int (statement, 6, [model.timeStamp timeIntervalSince1970]);

        //执行插入语句
        success2 = sqlite3_step(statement);
        //释放statement
        sqlite3_finalize(statement);
        
        //如果插入失败
        if (success2 == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
            //关闭数据库
            sqlite3_close(_database);
            return NO;
        }
        //关闭数据库
        sqlite3_close(_database);
        return YES;
    }
    return NO;
}

-(NSArray *)getCreashModels{
    NSMutableArray *array = [NSMutableArray new];
    if ([self openDB]) {
        sqlite3_stmt *statement = nil;
        //sql语句
        char *sql = "SELECT * FROM crashTable";
        if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message:get testValue.");
            return nil;
        }
        else {
            //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
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


@end
