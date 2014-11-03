//
//  MyESocketManualControlViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyESocketManualControlViewController.h"

#define SOCKET_INFORMATION_DOWNLOADER_NMAE @"SocketInformationDownloader"
#define SOCKET_SWITCH_CONTROL_UPLOADER_NMAE @"SocketSwitchControlUploader"

@interface MyESocketManualControlViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actor;

@end

@implementation MyESocketManualControlViewController
@synthesize device;

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self downloadTimerInfoFromServer];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [_timerToDownloadInfo invalidate];
    [_timer invalidate];
}

#pragma mark - IBAction methods
- (IBAction)refreshAction:(UIBarButtonItem *)sender {
    [self downloadTimerInfoFromServer];
}
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)powerSwitchChanged:(UIButton *)sender {
    self.actor.hidden = NO;
    sender.hidden = YES;
//    if(HUD == nil) {
//        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    } else
//        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:
                        @"%@?gid=%@&id=%ld&powerSwitch=%d",
                        GetRequst(URL_FOR_SOCKET_SWITCH_CONTROL),
                        MainDelegate.accountData.userId,
                        (long)self.device.deviceId,
                        sender.selected];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr postData:nil
                                 delegate:self
                                 loaderName:SOCKET_SWITCH_CONTROL_UPLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - private methods
-(void)handleTimer{
    if (self.socket.timeRemain <= 0) {
        self.socket.isPowerOn = NO;
        self.device.status.switchStatus = 0;
        self.timerInfoLabel.text = @"";
        self.powerBtn.selected = YES;
        return;
    }
    self.socket.timeRemain --;
    self.timerInfoLabel.text = [NSString stringWithFormat:@"定时剩余时间  %@",[MyEUtil getMinuteFromSeconds:_socket.timeRemain]];
}
//- (void)timerFired:(NSTimer *)aTimer{
//    NSInteger seconds = (_stopTs - (NSInteger)[[NSDate date] timeIntervalSince1970]);
//    NSInteger mins = (int)(seconds / 60);
//    NSInteger remainder_seconds = seconds % 60;
//    if(seconds <= 0){//定时结束，取消计时器
//        NSLog(@"定时结束，取消计时器");
//        if(_timer != nil){
//            [_timer invalidate];
//            _timer = nil;
//        }
//        self.timerInfoLabel.hidden = YES;
//        // 下面设置开关为关
//        [self.powerBtn setSelected:YES];
//        _stopTs = 0;
//    } else{
//        [self.timerInfoLabel setText:[NSString stringWithFormat:@"定时中,还剩%ld分钟 %ld 秒...",(long)mins, (long)remainder_seconds]];
//    }
//}

#pragma mark - URL private methods
-(void) downloadTimerInfoFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:
                        @"%@?tId=%@&action=0",
                        GetRequst(URL_FOR_SOCKET_INFORMATION_AND_TIME_CONTROL),
                        self.device.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr postData:nil
                                 delegate:self
                                 loaderName:SOCKET_INFORMATION_DOWNLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:SOCKET_INFORMATION_DOWNLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i == -3) {
            [MyEUniversal doThisToCloseKeyboardWithVC:self];
            return;
        }
        if (i >= 0) {
            self.socket = [[MYESocket alloc] initWithJSONString:string];
            self.powerBtn.selected = !_socket.isPowerOn;
            self.device.status.powerSwitch = _socket.isPowerOn;
            if (_socket.isPowerOn) {   //开关开启状态
                if (_socket.timeRemain > 0) {
                    self.timerInfoLabel.text = [NSString stringWithFormat:@"定时剩余时间  %@",[MyEUtil getMinuteFromSeconds:_socket.timeRemain]];
                    [_timer invalidate];
                    [_timerToDownloadInfo invalidate];
                    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
                    _timerToDownloadInfo = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(downloadTimerInfoFromServer) userInfo:nil repeats:YES];
                }else{
                    [_timer invalidate];
                    [_timerToDownloadInfo invalidate];
                    self.timerInfoLabel.text = @"";
                }
            }else{
                [_timerToDownloadInfo invalidate];
                [_timer invalidate];
            }
            [self.currentPowerLabel setText:[NSString stringWithFormat:@"%.2f (瓦)",_socket.currentPower]];
        }else{
            [MyEUtil showMessageOn:nil withMessage:@"数据获取失败"];
        }
        return;
    }
//    if([name isEqualToString:SOCKET_INFORMATION_DOWNLOADER_NMAE]) {
//        if ([MyEUtil getResultFromAjaxString:string] == -1) {
//            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载插座信息时发生错误！"];
//        } else  if ([MyEUtil getResultFromAjaxString:string] == -3) {
//            [MyEUniversal doThisWhenUserLogOutWithVC:self];
//       //     [MyEUtil showErrorOn:self.navigationController.view withMessage:@"用户会话超时，需要重新登录！"];
//        } else{
//            NSLog(@"ajax json = %@", string);
//            SBJsonParser *parser = [[SBJsonParser alloc] init];
//            // 把JSON转为字典
//            NSDictionary *result_dict = [parser objectWithString:string];
//            NSDictionary *terminalSocket = [result_dict objectForKey:@"terminalSocket"];
//            
//            if ([[result_dict objectForKey:@"result"] intValue] == 0){
//                // 下面设置开关为开
//                [self.powerBtn setSelected:NO];
//                self.device.status.powerSwitch = 1;
//                
//                NSInteger surplusSeconds = [[result_dict objectForKey:@"surplusSeconds"] intValue];
//                _stopTs = (NSInteger)[[NSDate date] timeIntervalSince1970] + surplusSeconds;
//                self.timerInfoLabel.hidden = NO;
//                NSInteger seconds = (_stopTs - (NSInteger)[[NSDate date] timeIntervalSince1970]);
//                NSInteger mins = (int)(seconds / 60);
//                NSInteger remainder_seconds = seconds % 60;
//                [self.timerInfoLabel setText:[NSString stringWithFormat:@"定时中,还剩%ld分钟 %ld 秒...",(long)mins, (long)remainder_seconds]];
//                
//                if(_timer != nil){
//                    [_timer invalidate];
//                    _timer = nil;
//                }
//                _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
//            } else if ([[result_dict objectForKey:@"result"] intValue] == 1){
//                
//                NSInteger switchStatus = [[terminalSocket objectForKey:@"switchStatus"] integerValue];
//                self.device.status.powerSwitch = switchStatus;
//                if(switchStatus == 0){// 表示插座在关闭状态
//                    // 下面设置开关为关
//                    [self.powerBtn setSelected:YES];
//                } else {// 表示插座在打开状态
//                    // 下面设置开关为开
//                    [self.powerBtn setSelected:NO];
//                }
//                self.timerInfoLabel.hidden = YES;
//            }
//            
//            self.device.name = [terminalSocket objectForKey:@"aliasName"];
//            //之所以出现这种情况，是因为返回的结果中就没有这个值
////            self.device.status.connection = [[terminalSocket objectForKey:@"connection"] integerValue];
//            self.device.status.currentPower = [[terminalSocket objectForKey:@"currentPower"] floatValue];
//            self.device.status.maxElectricCurrent = [[terminalSocket objectForKey:@"maxElectricCurrent"] integerValue];
//            self.device.status.totalPower = [[terminalSocket objectForKey:@"totalPower"] integerValue];
//            self.device.status.tpStartDate = [terminalSocket objectForKey:@"tpStartDate"];
//            [self.currentPowerLabel setText:[NSString stringWithFormat:@"%.2f  (瓦)", self.device.status.currentPower]];
//        }
//    }
    if([name isEqualToString:SOCKET_SWITCH_CONTROL_UPLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            self.actor.hidden = YES;
            self.powerBtn.hidden = NO;
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1) {
//            [MyEUtil showSuccessOn:self.view withMessage:[NSString stringWithFormat:self.powerBtn.selected?@"插座已经关闭":@"插座已经打开"]];
            self.actor.hidden = YES;
            self.powerBtn.hidden = NO;
            self.powerBtn.selected = !self.powerBtn.selected;
            self.device.status.powerSwitch = !self.powerBtn.selected;
        }else{
            self.actor.hidden = YES;
            self.powerBtn.hidden = NO;
            [MyEUtil showErrorOn:self.view withMessage:[NSString stringWithFormat:@"插座控制失败"]];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:SOCKET_INFORMATION_DOWNLOADER_NMAE])
        msg = @"下载插座信息通信错误，请稍后重试.";
    else if ([name isEqualToString:SOCKET_SWITCH_CONTROL_UPLOADER_NMAE])
        msg = @"插座控制通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showErrorOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
    self.actor.hidden = YES;
}

@end
