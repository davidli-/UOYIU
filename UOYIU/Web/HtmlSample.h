//
//  HtmlSample.h
//  UOYIU
//
//  Created by Macmafia on 2019/1/7.
//  Copyright © 2019 Macmafia. All rights reserved.
//

#ifndef HtmlSample_h
#define HtmlSample_h


#endif /* HtmlSample_h */
/*
 <!DOCTYPE html>
 <html lang="en">
 <head>
 <meta charset="UTF-8">
 <title>App与WebView交互</title>
 </head>
 <body>
 <button style="width: 100%; height: 100px;" onclick="buttonClick()">点击购买</button>
 </body>
 <script>
 //按钮点击事件
 function buttonClick() {
 //传递的信息
 var jsonStr = '{"id":"666", "message":"我是传递的数据"}';
 
 //UIWebView使用
 getMessage(jsonStr);
 
 //WKWebView使用
 //使用下方方法,会报错,为使界面执行逻辑通畅,因此使用try-catch
 try {
 window.webkit.messageHandlers.getMessage.postMessage(jsonStr)
 } catch(error) {
 console.log(error)
 }
 }
 function getMessage(json){
 //空方法
 }
 </script>
 </html>
 */
