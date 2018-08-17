//
//  UOBlocks.h
//  UOYIU
//
//  Created by Macmafia on 2018/8/7.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UOBlocks : NSObject

- (void)callBlocks;
- (int)blockAsParam:(int (^)(int a,int b))ablock;
- (int(^)(int a,int b))blockAsReturnValue;

@end
