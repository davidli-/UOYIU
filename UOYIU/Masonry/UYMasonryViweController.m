//
//  UYMasonryViweController.m
//  UOYIU
//
//  Created by Macmafia on 2018/6/26.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UYMasonryViweController.h"
#import "Masonry.h"

@interface UYMasonryViweController()

@property (nonatomic, strong) MASConstraint *constraint;
@property (nonatomic, weak) UIView *mView;

@end

@implementation UYMasonryViweController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self mas_makeConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onClickAction:(id)sender {
    NSArray *array = _mView.constraints;
    for (NSLayoutConstraint *constraint in array) {
        NSLog(@"1Attribute:%ld,2Attribute:%ld,1Item:%@,2Item:%@,const:%f",
              (long)constraint.firstAttribute,(long)constraint.secondAttribute,
              [constraint.firstItem class],[constraint.secondItem class],constraint.constant);
    }
    [_mView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@400);
    }];
    [_mView updateConstraintsIfNeeded];
}


#pragma mark -Custom Views

//使用原生 NSLayoutConstraints 添加约束
- (void)mas_NSLayoutAttribute
{
    UIView *superview = self.view;
    
    UIView *view1 = [[UIView alloc] init];
    view1.translatesAutoresizingMaskIntoConstraints = NO;
    view1.backgroundColor = [UIColor greenColor];
    [superview addSubview:view1];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    [superview addConstraints:@[
                                //view1 constraints
                                [NSLayoutConstraint constraintWithItem:view1
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:padding.top],
                                
                                [NSLayoutConstraint constraintWithItem:view1
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:padding.left],
                                
                                [NSLayoutConstraint constraintWithItem:view1
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:-padding.bottom],
                                
                                [NSLayoutConstraint constraintWithItem:view1
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:superview
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:-padding.right],
                                
                                ]];
}

- (void)mas_MASConstraintMaker
{
    UIView *superview = self.view;
    UIView *view1 = [[UIView alloc] init];
    view1.translatesAutoresizingMaskIntoConstraints = NO;
    view1.backgroundColor = [UIColor blueColor];
    [superview addSubview:view1];
    
    /*方案1
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top).offset(10);
        make.left.mas_equalTo(superview.mas_left).offset(10);
        make.bottom.equalTo(superview.mas_bottom).offset(-10);
        make.right.equalTo(superview.mas_right).offset(-10);
    }];*/
    
    //方案2
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@10);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-10);
    }];
    
    /*//方案3
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview).with.insets(padding);
    }];*/
}


- (void)mas_makeConstraints
{
    UIView *superview = self.view;
    UIView *view1 = [[UIView alloc] init];
    view1.translatesAutoresizingMaskIntoConstraints = NO;//可选 Masonry内部已默认置为NO
    view1.backgroundColor = [UIColor orangeColor];
    [superview addSubview:view1];//必须先addSubView才能设置约束
    _mView = view1;
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor blackColor];
    [view1 addSubview:view2];
    
    UIView *view3 = [[UIView alloc] init];
    view3.backgroundColor = [UIColor blueColor];
    [view1 addSubview:view3];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.backgroundColor = [UIColor redColor];
    label1.textColor = [UIColor whiteColor];
    [superview addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.backgroundColor = [UIColor yellowColor];
    label2.textColor = [UIColor blackColor];
    [superview addSubview:label2];
    
    label1.text = @"A12345678901234567890";
    label2.text = @"B12345678901234567890";
    
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(superview);
        make.left.equalTo(superview).offset(10);
        make.right.equalTo(superview).offset(-10);
        _constraint = make.height.equalTo(@200);
    }];
    
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(view1).offset(20);//合并 链式函数思想
        make.bottom.equalTo(view1).offset(-20);
        make.right.equalTo(view3.mas_left).offset(-20).priorityHigh();//间距的设置
        make.width.height.equalTo(view3);
    }];
    
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(view2);
        make.right.equalTo(view1).offset(-20);
    }];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.top.equalTo(view1.mas_bottom).offset(50);
        make.right.equalTo(label2.mas_left).offset(-20);
        make.height.equalTo(label2);
    }];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(label1);
        make.right.equalTo(view1);
    }];
    
    //设置抗压缩
    [label1 setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [label2 setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}
@end
