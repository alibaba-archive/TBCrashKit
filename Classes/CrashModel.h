//
//  CrashModel.h
//  TBCrashKit
//
//  Created by ChenHao on 11/24/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashModel : NSObject

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, copy) NSString *bundleName;
@property (nonatomic, copy) NSString *bundleVersion;

@property (nonatomic, copy) NSString *exceptionName;
@property (nonatomic, copy) NSString *exceptionReason;
@property (nonatomic, copy) NSString *stackTree;

@property (nonatomic, strong) NSDate *timeStamp;

@end
