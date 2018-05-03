//
//  ViewController.m
//  UOYIU
//
//  Created by Macmafia on 2018/2/28.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "ViewController.h"
#import "UOModalViewController.h"
#import "UOShowAnimation.h"
#import "UODismissAnimation.h"
#import "UOPanInteractiveTransition.h"

@interface ViewController ()
<UITextViewDelegate,
UIViewControllerTransitioningDelegate,
UOModalViewControllerDelegate
>
{
    NSString *fText;
    NSString *bText;
}

@property (weak, nonatomic) IBOutlet UITextView *mTextview;
@property (nonatomic, strong) UOModalViewController *mModalViewControler;
@property (nonatomic, strong) UOShowAnimation *mShowAnimation;//push动画
@property (nonatomic, strong) UODismissAnimation *mDismissAnimation;//dismiss动画
@property (nonatomic, strong) UOPanInteractiveTransition *mPanTransation;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"CoreText";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    [self mutableTextview];
    
//    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
//    [bt setTitle:@">2<" forState:UIControlStateNormal];
//    [bt setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [bt sizeToFit];
//    [bt addTarget:self action:@selector(onHandleBack) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bt];
//    self.navigationItem.leftItemsSupplementBackButton = YES;
}

#pragma mark -Actions

- (IBAction)onActions:(id)sender {
    if (!_mModalViewControler) {
        _mModalViewControler = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]
                                instantiateViewControllerWithIdentifier:@"UOModal"];
        _mModalViewControler.transitioningDelegate = self;
        _mModalViewControler.delegate = self;
    }
    
    if (!_mPanTransation) {
        _mPanTransation = [UOPanInteractiveTransition new];
        [_mPanTransation setUps:_mModalViewControler];
    }
    [self presentViewController:_mModalViewControler animated:YES completion:NULL];
}

#pragma mark -UIViewController Transation Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    if (!_mShowAnimation) {
        _mShowAnimation = [UOShowAnimation new];
    }
    return _mShowAnimation;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if (!_mDismissAnimation) {
        _mDismissAnimation = [UODismissAnimation new];
    }
    return _mDismissAnimation;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return self.mPanTransation.interacting ? self.mPanTransation : nil;
}

#pragma mark -UITextview Delegate
-(BOOL)textView:(UITextView *)textView
shouldInteractWithURL:(NSURL *)URL
        inRange:(NSRange)characterRange
    interaction:(UITextItemInteraction)interaction{
    return NO;
//    if (characterRange.location >= fText.length) {
//        NSLog(@"++++URL:%@",URL.absoluteString);
//        return YES;
//    }else{
//        return NO;
//    }
}

-(void)modalViewControllerDidClickedDismissButton:(id)viewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -Text Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

#pragma mark -Business
- (void)mutableTextview
{
    //文字颜色大小
    fText = @"This is an rich Text~:";
    bText = @"https://www.baidu.com";
    NSMutableAttributedString *mutAttStr = [[NSMutableAttributedString alloc]
                                            initWithString:[NSString stringWithFormat:@"%@%@",fText,bText]
                                            attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                         NSFontAttributeName:[UIFont systemFontOfSize:16]
                                                         }];
    [mutAttStr addAttribute:NSUnderlineStyleAttributeName value:@(1) range:NSMakeRange(fText.length, bText.length)];
    [mutAttStr addAttribute:NSUnderlineColorAttributeName value:[UIColor blueColor] range:NSMakeRange(fText.length, bText.length)];
    [mutAttStr addAttribute:NSLinkAttributeName value:[NSURL URLWithString:bText] range:NSMakeRange(fText.length, bText.length)];
    //点击时的样式
    NSDictionary *linkAttributes =@{NSForegroundColorAttributeName: [UIColor greenColor],
                                    NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                    NSUnderlineStyleAttributeName:@(NSUnderlinePatternSolid)};
    _mTextview.attributedText = mutAttStr;
    _mTextview.linkTextAttributes = linkAttributes;
}

- (void)onHandleBack{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
