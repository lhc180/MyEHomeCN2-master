//
//  MyEQRScanViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-3.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEQRScanViewController.h"

@interface MyEQRScanViewController (){
    ZBarReaderView *readerView;
}

@end
#define viewWidth self.view.bounds.size.width

#define viewHight self.view.bounds.size.height

@implementation MyEQRScanViewController


#pragma mark - life circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat width = IS_IPAD?400.0f:200.0f;
    //针对不同设备进行二维码界面的优化
    UIView *top,*left,*right,*bottom;
    top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHight/2-width/2)];
    left = [[UIView alloc] initWithFrame:CGRectMake(0, viewHight/2-width/2, viewWidth/2-width/2, width)];
    right = [[UIView alloc] initWithFrame:CGRectMake(viewWidth/2+width/2, viewHight/2-width/2, viewWidth/2-width/2, width)];
    bottom = [[UIView alloc] initWithFrame:CGRectMake(0, viewHight/2+width/2, viewWidth, viewHight/2 - width/2)];
//    if (IS_IPHONE5) {
//        if (IS_IOS6) {
//            top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 148)];
//            left = [[UIView alloc] initWithFrame:CGRectMake(0, 148, 60, 200)];
//            right = [[UIView alloc] initWithFrame:CGRectMake(260, 148, 60, 200)];
//            bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 348, 320, 200)];
//        }else{
//            top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 158)];
//            left = [[UIView alloc] initWithFrame:CGRectMake(0, 158, 60, 200)];
//            right = [[UIView alloc] initWithFrame:CGRectMake(260, 158, 60, 200)];
//            bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 358, 320, 210)];
//        }
//    }else{
//        if (IS_IOS6) {
//            top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 104)];
//            left = [[UIView alloc] initWithFrame:CGRectMake(0, 104, 60, 200)];
//            right = [[UIView alloc] initWithFrame:CGRectMake(260, 104, 60, 200)];
//            bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 304, 320, 156)];
//        }else{
//            top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 114)];
//            left = [[UIView alloc] initWithFrame:CGRectMake(0, 114, 60, 200)];
//            right = [[UIView alloc] initWithFrame:CGRectMake(260, 114, 60, 200)];
//            bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 314, 320, 166)];
//        }
//    }
    UIColor *bgColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    top.backgroundColor = bgColor;
    left.backgroundColor = bgColor;
    right.backgroundColor = bgColor;
    bottom.backgroundColor = bgColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"请将二维码置于扫描框正中间";
    label.font = [UIFont systemFontOfSize:13];
    [label sizeToFit];
    label.center = CGPointMake(viewWidth/2, viewHight/2 + width/2 + 20);
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"开启闪光灯" forState:UIControlStateNormal];
    [btn setTitle:@"关闭闪光灯" forState:UIControlStateSelected];
    [btn setTitleColor:MainColor forState:UIControlStateNormal];
    [btn setTitleColor:NavBarColor forState:UIControlStateSelected];
    [btn sizeToFit];
    btn.center = CGPointMake(viewWidth/2, viewHight/2 + width/2 + 70);
    [btn addTarget:self action:@selector(doThis:) forControlEvents:UIControlEventTouchUpInside];
    
    readerView = [ZBarReaderView new];
    readerView.frame = self.view.bounds;
    readerView.readerDelegate = self;
    readerView.torchMode = 0;
    readerView.trackingColor = [UIColor redColor];
//    NSLog(@"readerView Frame is  %f %f %f %f",readerView.frame.origin.x,readerView.frame.origin.y,readerView.frame.size.width,readerView.frame.size.height);
//    NSLog(@"readerView ScanCrop is  %f %f %f %f",readerView.scanCrop.origin.x,readerView.scanCrop.origin.y,readerView.scanCrop.size.width,readerView.scanCrop.size.height);
    //扫描区域
//    CGRect scanMaskRect = CGRectMake(60, CGRectGetMidY(readerView.frame)-126, 200, 200);
    CGRect scanMaskRect = CGRectMake(screenwidth/2-width/2, screenHigh/2-width/2, width, width);

//    NSLog(@"scanMaskRect  is %f %f %f %f",scanMaskRect.origin.x,scanMaskRect.origin.y,scanMaskRect.size.width,scanMaskRect.size.height);
    
    //处理模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        ZBarCameraSimulator *cameraSimulator
        = [[ZBarCameraSimulator alloc]initWithViewController:self];
        cameraSimulator.readerView = readerView;
    }
    [readerView addSubview:top];
    [readerView addSubview:left];
    [readerView addSubview:right];
    [readerView addSubview:bottom];
    [readerView addSubview:label];
    if (!IS_IPAD) {
        [readerView addSubview:btn];
    }
    [self.view addSubview:readerView];
    //扫描区域计算
    readerView.scanCrop = [self getScanCrop:scanMaskRect readerViewBounds:readerView.bounds];
    UIView *view = [[UIView alloc] initWithFrame:readerView.scanCrop];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    [readerView start];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ZBarReaderViewDelegate
//确定扫描区域
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x = rect.origin.x / readerViewBounds.size.width;
    y = rect.origin.y / readerViewBounds.size.height;
    width = rect.size.width / readerViewBounds.size.width;
    height = rect.size.height / readerViewBounds.size.height;

//    NSLog(@"%f %f",readerViewBounds.size.width,readerViewBounds.size.height);
//    NSLog(@"%f  %f  %f  %f",x,y,width,height);
    return CGRectMake(x, y, width, height);
}
- (void)readerView:(ZBarReaderView *)reader didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"beep-beep" ofType:@"aiff"];
    NSURL *soundUrl=[[NSURL alloc] initFileURLWithPath:soundPath];
    AVAudioPlayer *player=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [player play];
    for (ZBarSymbol *symbol in symbols) {
        NSLog(@"%@", symbol.data);
        if (self.isAddCamera) {
            [self.delegate passCameraUID:symbol.data];
            break;
        }
        if ([symbol.data length] == 30) {
            [self.delegate passMID:[symbol.data substringToIndex:23] andPIN:[symbol.data substringFromIndex:24]];
         }else{
            [MyEUtil showMessageOn:nil withMessage:@"请扫描智能网关背后的二维码"];
        }
        break;
    }
    [reader stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - private methods
- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action
-(void)doThis:(UIButton *)btn{
    btn.selected = !btn.selected;
    readerView.torchMode = btn.selected;
}
@end
