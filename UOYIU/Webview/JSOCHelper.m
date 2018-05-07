//
//  JSOCHelper.m
//  UOYIU
//
//  Created by Macmafia on 2018/5/7.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "JSOCHelper.h"
@interface JSOCHelper()
@property (nonatomic, weak) UIViewController *viewController;
@end

@implementation JSOCHelper

- (instancetype)initWithSource:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}

#pragma mark -JSExport Delegate methods
- (void)jsCallOCFunction{
    NSLog(@"++++JS CALL OC !!!");
}

@end
