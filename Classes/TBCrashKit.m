//
//  TBCrashKit.m
//  TBCrashKit
//
//  Created by ChenHao on 11/24/15.
//  Copyright © 2015 HarriesChen. All rights reserved.
//

#import "TBCrashKit.h"
#include <execinfo.h>
#import "SqlService.h"

@interface TBCrashKit()

/**
 * Called automatically to handle an exception.
 *
 * @param exception The exception that was raised.
 * @param stackTrace The stack trace.
 */
+ (void) handleException:(NSException *)exception stackTrace:(NSArray *)stackTrace;

/**
 *  callstackToArray
 *  covert the stack to Array the max stack is 128
 *
 *  @return NSArray
 */
+ (NSArray* )callstackToArray;

/**
 * Called automatically to handle a raised signal.
 *
 * @param signal The signal that was raised.
 * @param stackTrace The stack trace.
 */
+ (void)handleSignal:(int)signal stackTrace:(NSArray *)stackTrace;

/**
 * Get the name of a signal.
 *
 * @param signal The signal to get a name for.
 * @return The name of the signal.
 */
+ (NSString *)signalName:(int)signal;

/**
 * Store an exception and stack trace to disk.
 * It will be stored to the file specified in reportFilename.
 *
 * @param exception The exception to store.
 * @param stackTrace The stack trace to store.
 */
+ (void)storeCrash:(NSException* )exception stackTrace:(NSArray* )stackTrace;

@end

/**
 * Install the exception and signal handlers.
 */
static void installHandlers();

/**
 * Remove the exception and signal handlers.
 */
static void removeHandlers();

/**
 * Exception handler.
 * Sets up an appropriate environment and then calls CrashManager to
 * deal with the exception.
 *
 * @param exception The exception that was raised.
 */
static void uncaughtExceptionHandler(NSException* exception);

/**
 * Signal handler.
 * Sets up an appropriate environment and then calls CrashManager to
 * deal with the signal.
 *
 * @param exception The exception that was raised.
 */
static void handleSignal(int signal);


static void installHandlers() {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    signal(SIGILL, handleSignal);
    signal(SIGABRT, handleSignal);
    signal(SIGFPE, handleSignal);
    signal(SIGBUS, handleSignal);
    signal(SIGSEGV, handleSignal);
    signal(SIGSYS, handleSignal);
    signal(SIGPIPE, handleSignal);
}

static void removeHandlers() {
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGILL, SIG_DFL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGSYS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}

static void uncaughtExceptionHandler(NSException *exception) {
    //    NSArray *array = callstackAsArray();
    removeHandlers();
    NSLog(@"%@",exception);
    NSLog(@"%@",exception.reason);
    NSLog(@"%@",exception.name);
    NSLog(@"%@",exception.userInfo);
//    [TBCrashKit ha]
    [TBCrashKit handleException:exception stackTrace:[TBCrashKit callstackToArray]];
    
    //    NSLog(@"%@",);
}

static void handleSignal(int signal)
{
    removeHandlers();
    
    
    [TBCrashKit handleSignal:signal stackTrace:[TBCrashKit callstackToArray]];
    //    NSArray* stackTrace = [[StackTracer sharedInstance] generateTraceWithMaxEntries:kStackFramesToCapture];
    //    [[CrashManager sharedInstance] handleSignal:signal stackTrace:stackTrace];
    //
    //    [pool drain];
    // Note: A signal doesn't need to be re-raised like an exception does.
}

@implementation TBCrashKit

+ (void)crash {
    installHandlers();
}

/**
 *  callstackToArray
 *  covert the stack to Array the max stack is 128
 *
 *  @return NSArray
 */
+ (NSArray* )callstackToArray {
    void* callstack[128];
    const int numFrames = backtrace(callstack, 128);
    char **symbols = backtrace_symbols(callstack, numFrames);
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:numFrames];
    for (int i = 0; i < numFrames; ++i) {
        [arr addObject:[NSString stringWithUTF8String:symbols[i]]];
    }
    free(symbols);
    return arr;
}

+ (void)handleException:(NSException *)exception stackTrace:(NSArray *)stackTrace {
    [TBCrashKit storeCrash:exception stackTrace:stackTrace];
}

+ (void)handleSignal:(int)signal stackTrace:(NSArray *)stackTrace {
    NSException* exception = [NSException exceptionWithName:@"SignalRaisedException"
                                                     reason:[self signalName:signal]
                                                   userInfo:nil];
    [TBCrashKit storeCrash:exception stackTrace:stackTrace];
}

+ (void)storeCrash:(NSException *)exception stackTrace:(NSArray *)stackTrace {
    NSString* data = [NSString stringWithFormat:@"App: %@\nVersion: %@\n\n%@: %@\n%@",
                      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
                      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                      [exception name],
                      [exception reason],
                      stackTrace];
    
    NSLog(@"%@",data);
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,  NSUserDomainMask, YES);
    NSString *cachesDirectoryPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Caches"];
    NSString *regionListFile = [cachesDirectoryPath stringByAppendingPathComponent:@"TBCrash.txt"];
    [data writeToFile:regionListFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    CrashModel *model = [[CrashModel alloc] init];
    model.bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    model.bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    model.exceptionName = [exception name];
    model.exceptionReason = [exception reason];
    model.timeStamp = [NSDate date];
    model.stackTree = [TBCrashKit arrayToString:stackTrace];
    [[[SqlService alloc] init] insertCreashModel:model];
}

+ (NSString *)signalName:(int)signal {
    switch(signal)
    {
        case SIGABRT:
            return @"Abort";
        case SIGILL:
            return @"Illegal Instruction";
        case SIGSEGV:
            return @"Segmentation Fault";
        case SIGFPE:
            return @"Floating Point Error";
        case SIGBUS:
            return @"Bus Error";
        case SIGPIPE:
            return @"Broken Pipe";
        default:
            return [NSString stringWithFormat:@"Unknown Signal (%d)", signal];
    }
}

+ (NSString *)arrayToString:(NSArray *)array {
    NSMutableString *sb = [NSMutableString new];
    for (NSString *str in array) {
        [sb appendString:str];
        [sb appendString:@"\n"];
    }
    return [sb copy];
}

@end
