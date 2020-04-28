//
//  ViewController.m
//  OCCallJS
//
//  Created by ZH on 2019/4/9.
//  Copyright © 2019 张豪. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong)WKWebView *wkWeb;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.wkWeb = [[WKWebView alloc]initWithFrame:CGRectMake(20, 60, self.view.bounds.size.width - 40, 400)];
    self.wkWeb.backgroundColor = [UIColor redColor];
    self.wkWeb.UIDelegate = self;
    self.wkWeb.navigationDelegate = self;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"aaaaaa" withExtension:@"html"];
    [self.wkWeb loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:self.wkWeb];
    
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"开始加载页面");
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"有内容返回");
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"页面加载完成");
    NSDictionary *dic = @{@"a":@"1",@"b":@"2"};
    NSString *jsonStr = [self convertToJsonData:dic];
    NSLog(@"jsonStr---%@", jsonStr); // 如果有多个参数就转成json字符串传给h5
    
    //    NSString *parStr = @"dicstr";
    NSString * jsStr = [NSString stringWithFormat:@"func1('%@')",jsonStr];
    
    
    NSLog(@"jsStr--%@", jsStr);
    [self.wkWeb evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"结果-%@,错误--%@", result, error);
    }];
    
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"页面加载失败, 原因是--%@", error);
    
}

#pragma mark - WKUIDelegate, 如果有alert弹窗的话, 点击就会调用这个代理方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // 打印出"我是弹窗1", 就说明成功调用了JS里面的func1方法
    NSLog(@"点击了有alert的弹窗, 弹窗内容是---%@", message); // 这里获取到的messge就是html里面的window.alert内容
    // 下面判断到底是点了那个html的按钮就根据window.alert的内容进行判断就行
//    if ([message isEqualToString:@"我是弹窗1"]) {
//
//    }
    completionHandler();
}

// 字典转json
-(NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    // 去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

@end
