//
//  ASDFUIWebViewController.m
//  UOYIU
//
//  Created by Macmafia on 2019/1/7.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import "ASDFUIWebViewController.h"
#import "JSOCHelper.h"

@interface ASDFUIWebViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *mUIWebview;
@property (nonatomic, strong) JSContext *jsContext;
@end

@implementation ASDFUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUps];
}

#pragma -mark UIWebviewDelegate
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    //拦截请求
    if (UIWebViewNavigationTypeOther == navigationType) {
        if ([request.URL.absoluteString rangeOfString:@"XX"].location != NSNotFound) {
            //native处理逻辑
            return NO;
        }
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //为JSContext注入Bridge对象
    _jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _jsContext[@"jsbridge"] = [[JSOCHelper alloc] initWithSource:self];
    _jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"++JSContext Exception:%@",exception);
    };
    
    //JS调用OC原生方法（JS中通过jsbridge调用OC提供的接口）
    [_jsContext evaluateScript:@"jsbridge.jsCallOCFunction()"];//模拟js回调OC
    
    //OC调用js
    //js中定义login函数，block为其对应的OC回调
    _jsContext[@"login"] = ^(id data,NSString *error){
        NSLog(@"++++++js call jsContext block, data:%@,error:%@",data,error);
    };
    
    //方法1
    JSValue *jsFunc = _jsContext[@"login"];//调用上面注册的block
    [jsFunc callWithArguments:@[@"data",@"call by JSValue Error info"]];
    //方法2
    [_jsContext evaluateScript:@"login('data','call by [jsContext evaluateScript:] Error info')"];//OC调用JS中定义的登录方法
    //方法3
    NSString *jsFuncScript = @"login('data','Error info~')";
    [webView stringByEvaluatingJavaScriptFromString:jsFuncScript];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

#pragma mark -Setups
- (void)setUps
{
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:@"https://www.baidu.com"]];
    [_mUIWebview loadRequest:request];
}
@end
