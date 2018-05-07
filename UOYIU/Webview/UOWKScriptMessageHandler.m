//
//  UOWKScriptMessageHandler.m
//  UOYIU
//
//  Created by Macmafia on 2018/5/7.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UOWKScriptMessageHandler.h"

@implementation UOWKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"MessHandleName"]) {
        if ([message.body isEqualToString:@"funcName"]) {
        }
    }
}
@end
