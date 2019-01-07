//
//  JSOCHelper.h
//  UOYIU
//
//  Created by Macmafia on 2018/5/7.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

//声明一个协议，继承并扩展JSExport协议
@protocol JSOCExportProtocol <JSExport>

//声明属性
@property (nonatomic, copy) NSString *name;
//声明供js回调的OC方法
- (void)jsCallOCFunction;

@end

//实现JSExport协议，这就是注册JSContext时传递的对象
@interface JSOCHelper : NSObject<JSOCExportProtocol>

@property (nonatomic, weak) id <JSOCExportProtocol> mJSOCDelegate;

- (instancetype)initWithSource:(UIViewController*)viewController;

@end
