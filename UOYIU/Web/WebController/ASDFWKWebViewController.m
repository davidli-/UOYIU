//
//  ASDFWKWebViewController.m
//  UOYIU
//
//  Created by Macmafia on 2019/1/7.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#import "ASDFWKWebViewController.h"
#import <WebKit/WebKit.h>
#import "UOWKScriptMessageHandler.h"

@interface ASDFWKWebViewController ()
<WKNavigationDelegate,
WKUIDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *mWKWebview;
@property (weak, nonatomic) IBOutlet UIProgressView *mProgressView;

@property (nonatomic, strong) UOWKScriptMessageHandler *mScriptMessHandler;
@end

@implementation ASDFWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUps];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeMessageHandler];
}

-(void)dealloc{
    NSLog(@"++ASDFWKWebViewController dealloced~");
    [_mWKWebview.configuration.userContentController removeScriptMessageHandlerForName:NativeFunc_Hello];
    [_mWKWebview removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma -mark WKNavigationDelegate

// 决定导航的动作，通常用于处理跨域的链接能否导航。
// WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接单独处理。
// 但是，对于Safari是允许跨域的，不用这么处理。
// 决定是否允许发起这个请求
-(void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    WKNavigationActionPolicy policy = WKNavigationActionPolicyAllow;
    
    if (WKNavigationTypeOther == navigationAction.navigationType)
    {
        //检测cookie，有cookie时允许本次导航，没有cookie则不允许并重新设置cookie。
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
    }
    //在发送请求之前，决定是否跳转
    decisionHandler(policy);
}

//在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//用于授权验证的API，与AFN、UIWebView的授权验证API是一样的
- (void)webView:(WKWebView *)webView
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling ,nil);
}


//页面开始加载时调用（main frame的导航开始请求）
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
}

//webview内容已经加载结束，但是上面的某些资源比如图片加载之前调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
}

//页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"++++WKWebVie didFinishNavigation:%@",webView.URL.absoluteString);
    //除了首次加载的链接外，其他链接和重定向都不弹框
    if (![webView.URL.absoluteString isEqualToString:@"https://www.baidu.com/"]) {
        return;
    }
    //OC调用js中定义的函数
    NSString *jsFuncScript = @"alert('I am an alert box!!')";
    [_mWKWebview evaluateJavaScript:jsFuncScript completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"+++++WKWebview执行js：%@",jsFuncScript);
    }];
    //JS通过webview中window.webkit.messageHandlers回调OC中定义的函数
    jsFuncScript = [NSString stringWithFormat:@"window.webkit.messageHandlers.%@.postMessage('This is a param!');",NativeFunc_Hello];
    [_mWKWebview evaluateJavaScript:jsFuncScript completionHandler:^(id result, NSError * error) {
        NSLog(@"+++++WKWebview执行js：%@",jsFuncScript);
    }];
}

//web视图导航过程中发生错误
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(nonnull NSError *)error
{
    /*导航错误：NSURLErrorDomain Code=-999
     原因：webview 的上一个请求还没有加载完成，下一个请求发起了，此时 webview 会取消掉之前的请求，因此会回调导航失败错误（NSURLErrorCancelled = -999）。
     */
}

//web视图加载内容时发生错误
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
}

//当web content处理完成时，会回调
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
}

//接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"++++++地址重定向");
}


#pragma mark -WKUIDelegate

//为html的alert弹窗，提供iOS版的 UIAlert视图
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告"
                                                                   message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"我知道了"
                                                 style:(UIAlertActionStyleDefault)
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   completionHandler();
                                               }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

//为html的confirm弹窗，提供iOS版的 UIAlert视图
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择"
                                                                   message:message
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"同意"
                                                 style:(UIAlertActionStyleDefault)
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   completionHandler(YES);
                                               }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"不同意"
                                                     style:(UIAlertActionStyleCancel)
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       completionHandler(NO);
                                                   }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * _Nullable result))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入"
                                                                   message:prompt
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入";
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定"
                                                 style:(UIAlertActionStyleDefault)
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   UITextField *tf = [alert.textFields firstObject];
                                                   completionHandler(tf.text);
                                               }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:(UIAlertActionStyleCancel)
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       completionHandler(defaultText);
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma -mark KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        [_mProgressView setProgress:progress];
        if (progress == 1.0) {
            NSLog(@"++++WKWebview加载完成");
        }
    }
}

#pragma -mark BUSINESS
- (void)setUps
{
    _mWKWebview.navigationDelegate = self;
    _mWKWebview.UIDelegate = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:@"https://www.baidu.com"]];
    
    //WKUserScript用于往加载的页面中添加额外需要执行的JavaScript代码
    //设置cookie
    NSString *jsStr = [NSString stringWithFormat:@"alert(\"WKUserScript注入js\");"];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:jsStr
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart //js加载前执行
                                               forMainFrameOnly:NO];
    /*
     WKUserScriptInjectionTimeAtDocumentStart : 注入时机为document的元素生成之后,其他内容load之前.
     WKUserScriptInjectionTimeAtDocumentEnd : 注入时机为document全部load完成,任意子资源load完成之前.
     */
    [_mWKWebview.configuration.userContentController addUserScript:script];
    [_mWKWebview loadRequest:request];
    _mScriptMessHandler = [UOWKScriptMessageHandler new];
    //向webview注入脚本的OC回调
    [_mWKWebview.configuration.userContentController addScriptMessageHandler:_mScriptMessHandler name:NativeFunc_Hello];
    
    [_mWKWebview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
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

- (void)removeMessageHandler
{
    //离开时调用 否则会造成内存泄漏
    _mScriptMessHandler = nil;
    [_mWKWebview removeObserver:self forKeyPath:@"estimatedProgress"];
    [_mWKWebview.configuration.userContentController removeScriptMessageHandlerForName:NativeFunc_Hello];
}
@end
