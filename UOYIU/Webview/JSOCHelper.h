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

@protocol JSOCExportProtocol <JSExport>

- (void)jsCallOCFunction;

@end

@interface JSOCHelper : NSObject
<JSOCExportProtocol>

@property (nonatomic, weak) id <JSOCExportProtocol> mJSOCDelegate;

- (instancetype)initWithSource:(UIViewController*)viewController;
@end
