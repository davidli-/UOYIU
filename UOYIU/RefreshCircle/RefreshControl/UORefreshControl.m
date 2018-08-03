//
//  UORefreshControl.m
//  UOYIU
//
//  Created by Macmafia on 2018/8/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UORefreshControl.h"
#import "UORefreshHeader.h"
#import "Masonry.h"

@interface UORefreshControl()
@property (nonatomic, strong) UITableView *mTableview;
@property (nonatomic, strong) UORefreshHeader *mRefreshHeader;
@property (nonatomic, assign) CGFloat mInsetY;
@end

@implementation UORefreshControl

- (id)initWithTableview:(UITableView*)tableview
{
    self = [super init];
    if (self) {
        _mTableview = tableview;
        _mInsetY = ABS(_mTableview.adjustedContentInset.top);
        [_mTableview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (UORefreshHeader*)createRefreshHeader
{
    if (!_mRefreshHeader) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        _mRefreshHeader = [[UORefreshHeader alloc] init];
        _mRefreshHeader.backgroundColor = [UIColor greenColor];
        [_mTableview addSubview:_mRefreshHeader];
        [_mRefreshHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_mTableview);
            make.bottom.equalTo(_mTableview.mas_top);
            make.height.equalTo(@(bounds.size.height));
            make.width.equalTo(@(bounds.size.width));
        }];
    }
    
    return _mRefreshHeader;
}

- (void)removeObserver{
    [_mTableview removeObserver:self forKeyPath:@"contentOffset"];
}

-(void)dealloc{
    [self removeObserver];
}

#pragma mark - KVO Observe
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        float progress = (ABS(offset.y) - _mInsetY) / 100;
        if (progress > 1) {
            progress = 1;
        }
        if (progress < 0) {
            progress = 0;
        }
        _mRefreshHeader.circle.progress = progress;
        //NSLog(@"+++OffsetY: %.2f, progress:%.2f",offset.y,progress);
    }
}

@end
