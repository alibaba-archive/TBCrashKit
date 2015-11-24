# TBCrashKit

[![Build Status](https://travis-ci.org/teambition/TBCrashKit.svg)](https://travis-ci.org/teambition/TBCrashKit)

#How to Use

add `libsqlite3.tbd` to your project
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...
    [TBCrashKit crash];
    ...
    return YES;
}

```

just one line in the `AppDelegate`

#

#Demo
Check out the Example project.


#License
AutocompleteField is provided under the MIT License. See LICENSE for details.
