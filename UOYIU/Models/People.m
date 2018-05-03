//
//  People.m
//  UOYIU
//
//  Created by Macmafia on 2018/4/12.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "People.h"

@implementation AModel
- (void)set_modelString:(NSString *)_modelString
{
    __modelString = _modelString;
    NSLog(@"++++执行 setter _modelString");
}

- (void)setModelString:(NSString *)modelString
{
    NSLog(@"++++执行 setter modelString");
}

- (void)setNoExist1:(NSString *)noExist
{
    NSLog(@"++++执行 setter noExist1 ");
}
@end

@implementation People

- (void)setStringA:(NSString *)stringA
{
    _stringA = stringA;
    NSLog(@"++++执行 setter stringA");
}

- (instancetype)init
{
    if (self = [super init]) {
        self.modelA = [[AModel alloc] init];
    }
    return self;
}
@end
