//
//  UOProgressViewController.m
//  UOYIU
//
//  Created by Macmafia on 2018/8/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UOProgressViewController.h"
#import "UOCircleView.h"

@interface UOProgressViewController ()

@property (weak, nonatomic) IBOutlet UISlider *mSlider;
@property (weak, nonatomic) IBOutlet UOCircleView *mCircleView;

@end

@implementation UOProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onSliderUpdates:(id)sender
{
    UISlider *slider = sender;
    NSLog(@"++++%f",slider.value);
    [self.mCircleView setProgress:slider.value];
}

@end
