//
//  UOModalViewController.m
//  UOYIU
//
//  Created by Macmafia on 2018/5/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UOModalViewController.h"

@interface UOModalViewController ()
@end

@implementation UOModalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)dealloc{
    NSLog(@"++UOModalViewController dealloced~");
}

- (IBAction)onActions:(id)sender {
    if ([_delegate respondsToSelector:@selector(modalViewControllerDidClickedDismissButton:)]) {
        [_delegate modalViewControllerDidClickedDismissButton:self];
    }
}

@end
