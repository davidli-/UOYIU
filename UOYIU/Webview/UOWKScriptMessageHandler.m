//
//  UOWKScriptMessageHandler.m
//  UOYIU
//
//  Created by Macmafia on 2018/5/7.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UOWKScriptMessageHandler.h"

NSString *const NativeFunc_Hello = @"wk_methodName";

@implementation UOWKScriptMessageHandler

//从 web 界面中接收到一个脚本时调用
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:NativeFunc_Hello]) {
        NSLog(@"++++WK Script message:%@",message.body);
    }
}
@end
