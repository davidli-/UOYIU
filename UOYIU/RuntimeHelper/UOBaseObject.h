//
//  UOBaseObject.h
//  UOYIU
//
//  Created by Macmafia on 2018/5/21.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UOBaseObject : NSObject<NSCoding,NSCopying>
{
    NSString *str1;
}
@property (nonatomic, assign) int int2;
@end
