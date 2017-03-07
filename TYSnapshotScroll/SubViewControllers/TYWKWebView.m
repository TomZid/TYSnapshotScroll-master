//
//  TYWKWebView.m
//  TYSnapshotScroll
//
//  Created by apple on 16/12/27.
//  Copyright © 2016年 TonyReet. All rights reserved.
//

#import "TYWKWebView.h"
#import "TYSnapshot.h"

@interface TYWKWebView () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) UIButton *button;

@end

@implementation TYWKWebView

-(WKWebView* )webView{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.bounces = NO;
        _webView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (void )buttonInit
{
    if (!self.button) {
        CGFloat buttonW = 120;
        CGFloat buttonH = 50;
        CGFloat buttonX = (TYSnapshotMainScreenBounds.size.width - buttonW)/2;
        CGFloat buttonY = TYSnapshotMainScreenBounds.size.height - 2*buttonH;
        CGRect buttonFrame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        
        self.button = [[UIButton alloc] initWithFrame:buttonFrame];
        [self.view addSubview:self.button];
        [self.view bringSubviewToFront:self.button];
        self.button.layer.masksToBounds = YES;
        self.button.layer.cornerRadius = buttonW*0.05;
        self.button.backgroundColor = [UIColor redColor];
        
        
        self.button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.button setTitle:@"保存网页为图片" forState:UIControlStateNormal];
        [self.button addTarget:self action:@selector(snapshotBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadWebView];
    [self buttonInit];
}

- (void)loadWebView{
    NSString *urlStr = @"http://vpass.vipabc.com:8080/vipjr/mysession/comments/dist/view/src/consultant_comments.html?brandId=4&clientSn=3449193&lang=zh-cn&sessionSn=2017020108081892&token=11a4992598324e853916b7b4f9e6458b&consultantSn=14293&consultantName=Melina%20Moriel&childName=Niki%20Cao&sessionType=6&sessionNameCN=This%20and%20That&sessionNameEN=This%20and%20That&sharemode=1&lng=zh-cn&from=singlemessage&isappinstalled=0";//@"https://github.com/TonyReet/TYSnapshotScroll/blob/master/README.md";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];//超时时间5秒
    
    //加载地址数据
    [self.webView loadRequest:request];
}

- (void)snapshotBtn:(UIButton *)sender
{
    __weak typeof(self) ws = self;
    [self showQRC:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TYSnapshot screenSnapshot:self.webView finishBlock:^(UIImage *snapShotImage) {
                //保存相册
                UIImageWriteToSavedPhotosAlbum(snapShotImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                [self.button setTitle:@"保存到相册,请稍后" forState:UIControlStateNormal];
                [ws hideQRC:nil];
            }];
        });
    }];
    /*
    [TYSnapshot screenSnapshot:self.webView finishBlock:^(UIImage *snapShotImage) {
        //保存相册
        UIImageWriteToSavedPhotosAlbum(snapShotImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        [self.button setTitle:@"保存到相册,请稍后" forState:UIControlStateNormal];
    }];
     */
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self.button setTitle:@"保存网页为图片" forState:UIControlStateNormal];
    
   
    if (error == nil) {
        NSLog(@"-------保存成功---------");
    }else{
        NSLog(@"-------保存失败---------");
    }
}

- (void)showQRC:(void(^)())handle {
    [self runJS:NO handle:handle];
}

- (void)hideQRC:(void(^)())handle {
    [self runJS:YES handle:handle];
}

- (void)runJS:(BOOL)hidded handle:(void(^)())handle {
    NSString *jsStr = [NSString stringWithFormat:@"document.getElementsByClassName(\"qrcode-layout\")[0].style.display=\"%@\";", hidded ? @"none" : @"block"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (handle) {
            handle();
        }
    }];
}

# pragma mark - WKUIDelegate, WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
//    [webView evaluateJavaScript:[NSString stringWithFormat:@"document.readyState"] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        NSString *stateStr = (NSString*)response;
//        if ([stateStr isEqualToString:@"complete"]) {
//            self.button.enabled = YES;
//        }
//    }];
    
//    //隐藏
    [self hideQRC:nil];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

@end
