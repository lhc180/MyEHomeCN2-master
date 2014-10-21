//
//  MyESocketTimedControlViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyESocketTimedControlViewController.h"
#import "MyEAccountData.h"
#import "MyEDevice.h"
#import "MyEUtil.h"
#import "SBJson.h"

#define SOCKET_INFORMATION_DOWNLOADER_NMAE @"SocketInformationDownloader"
#define SOCKET_START_TIMER_CONTROL_UPLOADER_NMAE @"SocketStartTimingControlUploader"
#define SOCKET_STOP_TIMER_CONTROL_UPLOADER_NMAE @"SocketFinishTimingControlUploader"

@interface MyESocketTimedControlViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;

@end

@implementation MyESocketTimedControlViewController


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
//    _timingMinutes = 120; // Default timing minutes is 120.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self downloadTimerInfoFromServer];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [_timer invalidate];
    [_timerToDownloadInfo invalidate];
}
#pragma mark - private methods
-(void)startTimer{
    NSInteger hour = [self.timePicker selectedRowInComponent:0];
    NSInteger minute = [self.timePicker selectedRowInComponent:1];
    self.socket.timeSet = hour*60 + minute;
    self.socket.timeRemain = self.socket.timeSet*60;
    if (self.socket.timeSet == 0) {
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:
                        @"%@?tId=%@&action=1&setTimingMinute=%i",
                        GetRequst(URL_FOR_SOCKET_INFORMATION_AND_TIME_CONTROL),
                        self.device.tId,
                        self.socket.timeSet];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr postData:nil
                                 delegate:self
                                 loaderName:SOCKET_START_TIMER_CONTROL_UPLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);

}
-(void)cancelTimer{
    NSString *urlStr = [NSString stringWithFormat:
                        @"%@?tId=%@&action=2",
                        GetRequst(URL_FOR_SOCKET_INFORMATION_AND_TIME_CONTROL),
                        self.device.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr postData:nil
                                 delegate:self
                                 loaderName:SOCKET_STOP_TIMER_CONTROL_UPLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
#pragma mark - IBAction methods

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)startOrCancelTimer:(UIButton *)sender {
    if (!sender.selected) {
        [self startTimer];
    }else
        [self cancelTimer];
}

- (IBAction)changeTimerMinutes:(id)sender {
    NSInteger hours = (int)(_timingMinutes / 60);
    NSInteger remainder_minutes = _timingMinutes % 60;
    [self.timerMinutesBtn setTitle:[NSString stringWithFormat:@"定时时间 %ld小时%ld分钟", (long)hours, (long)remainder_minutes] forState:UIControlStateNormal];	
    // Show UIPickerView
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
        self.pickerViewContainer.frame = CGRectMake(0, 257, 320, 261);
    } else{
        self.pickerViewContainer.frame = CGRectMake(0, 109, 320, 261);
    }
    [UIView commitAnimations];
    
    [self.pickerView selectRow:hours inComponent:0 animated:YES];
    [self.pickerView reloadComponent:1];
    [self.pickerView selectRow:(hours == 0 ? remainder_minutes - 1 : remainder_minutes) inComponent:1 animated:YES];
}
- (IBAction)switchTimer:(id)sender {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    if(!_isTiming){
        NSString *urlStr = [NSString stringWithFormat:
                            @"%@?tId=%@&action=1&setTimingMinute=%ld",
                            GetRequst(URL_FOR_SOCKET_INFORMATION_AND_TIME_CONTROL),
                            self.device.tId,
                            (long)_timingMinutes];
        MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                     initLoadingWithURLString:urlStr postData:nil
                                     delegate:self
                                     loaderName:SOCKET_START_TIMER_CONTROL_UPLOADER_NMAE
                                     userDataDictionary:nil];
        NSLog(@"%@",downloader.name);
    }else{
        NSString *urlStr = [NSString stringWithFormat:
                            @"%@?tId=%@&action=2&setTimingMinute=%ld",
                            GetRequst(URL_FOR_SOCKET_INFORMATION_AND_TIME_CONTROL),
                            self.device.tId,
                            (long)_timingMinutes];
        MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                     initLoadingWithURLString:urlStr postData:nil
                                     delegate:self
                                     loaderName:SOCKET_STOP_TIMER_CONTROL_UPLOADER_NMAE
                                     userDataDictionary:nil];
        NSLog(@"%@",downloader.name);
    }
}
- (IBAction)refreshAction:(id)sender {
    [self downloadTimerInfoFromServer];
}
- (IBAction)hidePicker:(id)sender {
    [self hidePickerView];
}
#pragma mark - UIPickerViewDelegate Protocol and UIPickerViewDataSource Method
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 4;
    } else{  //if (component == 1)
        return 60;
//        NSInteger hours = [self.pickerView selectedRowInComponent:0];
//        if (hours == 4) {
//            return 1;
//        } if (hours == 0) {
//            return 59;
//        } else
//            return 60;
    }
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 100;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, [pickerView rowSizeForComponent:0].width-30, [pickerView rowSizeForComponent:0].height)];
//    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    
    //这句代码添加之后，整个视图看上去好看多了，主要是label本身是白色的背景
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"%i",row];
//    if(component == 0){
//        label.text = [NSString stringWithFormat: @"%ld",  (long)row];
//    } else{ //if(component == 1)
//        NSInteger hours = [self.pickerView selectedRowInComponent:0];
//        if (hours == 0) {
//            label.text = [NSString stringWithFormat: @"%ld",  (long)row + 1];
//        } else
//            label.text = [NSString stringWithFormat: @"%ld",  (long)row];
//    }
    return label;
}

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    if(component == 0){
//        [pickerView reloadComponent:1];
//        NSInteger minutes = [self.pickerView selectedRowInComponent:1];
//        minutes = row == 0 ? minutes + 1 : minutes;
//        _timingMinutes = row * 60 + minutes;
//    } else{ //if(component == 1)
//        NSInteger hours = [self.pickerView selectedRowInComponent:0];
//        NSInteger minutes = hours == 0 ? row + 1 : row;
//        _timingMinutes = hours * 60 +  minutes;
//    }
//    NSInteger hours = (int)(_timingMinutes / 60);
//    NSInteger remainder_minutes = _timingMinutes % 60;
//    [self.timerMinutesBtn setTitle:[NSString stringWithFormat:@"定时时间 %ld小时%ld分钟", (long)hours, (long)remainder_minutes] forState:UIControlStateNormal];
//}

#pragma mark - private methods
-(void)handleTimer{
    if (self.socket.timeRemain <= 0) {
        self.socket.isPowerOn = NO;
        self.device.status.switchStatus = 0;
        self.lblTime.hidden = YES;
        self.btnTime.selected = NO;
        return;
    }
    self.socket.timeRemain --;
    self.lblTime.text = [MyEUtil getMinuteFromSeconds:self.socket.timeRemain];
}
- (void)updateTimerInformation
{
    NSInteger seconds = (_stopTs - (NSInteger)[[NSDate date] timeIntervalSince1970]);
    NSInteger mins = (int)(seconds / 60);
    NSInteger remainder_seconds = seconds % 60;
    if(seconds <= 0){//定时结束，取消计时器
        NSLog(@"定时结束，取消计时器");
        if(_timer != nil){
            [_timer invalidate];
            _timer = nil;
        }
        self.timerInfoLabel.hidden = YES;
        self.timerMinutesBtn.enabled = YES;
        [self.timerSwitchBtn setTitle:@"启动定时" forState:UIControlStateNormal];
        _isTiming = NO;
        _stopTs = 0;
    } else{
        [self.timerInfoLabel setText:[NSString stringWithFormat:@"定时中, 还剩%ld分钟 %ld 秒...",(long)mins, (long)remainder_seconds]];
        self.timerInfoLabel.hidden = NO;
        self.timerMinutesBtn.enabled = NO;
    }
}
- (void)timerFired:(NSTimer *)aTimer{
    [self updateTimerInformation];
}
- (void)hidePickerView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
        self.pickerViewContainer.frame = CGRectMake(0, 568, 320, 261);
    } else
        self.pickerViewContainer.frame = CGRectMake(0, 480, 320, 261);
    [UIView commitAnimations];
}
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
    NSLog(@"ajax string is \n %@", string);
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if (i == -3) {
        [MyEUniversal doThisToCloseKeyboardWithVC:self];
        return;
    }
    if ([name isEqualToString:SOCKET_INFORMATION_DOWNLOADER_NMAE]) {
        if (i >= 0) {
            self.socket = [[MYESocket alloc] initWithJSONString:string];
            self.lblTime.hidden = self.socket.timeRemain <= 0;
            self.btnTime.selected = self.socket.timeRemain > 0;
            if (self.socket.timeRemain > 0) {
                self.lblTime.text = [MyEUtil getMinuteFromSeconds:_socket.timeRemain];
                [_timer invalidate];
                [_timerToDownloadInfo invalidate];
                _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
                _timerToDownloadInfo = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(downloadTimerInfoFromServer) userInfo:nil repeats:YES];
            }else{
                [_timer invalidate];
                [_timerToDownloadInfo invalidate];
            }
        }else{
            [MyEUtil showMessageOn:nil withMessage:@"数据获取失败"];
        }
        return;
    }
    if([name isEqualToString:SOCKET_INFORMATION_DOWNLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            // 把JSON转为字典
            NSDictionary *result_dict = [parser objectWithString:string];
            NSDictionary *terminalSocket = [result_dict objectForKey:@"terminalSocket"];
            if (!result_dict[@"surplusSeconds"]) {
                self.timerMinutesBtn.enabled = YES;
            }
            if ([[result_dict objectForKey:@"result"] intValue] == 0){
                NSInteger surplusSeconds = [[result_dict objectForKey:@"surplusSeconds"] intValue];
                NSInteger setTmingMinute = [[terminalSocket objectForKey:@"setTmingMinute"] integerValue];
                _timingMinutes = setTmingMinute;
                NSInteger hours = (int)(_timingMinutes / 60);
                NSInteger remainder_minutes = _timingMinutes % 60;
                [self.timerMinutesBtn setTitle:[NSString stringWithFormat:@"定时时间 %ld小时%ld分钟", (long)hours, (long)remainder_minutes] forState:UIControlStateNormal];
                
                _stopTs = (NSInteger)[[NSDate date] timeIntervalSince1970] + surplusSeconds;
                [self updateTimerInformation];
                
                if(_timer != nil){
                    [_timer invalidate];
                    _timer = nil;
                }
                _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
                [self.timerSwitchBtn setTitle:[NSString stringWithFormat:@"停止定时"] forState:UIControlStateNormal];
                _isTiming = YES;
            } else if ([[result_dict objectForKey:@"result"] intValue] == 1){
                if(_timer != nil){
                    [_timer invalidate];
                    _timer = nil;
                }
                NSInteger switchStatus = [[terminalSocket objectForKey:@"switchStatus"] integerValue];
                self.device.status.powerSwitch = switchStatus;
                self.timerInfoLabel.hidden = YES;
                [self.timerSwitchBtn setTitle:[NSString stringWithFormat:@"启动定时"] forState:UIControlStateNormal];
                _isTiming = NO;
            } else {
                [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载插座信息时发生错误！"];
            }
            
            self.device.name = [terminalSocket objectForKey:@"aliasName"];
//            self.device.status.connection = [[terminalSocket objectForKey:@"connection"] integerValue];
            self.device.status.currentPower = [[terminalSocket objectForKey:@"currentPower"] integerValue];
            self.device.status.maxElectricCurrent = [[terminalSocket objectForKey:@"maxElectricCurrent"] integerValue];
            self.device.status.totalPower = [[terminalSocket objectForKey:@"totalPower"] integerValue];
            self.device.status.tpStartDate = [terminalSocket objectForKey:@"tpStartDate"];
        }
    }
    if([name isEqualToString:SOCKET_START_TIMER_CONTROL_UPLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            self.btnTime.selected = YES;
            self.lblTime.hidden = NO;
            self.lblTime.text = [MyEUtil getMinuteFromSeconds:_socket.timeRemain];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
            _timerToDownloadInfo = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(downloadTimerInfoFromServer) userInfo:nil repeats:YES];
//            _stopTs = (NSInteger)[[NSDate date] timeIntervalSince1970] + 60 * _timingMinutes;
//            
//            [self updateTimerInformation];
//            
//            NSInteger hours = (int)(_timingMinutes / 60);
//            NSInteger remainder_minutes = _timingMinutes % 60;
//            [self.timerMinutesBtn setTitle:[NSString stringWithFormat:@"定时时间 %ld小时%ld分钟", (long)hours, (long)remainder_minutes] forState:UIControlStateNormal];
//            
//            if(_timer != nil){
//                [_timer invalidate];
//                _timer = nil;
//            }
//            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
//            [self.timerSwitchBtn setTitle:[NSString stringWithFormat:@"停止定时"] forState:UIControlStateNormal];
//            _isTiming = YES;
        } else {
            [MyEUtil showErrorOn:self.view withMessage:@"启动定时器错误"];
        }
    }
    if([name isEqualToString:SOCKET_STOP_TIMER_CONTROL_UPLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            self.btnTime.selected = NO;
            self.lblTime.hidden = YES;
            [_timerToDownloadInfo invalidate];
            [_timer invalidate];
//            self.timerInfoLabel.hidden = YES;
//            self.timerMinutesBtn.enabled = YES;
//            
//            
//            if(_timer != nil){
//                [_timer invalidate];
//                _timer = nil;
//            }
//            [self.timerSwitchBtn setTitle:[NSString stringWithFormat:@"启动定时"] forState:UIControlStateNormal];
//            _isTiming = NO;
        } else {
            [MyEUtil showErrorOn:self.view withMessage:@"停止定时器错误"];
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
    else if ([name isEqualToString:SOCKET_START_TIMER_CONTROL_UPLOADER_NMAE])
        msg = @"插座启动定时控制通信错误，请稍后重试.";
    else if ([name isEqualToString:SOCKET_STOP_TIMER_CONTROL_UPLOADER_NMAE])
        msg = @"插座停止定时控制通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showErrorOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}
@end
