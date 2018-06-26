//
//  AppDelegate.m
//  UOYIU
//
//  Created by Macmafia on 2018/2/28.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "AppDelegate.h"
#import "UYDatabase.h"

@interface AppDelegate()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UYDatabase *database = [UYDatabase shareInstance];
    [database coreDataTest];
    return YES;
}
@end
