//
//  UYDatabase.h
//  UOYIU
//
//  Created by Macmafia on 2018/6/26.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UYDatabase : NSObject

+ (instancetype)shareInstance;
- (void)coreDataTest;

@end
