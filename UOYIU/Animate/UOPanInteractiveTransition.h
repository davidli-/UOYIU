//
//  UOPanInteractiveTransition.h
//  UOYIU
//
//  Created by Macmafia on 2018/5/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UOPanInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign) BOOL interacting;

- (void)setUps:(UIViewController*)Vc;
@end
