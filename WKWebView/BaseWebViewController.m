//
//  BaseWebViewController.m
//  BusinessiOS
//
//  Created by cguo on 2017/7/28.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import "BaseWebViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"
#import "OCJSTool.h"
#import "TZImagePickerController.h"
#import "MapViewController.h"
#import "AFNetworking.h"
#import "HttpTool.h"
#import "LocationTool.h"
#import "ViewController.h"
#import "GetPhotoTool.h"
#import "PhotoModel.h"
#import "DateView.h"
#import "SVProgressHUD.h"
#import "NSString+Extension.h"

#import "UIColor+Extension.h"



@interface BaseWebViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate,TZImagePickerControllerDelegate,GetPhotoToolDelegate>
{
  
}

@property(nonatomic,strong)WKWebView *wkWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property(nonatomic,strong)WKWebViewJavascriptBridge *bridge;
@property(nonatomic,strong)OCJSTool *OJTool;

@property(nonatomic,strong)LocationTool *locaTool;
@property(nonatomic,strong)  BMKLocationService *LocationService;

@property(nonatomic,strong)UIImageView *bgImageView;
@property(nonatomic,strong)GetPhotoTool *photoTool;

@property(nonatomic,strong)NSString *cookie;
//状态栏的viwe
@property(nonatomic,strong)UIView *BarView;
@end

@implementation BaseWebViewController

-(OCJSTool *)OJTool
{
    if (_OJTool==nil) {
        _OJTool=[[OCJSTool alloc]initWithDelegate:(id)self withVc:self];
    }
    return _OJTool;
}

-(GetPhotoTool *)photoTool
{
    if (_photoTool==nil) {
        _photoTool=[[GetPhotoTool alloc]initWithImagePickerController:(id)self withDelegate:self];
    }
    return _photoTool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setBaseWebView];
    self.view.backgroundColor=[UIColor whiteColor];
       [self setBarView];

    
    [self setBGView];

    
 

}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)setBGView
{
    
   
     self.bgImageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
     self.bgImageView.image=[UIImage imageNamed:@"BeginImage"];
    [self.view addSubview:self.bgImageView];
    [self.view bringSubviewToFront:self.bgImageView];

   
    //
    //    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    //
    //    btn.backgroundColor=[UIColor redColor];
    //    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchDown];
    //
    //    [self.view addSubview:btn];
}
#pragma mark--状态栏的颜色
-(void)setBarView
{
    self.BarView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    self.BarView.backgroundColor=[UIColor colorWithhexString:@"#2887E0"];

    [self.view addSubview:self.BarView];
}




-(void)setBaseWebView
{
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    
    WKPreferences *preferences = [[WKPreferences alloc]init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 18.0;
    config.preferences = preferences;
    
    
   
     // 你所保存的cookie值------这样即可解决一个url内部多个跳转，cookie仍能保存的问题。
//     NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"cookie"];
//     NSString *cookie = [NSString stringWithFormat:@"%@=%@", [dic valueForKey:@"key"], [dic valueForKey:@"value"]];
//     WKUserContentController *userContentController = WKUserContentController.new;
//     WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource: [NSString stringWithFormat:@"document.cookie = '%@';", cookie] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//     [config.userContentController addUserScript:cookieScript];
//     WKWebViewConfiguration* webViewConfig = WKWebViewConfiguration.new;
//     webViewConfig.userContentController = userContentController;
//    NSString *JiaThis=[NSString stringWithFormat:@"<!-- JiaThis Button BEGIN --><div class=\"jiathis_style_m\"></div><script type=\"text/javascript\"src=\"http://v3.jiathis.com/code/jiathis_m.js\" charset=\"utf-8\"></script><!-- JiaThis Button END -->"];
//    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:JiaThis injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//    [config.userContentController addUserScript:cookieScript];
//    //创建脚本
//    WKUserScript *cookieScript2 = [[WKUserScript alloc] initWithSource:@"alert(document.cookie);" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    //添加脚本
//    [config.userContentController addUserScript:cookieScript2];
    

    
    
    self.wkWebView=[[WKWebView alloc]initWithFrame:CGRectMake(0, 20,ScreenWidth , ScreenHeight-20) configuration:config];
//    [config.userContentController addScriptMessageHandler:self name:@"takePictures"];
//    [config.userContentController addScriptMessageHandler:self name:@"getPictures"];
//    [config.userContentController addScriptMessageHandler:self name:@"getLocation"];
//    [config.userContentController addScriptMessageHandler:self name:@"testJavascriptHandler"];
    
    

    [self.view addSubview:self.wkWebView];
   

    //设置代理
    self.wkWebView.UIDelegate=self;
    self.wkWebView.navigationDelegate=self;
    // 开始右滑返回手势
    self.wkWebView.allowsBackForwardNavigationGestures = YES;
    self.wkWebView.scrollView.bounces = false;
    
    //用心寻味H5链接 http://ms.yonxin.com/index.php?app=h5&from=singlemessage&isappinstalled=1#/home/all?_k=ficd4d
    //用心工匠微信端链接  http://1q73j94451.iok.la/Service/HomePage

//淘宝：http://h5.m.taobao.com/moshtml
    
//  明涛测试  http://172.16.35.46:6688/Mobile/Login
    //海涛测试  http://172.16.38.42:8085/Mobile/Login

//    [request addValue:@"skey=skeyValue" forHTTPHeaderField:@"Cookie"];
//        NSURL *loadUrl=[NSURL URLWithString:@"http://172.16.38.42:8085/Mobile/Login"];
  
//    NSURL *loadUrl=[NSURL URLWithString:@"http://172.16.38.68:3000/46-demo.html"];
//        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:loadUrl]];

//    NSURL *loadUrl=[NSURL URLWithString:@"http://192.168.64.2/test6.html"];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:HostURL]];
    [self.wkWebView loadRequest:request];
//

    
    
//    //设置进度条
//    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 2)];
//    [self.view addSubview:self.progressView];
//    self.progressView.progressTintColor = [UIColor greenColor];
//    self.progressView.trackTintColor = [UIColor clearColor];
    
    // KVO 监听属性，除了下面列举的两个，还有其他的一些属性，具体参考 WKWebView 的头文件
//    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];//进度条
    [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
//    [self.wkWebView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    
    // 监听 self.webView.scrollView 的 contentSize 属性改变，从而对底部添加的自定义 View 进行位置调整
//    [self.wkWebView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    


    //第三方设置JS与OC交互的桥梁
    self.bridge=[WKWebViewJavascriptBridge bridgeForWebView:self.wkWebView];
    //    //设置代理，否则不会响应相关的代理方法
    [self.bridge setWebViewDelegate:self];
    //
    [self AddBridgeJSandOC];
    
  
 
}
-(void)SetHtmlDate
{
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"test6" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.wkWebView loadHTMLString:appHtml baseURL:baseURL];
}

-(void)AddBridgeJSandOC
{
//    __weak typeof(self)weakself=self;
    
  
    
    [self.bridge registerHandler:@"takePictures" handler:^(id data, WVJBResponseCallback responseCallback) {
       
        NSLog(@"拍照");
        [self ToPhoneController];

//        NSURL *loadUrl=[NSURL URLWithString:@"http://ms.yonxin.com/index.php?app=h5&from=singlemessage&isappinstalled=1#/home/all?_k=ficd4d"];
//         NSURL *loadUrl = [[NSBundle mainBundle] URLForResource:@"ExampleApp" withExtension:@"html"];
//        
//        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:loadUrl]];
        //相关的调用的方法，进行相关的操作
        
        //把结果回调回去，参数可以是字典后数组
//        NSString *str=@"回调回去的参数";
//        responseCallback(str);
    }];
    
    [self.bridge registerHandler:@"sendRegisterID" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"回传reginstID");
        
        NSString *registerID=[[NSUserDefaults standardUserDefaults]objectForKey:@"registerID"];
         responseCallback(registerID);
//       [self ToMapViewController];
//        NSString *scanResult = @"http://www.baidu.com";
//        responseCallback(scanResult);
        //相关的调用的方法，进行相关的操作
        
        //把结果回调回去，参数可以是字典后数组
        //        NSString *str=@"回调回去的参数";
//                responseCallback(str);
    }];
    
    [self.bridge registerHandler:@"getPictures" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"选择图片");
        responseCallback(@"回调选择的图片");
//        
//        UIDatePicker*pickerDate=[[UIDatePicker alloc]init];
//        pickerDate.datePickerMode=UIDatePickerModeDate;
//        DateView *dateView=[[DateView alloc]initDateViewWithFrame:CGRectMake(0, ScreenHeight-250, ScreenWidth, 250) WithdatePicker:pickerDate];
//        dateView.setChooseDateblock=^(NSString *dateStr,NSDate *date)
//        {
//            NSLog(@"%@",dateStr);
//            NSLog(@"%@",date);
//        };
//        [self.view addSubview:dateView];


//        NSString *scanResult = @"http://www.baidu.com";
//        responseCallback(scanResult);
        //相关的调用的方法，进行相关的操作
        
        //把结果回调回去，参数可以是字典后数组
        //        NSString *str=@"回调回去的参数";
        //        responseCallback(str);
    }];
    
    [self.bridge registerHandler:@"getLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"选择位置");
        self.LocationService=[[BMKLocationService alloc]init];
        self.locaTool=[LocationTool LocationDelegateWithManager:self.LocationService LocationBlock:^(BMKUserLocation *userLocation) {
            NSLog(@"%.10f",userLocation.location.coordinate.longitude);
            
            responseCallback(@{@"经度":@(userLocation.location.coordinate.latitude),@"纬度":@(userLocation.location.coordinate.longitude)});
        }];
        
        self.LocationService.delegate=self.locaTool;
    }];
    
    [self.bridge registerHandler:@"sendTagAlia" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"其他的一些设置");
        responseCallback(@"其他的一些设置");
    }];

    
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    NSLog(@"createWebViewWithConfiguration  request     %@",navigationAction.request);
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
        
    }
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

-(void)setDate
{

    UIDatePicker *picker=(UIDatePicker*)[self.view viewWithTag:1];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
    NSLog(@"%@", [formatter stringFromDate:picker.date]);
    [picker removeFromSuperview];
    
    [[self.view viewWithTag:2] removeFromSuperview];
 
}

#pragma mark--当有js事件响应时调用该方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:message.body];
    NSLog(@"JS交互参数：%@", dic);
    
    if ([message.name isEqualToString:@"word"] && [dic isKindOfClass:[NSDictionary class]]) {
        
        NSLog(@"currentThread  ------   %@", [NSThread currentThread]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *code = dic[@"code"];
            if ([code isEqualToString:@"0001"]) {
         
//                [self ToPhoneController];
//                [self ToMapViewController];
                
                NSString *js = [NSString stringWithFormat:@"globalCallback(\'%@\')", @"该设备的deviceId: *****"];
                [self.wkWebView evaluateJavaScript:js completionHandler:nil];
                
            } else {
                return;
            }
        });
    } else {
        return;
    }
}
-(void)ToMapViewController
{
    
    MapViewController *mapVC=[[MapViewController alloc]init];
    
    [self presentViewController:mapVC animated:YES completion:nil];
}

#pragma mark-- 当控制器消失时需要移除监听
- (void)dealloc {
     NSLog(@"消除的方法");
    
    
//    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView removeObserver:self forKeyPath:@"title"];
//    [self.wkWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
    //    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"timefor"];

    
    
}

#pragma mark-- 监听key值的变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
//    if ([keyPath isEqualToString:@"estimatedProgress"]) {
////        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:YES];
//        if (self.wkWebView.estimatedProgress < 1.0) {
////            self.delayTime = 1 - self.wkWebView.estimatedProgress;
//            NSLog(@"%lf",self.wkWebView.estimatedProgress);
//            return;
//        }
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            self.progressView.progress = 0;
////        });
//    } else
    //当webview内存暴增并出现白屏时，刷新页面
    if ([keyPath isEqualToString:@"title"]) {
        self.title = self.wkWebView.title;
        if (self.wkWebView.title.length==0 ||self.wkWebView.title==nil) {
//            [self.wkWebView reload];
        }
    }
    if ([keyPath isEqualToString:@"loading"]) {
        if (self.wkWebView.loading) {
            NSLog(@"正在加载");
        }else
        {
            NSLog(@"没有在加载");
        }
    }
//    } else if ([keyPath isEqualToString:@"contentSize"]) {
////        if (self.contentHeight != self.webView.scrollView.contentSize.height) {
////            self.contentHeight = self.webView.scrollView.contentSize.height;
////            self.addView.frame = CGRectMake(0, self.contentHeight - addViewHeight, ScreenWidth, addViewHeight);
//            NSLog(@"----------%@", NSStringFromCGSize(self.wkWebView.scrollView.contentSize));
////        }
//    }

}


#pragma mark - WKNavigationDelegate

// 开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    NSLog(@"didStartProvisionalNavigation   ====    %@", navigation);
      [self.bgImageView removeFromSuperview];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
//    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//         [SVProgressHUD dismiss];
//    });
    
}

// 页面加载完调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.bgImageView removeFromSuperview];
//            
//        });
//    });
   
      [SVProgressHUD dismiss];

    NSLog(@"didFinishNavigation   ====    %@", navigation);
 



    //    NSString *JSStr=[NSString stringWithFormat:@"<!-- UY BEGIN --><div id=\"uyan_frame\"></div><script type=\"text/javascript\" src=\"http://v2.uyan.cc/code/uyan.js\"></script><!-- UY END -->"];
//    NSString *JiaThis=[NSString stringWithFormat:@"<!-- JiaThis Button BEGIN --><div class=\"jiathis_style_m\"></div><script type=\"text/javascript\"src=\"http://v3.jiathis.com/code/jiathis_m.js\" charset=\"utf-8\"></script><!-- JiaThis Button END -->"];
//

////    NSString *js = [NSString stringWithFormat:@"testJavascriptHandler(\'%@\')", @"参数"];
//    [self.wkWebView evaluateJavaScript:strJS completionHandler:^(id _Nullable responseData, NSError * _Nullable error) {
//        NSLog(@"回调--%@---%@",responseData,error);
//    }];
//    调用JS的方法----OpenBox----setupWebViewJavascriptBridge
//    NSString *OCTojs=[NSString stringWithFormat:@"setupWebViewJavascriptBridge"];
//    [self.wkWebView evaluateJavaScript:OCTojs completionHandler:^(id _Nullable requstRelust, NSError * _Nullable error) {
//        NSLog(@"%@",error);
//    }];
    
    

    
    /*
    if (!showAddView) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.wkWebView.scrollView addSubview:self.addView];
        
           });
    */
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation   ====    %@\nerror   ====   %@", navigation, error);
}

// 内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"didCommitNavigation   ====    %@", navigation);
  

}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationAction   ====    %@", navigationAction);
   
    NSLog(@"跳转链接%@", navigationAction.request.URL);
    //    //如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
//    if (!navigationAction.targetFrame.isMainFrame) {
//        [webView loadRequest:navigationAction.request];
//        
//    }

    //获取跳转的URL
//    NSString *urlStr=[navigationAction.request.URL.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
//    NSLog(@"%@",urlStr);
//    
//    if ([urlStr isEqualToString:@"http://www.baidu.com/"]) {
//        ViewController *vc=[[ViewController alloc]init];
//        vc.urlStr=urlStr;
////        [self.navigationController pushViewController:view animated:YES];
//           [self presentViewController:vc animated:YES completion:nil];
//    }
//  

    /*
     一个网页嵌套多个点击方法，可以实现cookie的保存和存值
     
     NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"cookie"];
     NSString *cookie = [NSString stringWithFormat:@"%@=%@", [dic valueForKey:@"key"], [dic valueForKey:@"value"]];
     // 如果请求头部不包含cookie值则需要我们去传cookie
     if ([navigationAction.request allHTTPHeaderFields][@"Cookie"] && [[navigationAction.request allHTTPHeaderFields][@"Cookie"] rangeOfString:cookie].length > 0) {
     decisionHandler(WKNavigationActionPolicyAllow);
     } else {
     NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:navigationAction.request.URL];
     [request setValue:cookie forHTTPHeaderField:@"Cookie"];
     [webView loadRequest:request];
     decisionHandler(WKNavigationActionPolicyCancel);
     }
     */
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"%@",webView.URL);
  
}

#pragma mark--在这个方法中获取cookie
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationResponse   ====    %@", navigationResponse);
     NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
//    NSArray *cookieArr=[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:response.URL];


    NSString *str=[NSString stringWithFormat:@"%@",response.URL];
    if ([str hasPrefix:@"http://s.yonxin.com"]) {
        NSLog(@"%@",response.URL);
    
           NSArray *cookieArr=[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:response.URL];
        NSData *cookieData=[NSKeyedArchiver archivedDataWithRootObject:cookieArr];
        NSLog( @"%@",cookieData);

    }
   
    
    NSLog(@"%@",response.URL);
   


    
     if (self.cookie == nil) {
//     NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
     NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
//     读取wkwebview中的cookie
     for (NSHTTPCookie *cookie in cookies) {
//      这里就是你需要的cookie
         NSLog(@"%@",cookie);
     }
     
     }
  
    decisionHandler(WKNavigationResponsePolicyAllow);
}



// 加载 HTTPS 的链接，需要权限认证时调用  \  如果 HTTPS 是用的证书在信任列表中这不会此代理方法
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}





#pragma mark - WKUIDelegate

// 提示框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示框" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认框" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入框" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
        textField.placeholder = defaultText;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}



-(void)btnClick
{
    
    ViewController *vc=[[ViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
    
    /*
     id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
     [self.bridge callHandler:@"testJavascriptHandler" data:@"一个字符串" responseCallback:^(id response) {
     NSLog(@"testJavascriptHandler responded: %@", response);
     }];
     //    // 如果不需要参数，不需要回调，使用这个
     //    [_webViewBridge callHandler:@"testJSFunction"];
     //    // 如果需要参数，不需要回调，使用这个
     //    [_webViewBridge callHandler:@"testJSFunction" data:@"一个字符串"];
     // 如果既需要参数，又需要回调，使用这个
     //    [self.bridge callHandler:@"testJSFunction" data:@"一个字符串" responseCallback:^(id responseData) {
     //        NSLog(@"调用完JS后的回调：%@",responseData);
     //    }];
     
     
     //    NSString *jsStr=[NSString stringWithFormat:@"testJavascriptHandler(\'%@\')",@""];
     //    NSString *js = [NSString stringWithFormat:@"testJavascriptHandler(\'%@\')", @"参数"];
     //    [self.wkWebView evaluateJavaScript:@"testJavascriptHandler" completionHandler:^(id _Nullable responseData, NSError * _Nullable error) {
     //        NSLog(@"回调--%@--error%@",responseData,error);
     //    }];
     //
     NSString *JS=[NSString stringWithFormat:@"function popConfirmPanel() {var ok = confirm(\"确认框\");}"];
     
     [self.wkWebView evaluateJavaScript:JS completionHandler:^(id _Nullable requstJson, NSError * _Nullable error) {
     NSLog(@"完成--%@",error);
     }];
     
     //      [self.bridge callHandler:JS];
     [self.wkWebView evaluateJavaScript:@"popConfirmPanel()" completionHandler:^(id _Nullable requstJson, NSError * _Nullable error) {
     NSLog(@"完成--%@",error);
     }];
     */
}


#pragma mark 选择图片相关
-(void)PostImage:(UIImage*)image
{
    
    [HttpTool uploadWithURL:@"http://172.16.35.58:8080/PostImage.php" parameters:nil images:@[image] name:@"picture_name" fileName:@"image" mimeType:@"jpeg" progress:^(NSProgress *progress) {
        NSLog(@"%@",progress);
    } success:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    //    // 获得网络管理者
    //    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //
    //    // 设置请求参数
    //    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //
    //    [manager POST:@"http://172.16.35.58:8080/index.php" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    //
    //        // 获取图片数据
    //        NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
    //
    //        // 设置上传图片的名字
    //        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //        formatter.dateFormat = @"yyyyMMddHHmmss";
    //        NSString *str = [formatter stringFromDate:[NSDate date]];
    //        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
    //
    //        [formData appendPartWithFileData:fileData name:@"image" fileName:fileName mimeType:@"image/png"];
    //
    //    } progress:^(NSProgress * _Nonnull uploadProgress) {
    //        NSLog(@"%@", uploadProgress);
    //    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    //        // 返回结果
    //        NSLog(@"%@", responseObject[@"datas"]);
    //    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    //        NSLog(@"%@", error);
    //    }];
}

-(void)ToPhoneController
{
    
    TZImagePickerController *imageController=[[TZImagePickerController alloc]initWithMaxImagesCount:4 delegate:self];
    
    [imageController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photoArr, NSArray *PHAsset, BOOL scor) {
        
        NSLog(@"%@---%@",photoArr,PHAsset);
        
        
        NSMutableArray *modelArr=[PhotoModel GetPhotoModelArrByPHAssetArr:PHAsset imageSize:CGSizeMake(0, 0)];
        //        for (PhotoModel *model in modelArr) {
        //            NSLog(@"%ld",model.imageData.length);
        //        }
        
        [HttpTool uploadWithURL:@"http://baidu.com" parameters:nil imageModels:modelArr progress:^(NSProgress *progress) {
            NSLog(@"%@",progress);
        } success:^(id responseObject) {
            NSLog(@"%@",responseObject);
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
    }];
    
    [self presentViewController:imageController animated:YES completion:nil];
    //    self.photoTool.block=^(NSArray *photoArr,NSArray *PHAsset)
    //    {
    //        NSLog(@"%@---%@",photoArr,PHAsset);
    //
    //
    //        NSMutableArray *modelArr=[PhotoModel GetPhotoModelArrByPHAssetArr:PHAsset imageSize:CGSizeMake(0, 0)];
    ////        for (PhotoModel *model in modelArr) {
    ////            NSLog(@"%ld",model.imageData.length);
    ////        }
    //
    //        [HttpTool uploadWithURL:@"http://baidu.com" parameters:nil imageModels:modelArr progress:^(NSProgress *progress) {
    //            NSLog(@"%@",progress);
    //        } success:^(id responseObject) {
    //            NSLog(@"%@",responseObject);
    //        } failure:^(NSError *error) {
    //            NSLog(@"%@",error);
    //        }];
    //        NSString *fileName=photoArr
    //        [HttpTool uploadWithURL:@"" parameters:nil images:photoArr name:@"image" fileName:<#(NSString *)#> mimeType:<#(NSString *)#> progress:<#^(NSProgress *progress)progress#> success:<#^(id responseObject)success#> failure:<#^(NSError *error)failure#>]
    //    };
    //    self.photoTool=[[GetPhotoTool alloc]initWithImagePickerController:imageController finishBlock:^(NSArray *photoArr) {
    //
    //        NSLog(@"%@",photoArr);
    //    }];
    //
    //    imageController.delegate=self.photoTool;
    
    
    
    
}
//隐藏图片选择完成后的代理
/*
 - (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
 {
 NSLog(@"%ld",photos.count);
 NSLog(@"%ld",assets.count);
 //    NSString *js = [NSString stringWithFormat:@"globalCallback(\'%@\')", @"该设备的deviceId: *****"];
 
 [self PostImage:photos.firstObject];
 
 NSString *OCTojs=[NSString stringWithFormat:@"popAlertPanel()"];
 [self.wkWebView evaluateJavaScript:OCTojs completionHandler:nil];
 }
 */
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
    [UIApplication sharedApplication].statusBarHidden=NO;
    if(![NSString isEmpty:self.wkWebView.title])
    
        NSLog(@"webview的标题-----%@",self.wkWebView.title);
}


@end
