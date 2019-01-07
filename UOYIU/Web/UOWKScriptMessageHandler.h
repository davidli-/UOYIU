//
//  UOWKScriptMessageHandler.h
//  UOYIU
//
//  Created by Macmafia on 2018/5/7.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

UIKIT_EXTERN NSString *const NativeFunc_Hello;

@interface UOWKScriptMessageHandler : NSObject<WKScriptMessageHandler>

@end
