//
//  UORefreshHeader.m
//  UOYIU
//
//  Created by Macmafia on 2018/8/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UORefreshHeader.h"
#import "Masonry.h"

@implementation UORefreshHeader

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.circle];
        [_circle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-10);
            make.width.equalTo(@50);
            make.height.equalTo(@50);
        }];
    }
    return self;
}

- (UOCircleView *)circle
{
    if (!_circle) {
        _circle = [[UOCircleView alloc] init];
        _circle.backgroundColor = [UIColor clearColor];
    }
    return _circle;
}
@end
