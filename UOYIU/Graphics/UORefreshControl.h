//
//  UORefreshControl.h
//  UOYIU
//
//  Created by Macmafia on 2018/8/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UORefreshHeader.h"

@interface UORefreshControl : NSObject

- (id)initWithTableview:(UITableView*)tableview;
- (UORefreshHeader*)createRefreshHeader;
- (void)removeObserver;
@end
