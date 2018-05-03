//
//  People.h
//  UOYIU
//
//  Created by Macmafia on 2018/4/12.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AModel : NSObject
@property (nonatomic, strong) NSString *_modelString;
@end

@interface People : NSObject
@property (nonatomic, strong) NSString *stringA;
@property (nonatomic, strong) AModel *modelA;
@end
