//
//  UOBlocks.m
//  UOYIU
//
//  Created by Macmafia on 2018/8/7.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UOBlocks.h"

typedef int(^multiBlock)(int a,int b);

@interface UOBlocks()

@property (nonatomic, copy) multiBlock mMultiBlock;
@property (nonatomic, copy) int (^clickBlock)(int a);

@end

@implementation UOBlocks

- (void)callBlocks
{
    //1
    self.mMultiBlock = ^int(int a, int b) {
        return a * b;
    };
    NSLog(@"++++%d",self.mMultiBlock(2,3));
    
    //2
    self.clickBlock = ^int(int a) {
        return a;
    };
    self.clickBlock(5);
}

- (int)blockAsParam:(int (^)(int a,int b))ablock
{
    return ablock(2,3);
}

- (int(^)(int a,int b))blockAsReturnValue{
    return ^int (int x,int y){
        return x * y;
    };
}
@end
