//
//  UOModalViewController.h
//  UOYIU
//
//  Created by Macmafia on 2018/5/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UOModalViewController;
@protocol UOModalViewControllerDelegate <NSObject>

- (void) modalViewControllerDidClickedDismissButton:(UOModalViewController *)viewController;

@end

@interface UOModalViewController : UIViewController
@property (nonatomic, weak) id<UOModalViewControllerDelegate> delegate;
@end
