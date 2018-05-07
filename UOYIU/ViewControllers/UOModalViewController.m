//
//  UOModalViewController.m
//  UOYIU
//
//  Created by Macmafia on 2018/5/3.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UOModalViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSOCHelper.h"
#import "UOWKScriptMessageHandler.h"

@interface UOModalViewController ()
<
WKNavigationDelegate,
UIWebViewDelegate
>
@property (weak, nonatomic) IBOutlet UIWebView *mUIWebview;
@property (weak, nonatomic) IBOutlet WKWebView *mWKWebview;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) UOWKScriptMessageHandler *mScriptMessHandler;

@end

@implementation UOModalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUps];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeMessageHandler];
}

-(void)dealloc{
    NSLog(@"++++++dealloced");
}

- (IBAction)onActions:(id)sender {
    if ([_delegate respondsToSelector:@selector(modalViewControllerDidClickedDismissButton:)]) {
        [_delegate modalViewControllerDidClickedDismissButton:self];
    }
}

#pragma -mark UIWebviewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //为JSContext注入Bridge对象
    _jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _jsContext[@"jsbridge"] = [[JSOCHelper alloc] initWithSource:self];
 
    //注册js回调OC的函数
    _jsContext[@"jsCallOCFunction"] = ^(id data,NSError *error){
        NSLog(@"++++++");
    };
    
    //执行JS 方法1
    NSString *jsFuncScript = @"login('Dav','123')";
    [_jsContext evaluateScript:jsFuncScript];
    //执行JS 方法2
    JSValue *jsFunc = _jsContext[@"login"];
    [jsFunc callWithArguments:@[@"Dav",@"123"]];
    //执行JS 方法3
    [webView stringByEvaluatingJavaScriptFromString:jsFuncScript];
}

#pragma -mark WKNavigationDelegate
//在发送请求之前，决定是否跳转
-(void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //检测cookie，有cookie时允许本次导航，没有cookie则不允许并重新设置cookie。
    WKNavigationActionPolicy policy = WKNavigationActionPolicyAllow;
    NSURL *url = navigationAction.request.URL;
    NSDictionary *aHeaderFieldsDic = navigationAction.request.allHTTPHeaderFields;
    NSString *cookie = aHeaderFieldsDic[@"Cookie"];
    
    //如果没有cookie 取消当前请求 重新设置cookie后再发送
    if (!cookie || 0 == cookie.length) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.allHTTPHeaderFields = aHeaderFieldsDic;
        [request setValue:@"name='Dav'" forHTTPHeaderField:@"Cookie"];
        [webView loadRequest:request];
        policy = WKNavigationActionPolicyCancel;
    }
    decisionHandler(policy);
}

//在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
}

//当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSString *jsFuncScript = @"login('Dav','123')";
    [_mWKWebview evaluateJavaScript:jsFuncScript completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"+++++WKWebview执行js：%@",jsFuncScript);
    }];
}

//页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
}

//接收到服务器跳转请求之后调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"++++++地址重定向");
}

#pragma -mark BUSINESS
- (void)setUps
{
    [self loadUIWebview];
    [self loadWKWebview];
}

- (void)loadUIWebview
{
    _mUIWebview.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:
                                    [NSURL URLWithString:@"https://www.baidu.com"]];
    [_mUIWebview loadRequest:request];
}

- (void)loadWKWebview
{
    _mWKWebview.navigationDelegate = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:@"https://www.baidu.com"]];
    //设置cookie
    NSString *cookie = [NSString stringWithFormat:@"document.cookie='username'"];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:cookie
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:NO];
    [_mWKWebview.configuration.userContentController addUserScript:script];
    [_mWKWebview loadRequest:request];
    _mScriptMessHandler = [UOWKScriptMessageHandler new];
    [_mWKWebview.configuration.userContentController addScriptMessageHandler:_mScriptMessHandler name:@"MessHandleName"];
}

- (void)clearCache
{
    NSSet *dataType = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache,
                                            WKWebsiteDataTypeMemoryCache]];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:dataType
                                               modifiedSince:[NSDate date]
                                           completionHandler:^{
        NSLog(@"+++++clear cache++++");
    }];
}

- (void)removeMessageHandler{
    //离开时调用 否则会造成内存泄漏
    _mScriptMessHandler = nil;
    [_mWKWebview.configuration.userContentController removeScriptMessageHandlerForName:@"MessHandleName"];
}
@end
