//
//  ModelSerialiseHelper.h
//  UOYIU
//
//  Created by Macmafia on 2018/5/21.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#ifndef ModelSerialiseHelper_h
#define ModelSerialiseHelper_h

#import <objc/runtime.h>
/*
 序列化工具使用示例:
 
 1、TLObject头文件中声明NSCoding协议
 
 @interface TLObject : NSObject<NSCoding>
 @property (nonatomic, copy) NSString *mName;
 @property (nonatomic) BOOL mIsTrue;
 @property (nonatomic) NSInteger mInteger;
 @property (nonatomic) UIImage *mImage;
 @end
 
 2、m文件中导入头文件和宏即可
 
 #import "TLObject.h"
 #import "ModelSerialiseHelper.h"
 @implementation TLObject
 
 ModelCodingProtocol()
 
 @end
 */


#define ModelCodingProtocol()\
- (id)initWithCoder:(NSCoder *)coder\
{\
    Class cls = [self class];\
    while (cls != [NSObject class])\
    {\
        unsigned int count = 0;\
        Ivar *ivarList = class_copyIvarList([cls class], &count);\
        for (int i = 0; i < count; i++)\
        {\
            const char *varName = ivar_getName(*(ivarList + i));\
            NSString *key = [NSString stringWithUTF8String:varName];\
            NSString *aStr = [key substringToIndex:1];\
            if ([aStr isEqualToString:@"_"]) {\
                key = [key substringFromIndex:1];\
            }\
            id varValue = [coder decodeObjectForKey:key];\
            if (varValue) {\
                [self setValue:varValue forKey:key];\
            }\
        }\
        free(ivarList);\
        cls = class_getSuperclass(cls);\
    }\
    return self;\
}\
- (void)encodeWithCoder:(NSCoder *)coder\
{\
    Class cls = [self class];\
    while (cls != [NSObject class])\
    {\
        unsigned int count = 0;\
        Ivar *ivarList = class_copyIvarList([cls class], &count);\
        for (int i = 0; i < count; i++)\
        {\
            const char *varName = ivar_getName(*(ivarList + i));\
            NSString *key = [NSString stringWithUTF8String:varName];\
            NSString *aStr = [key substringToIndex:1];\
            if ([aStr isEqualToString:@"_"]) {\
                key = [key substringFromIndex:1];\
            }\
            id varValue = [self valueForKey:key];\
            if (varValue) {\
                [coder encodeObject:varValue forKey:key];\
            }\
        }\
        free(ivarList);\
        cls = class_getSuperclass(cls);\
    }\
}\

#define ModelCopyProtocol()\
- (id)copyWithZone:(NSZone *)zone\
{\
    id copy = [[[self class] allocWithZone:zone] init];\
    Class cls = [self class];\
    while (cls != [NSObject class])\
    {\
        unsigned int count = 0;\
        Ivar *ivarList = class_copyIvarList([cls class], &count);\
        for (int i = 0; i < count; i++)\
        {\
            const char *varName = ivar_getName(*(ivarList + i));\
            NSString *key = [NSString stringWithUTF8String:varName];\
            NSString *aStr = [key substringToIndex:1];\
            if ([aStr isEqualToString:@"_"]) {\
                key = [key substringFromIndex:1];\
            }\
            id varValue = [self valueForKey:key];\
            if (varValue) {\
                [copy setValue:varValue forKey:key];\
            }\
        }\
        free(ivarList);\
        cls = class_getSuperclass(cls);\
    }\
    return copy;\
}\

#endif /* ModelSerialiseHelper_h */
