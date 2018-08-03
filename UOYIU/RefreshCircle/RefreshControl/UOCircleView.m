//
//  UOCircleView.m
//  UOYIU
//
//  Created by Macmafia on 2018/8/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UOCircleView.h"

@implementation UOCircleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUps];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUps];
    }
    return self;
}

-(void)setProgress:(float)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //边宽
    CGFloat lineWidth = 3.0f;
    //半径
    CGFloat radius = (CGRectGetWidth(rect) - lineWidth * 2) / 2.0;
    //圆心
    CGPoint center = CGPointMake(CGRectGetWidth(rect)/2.0, CGRectGetHeight(rect) / 2.0);
    //扇形起点
    CGFloat startAngle = - M_PI_2;
    //根据进度计算扇形结束位置
    CGFloat endAngle = startAngle + self.progress * M_PI * 2;
    //根据起始点、原点、半径绘制弧线
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    if (CIRCLE_STYLE_BORDER == _style)//画线
    {
        CGContextRef ref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ref, lineWidth);
        CGContextSetStrokeColorWithColor(ref, self.borderColor.CGColor);
        CGContextAddPath(ref, path.CGPath);
        CGContextStrokePath(ref);
    }
    else if (CIRCLE_STYLE_FILL == _style)//画饼
    {
        //从弧线结束为止绘制一条线段到圆心。这样系统会自动闭合图形，绘制一条从圆心到弧线起点的线段。
        [path addLineToPoint:center];
        //设置扇形的填充颜色
        [self.fillColor set];
        //设置扇形的填充模式
        [path fill];
    }
    else{
        CGContextRef ref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ref, lineWidth);
        CGContextSetFillColorWithColor(ref, self.fillColor.CGColor);
        CGContextSetStrokeColorWithColor(ref, self.borderColor.CGColor);
        //从弧线结束为止绘制一条线段到圆心。这样系统会自动闭合图形，绘制一条从圆心到弧线起点的线段。
        [path addLineToPoint:center];
        CGContextAddPath(ref, path.CGPath);
        CGContextDrawPath(ref, kCGPathFillStroke);
    }
}

//默认配置
- (void)setUps{
    _style = CIRCLE_STYLE_BOTH;
    self.backgroundColor = [UIColor clearColor];
    self.fillColor = [UIColor blueColor];
    self.borderColor = [UIColor whiteColor];
}
@end
