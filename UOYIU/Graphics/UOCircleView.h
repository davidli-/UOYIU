//
//  UOCircleView.h
//  UOYIU
//
//  Created by Macmafia on 2018/8/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CIRCLE_STYLE_BORDER,//画圈
    CIRCLE_STYLE_FILL,//画饼
    CIRCLE_STYLE_BOTH,//画圈 + 画饼
}CIRCLE_STYLE;

@interface UOCircleView : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, assign) CIRCLE_STYLE style;
@property (nonatomic, strong) UIColor *fillColor;//饼图填充色
@property (nonatomic, strong) UIColor *borderColor;//边框颜色

@end
