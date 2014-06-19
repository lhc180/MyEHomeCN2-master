//
//  MyEDeviceAcViewController.m
//  MyEHome
//
//  Created by Ye Yuan on 10/8/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcManualControlViewController.h"
#import "MyEAcUserModelViewController.h"


#define AC_INSTRUCTION_SET_DOWNLOADER_NMAE @"AcUserModelInstructionDownloader"
#define AC_TEMPERATURE_HUMIDITY_DOWNLOADER_NMAE @"AcTemperatureHumidityDownloader"

@interface MyEAcManualControlViewController ()

@end

@implementation MyEAcManualControlViewController
@synthesize accountData, device,runMode1,runMode2,runMode3,runMode4,runMode5,windLevel,windLevel0,windLevel1,windLevel2,windLevel3,runImage,runLabel,lockLabel,temperatureLabel,homeHumidityLabel,homeTemperatureLabel,tipsLabel,acControlView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
-(void)viewDidDisappear:(BOOL)animated{
    [timerToRefreshTemperatureAndHumidity invalidate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isBtnLocked = NO;
    [self setRunModeImageWithRunMode:self.device.status.runMode];
    [self setWindLevelImageWithWindLevel:self.device.status.windLevel];
    temperatureLabel.text = [NSString stringWithFormat:@"%li",(long)self.device.status.setpoint];
    [homeHumidityLabel setText:[NSString stringWithFormat:@"%li%%", (long)self.device.status.humidity]];
    [homeTemperatureLabel setText:[NSString stringWithFormat:@"%li℃", (long)self.device.status.temperature]];
    if (self.device.status.powerSwitch == 0) {
        [self doThisWhenPowerOff];
        powerOn = NO;
    }else{
        powerOn = YES;
        [self doThisWhenPowerOn];
    }
    acControlView.layer.shadowOffset = CGSizeMake(0, -2);
    acControlView.layer.shadowRadius = 5;
    acControlView.layer.shadowColor = [UIColor blackColor].CGColor;
    acControlView.layer.shadowOpacity = 0.5;
    acControlView.layer.cornerRadius = 5;
    
    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:5];
                [btn.layer setBorderWidth:1];
                [btn.layer setBorderColor:btn.tintColor.CGColor];
            }
        }
    }
    timerToRefreshTemperatureAndHumidity = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(downloadTemperatureHumidityFromServer) userInfo:nil repeats:YES];

}

#pragma mark -
#pragma mark URL Loading System methods
- (void) downloadTemperatureHumidityFromServer
{
    // this is a dumb download, don't add progress indicator or spinner here
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld",URL_FOR_AC_TEMPERATURE_HUMIDITY_VIEW, self.device.tId, (long)self.device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:AC_TEMPERATURE_HUMIDITY_DOWNLOADER_NMAE  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)sendInstructionToServer{
    runImage.hidden = NO;
    NSString *urlStr = [NSString stringWithFormat:@"%@?id=%ld&switch_=%li&runMode=%li&setpoint=%li&windLevel=%li",
                        URL_FOR_AC_CONTROL_SAVE,
                        (long)self.device.deviceId,
                        (long)self.device.status.powerSwitch,
                        (long)self.device.status.runMode,
                        (long)self.device.status.setpoint,
                        (long)self.device.status.windLevel];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"sendInstructionToServer"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:AC_TEMPERATURE_HUMIDITY_DOWNLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if ([MyEUtil getResultFromAjaxString:string] != 1){
            [MyEUtil showMessageOn:nil withMessage:@"下载数据失败"];
        }else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict = [parser objectWithString:string];
            self.device.status.temperature = [[dict objectForKey:@"temperature"] intValue];
            self.device.status.humidity = [[dict objectForKey:@"humidity"] intValue];
            [homeHumidityLabel setText:[NSString stringWithFormat:@"%li%%", (long)self.device.status.humidity]];
            [homeTemperatureLabel setText:[NSString stringWithFormat:@"%li℃",(long)self.device.status.temperature]];
        }
    }
    if ([name isEqualToString:@"sendInstructionToServer"]) {
        NSLog(@"string is %@",string);
        runImage.hidden = YES;
        if ([MyEUtil getResultFromAjaxString:string] == 2) {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dic = [parser objectWithString:string];
            [self setRunModeImageWithRunMode:[dic[@"runMode"] intValue]];
            [self setWindLevelImageWithWindLevel:[dic[@"windLevel"] intValue]];
            temperatureLabel.text = [NSString stringWithFormat:@"%i",[dic[@"setpoint"] intValue]];
            self.device.status.runMode = [dic[@"runMode"] intValue];
            self.device.status.windLevel = [dic[@"windLevel"] intValue];
            self.device.status.setpoint = [dic[@"setpoint"] intValue];
            [MyEUtil showMessageOn:nil withMessage:@"该指令未学习，启用自动补全功能"];
        }else if([MyEUtil getResultFromAjaxString:string] !=1){
            [MyEUtil showMessageOn:nil withMessage:@"发送指令失败"];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:AC_INSTRUCTION_SET_DOWNLOADER_NMAE])
        msg = @"获取指令通信错误，请稍后重试.";
    else msg = @"获取温度湿度通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}
#pragma mark - IBAction methods
- (IBAction)dismissVC:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)poweOnOrOff:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (powerOn) {
        powerOn = NO;
        self.device.status.powerSwitch = 0;
        [self doThisWhenPowerOff];
        [self sendInstructionToServer];
    }else{
        powerOn = YES;
        self.device.status.powerSwitch = 1;
        [self doThisWhenPowerOn];
        [self sendInstructionToServer];
    }
}
- (IBAction)lock:(UIButton *)sender {
    if (!powerOn) {//当空调为关闭状态时，锁定功能无效
        return;
    }
    if (isBtnLocked) {
        isBtnLocked = NO;
    }else{
        isBtnLocked = YES;
    }
    lockLabel.hidden = !isBtnLocked;
}

- (IBAction)temperaturePlus:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (self.device.status.powerSwitch == 0) {
        return;
    }
    if (self.device.status.tempMornitorEnabled == 1 && [temperatureLabel.text intValue] >= self.device.status.acTmax) {
        [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"超出温度监控最高温度"];
        return;
    }

    //获取当前的温度
    NSInteger i = self.device.status.setpoint;
    ++i;
    self.device.status.setpoint = i;
    if (i > 30) {
        i = 30;
        self.device.status.setpoint = i;
        runImage.hidden = YES;
    }
    temperatureLabel.text = [NSString stringWithFormat:@"%li",(long)i];
    [self observeBtnClickTimeInterval];
}

- (IBAction)temperatureMinus:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (self.device.status.powerSwitch == 0) {
        return;
    }
    if (self.device.status.tempMornitorEnabled == 1 && [temperatureLabel.text intValue] <= self.device.status.acTmin) {
        [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"低于温度监控最低温度"];
        return;
    }
    NSInteger i = self.device.status.setpoint;
    --i;
    self.device.status.setpoint = i;
    if (i<18) {
        i = 18;
        self.device.status.setpoint = i;
        runImage.hidden = YES;
    }
    temperatureLabel.text = [NSString stringWithFormat:@"%li",(long)i];
    [self observeBtnClickTimeInterval];
}

- (IBAction)runModeChange:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (self.device.status.powerSwitch == 1) {
        [self observeBtnClickTimeInterval];
    }
    NSInteger i = self.device.status.runMode;
    i ++;
    if (self.device.instructionMode == 1) {
        if (i > 5) {
            i = 1;
        }
    }else{
        if (i > 4) {
            i = 1;
        }
    }
    [self setRunModeImageWithRunMode:i];
    self.device.status.runMode = i;
}

- (IBAction)windLevelChange:(UIButton *)sender {
    if (isBtnLocked) {
        return;
    }
    if (self.device.status.powerSwitch == 0) {
        return;
    }
    NSInteger i = self.device.status.windLevel;
    i++;
    if (i > 3) {
        i = 0;
    }
    [self setWindLevelImageWithWindLevel:i];
    self.device.status.windLevel = i;
    [self observeBtnClickTimeInterval];
}
#pragma mark - private methods
-(void)doThisWhenPowerOn{
    [self setRunModeImageWithRunMode:self.device.status.runMode];
    [self setWindLevelImageWithWindLevel:self.device.status.windLevel];
    runLabel.hidden = NO;
    windLevel.hidden = NO;
    tipsLabel.hidden = YES;
    self.sheshiduLabel.hidden = NO;
    self.temperatureLabel.hidden = NO;
}
-(void)doThisWhenPowerOff{
    //    runMode1.hidden = YES;
    //    runMode2.hidden = YES;
    //    runMode3.hidden = YES;
    //    runMode4.hidden = YES;
    //    runMode5.hidden = YES;
    self.sheshiduLabel.hidden = YES;
    self.temperatureLabel.hidden = YES;
    tipsLabel.hidden = NO;
    windLevel.hidden = YES;
    windLevel0.hidden = YES;
    windLevel1.hidden = YES;
    windLevel2.hidden = YES;
    windLevel3.hidden = YES;
    runLabel.hidden = YES;
    runImage.hidden = YES;
}
-(void)setRunModeImageWithRunMode:(NSInteger)runMode{
    switch (runMode) {
        case 1:
            runMode1.hidden = NO;
            runMode2.hidden = YES;
            runMode3.hidden = YES;
            runMode4.hidden = YES;
            runMode5.hidden = YES;
            break;
        case 2:
            runMode1.hidden = YES;
            runMode2.hidden = NO;
            runMode3.hidden = YES;
            runMode4.hidden = YES;
            runMode5.hidden = YES;
            break;
        case 3:
            runMode1.hidden = YES;
            runMode2.hidden = YES;
            runMode3.hidden = NO;
            runMode4.hidden = YES;
            runMode5.hidden = YES;
            break;
        case 4:
            runMode1.hidden = YES;
            runMode2.hidden = YES;
            runMode3.hidden = YES;
            runMode4.hidden = NO;
            runMode5.hidden = YES;
            break;
        default:
            runMode1.hidden = YES;
            runMode2.hidden = YES;
            runMode3.hidden = YES;
            runMode4.hidden = YES;
            runMode5.hidden = NO;
            break;
    }
}
-(void)setWindLevelImageWithWindLevel:(NSInteger)wind{
    switch (wind) {
        case 0:
            windLevel0.hidden = NO;
            windLevel1.hidden = YES;
            windLevel2.hidden = YES;
            windLevel3.hidden = YES;
            break;
        case 1:
            windLevel0.hidden = YES;
            windLevel1.hidden = NO;
            windLevel2.hidden = YES;
            windLevel3.hidden = YES;
            break;
        case 2:
            windLevel0.hidden = YES;
            windLevel1.hidden = NO;
            windLevel2.hidden = NO;
            windLevel3.hidden = YES;
            break;
        default:
            windLevel0.hidden = YES;
            windLevel1.hidden = NO;
            windLevel2.hidden = NO;
            windLevel3.hidden = NO;
            break;
    }
}
//这里实现连续点击btn，直至没有点击操作时执行
-(void)observeBtnClickTimeInterval{
    if (timer.isValid) {
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendInstructionToServer) userInfo:nil repeats:NO];
    }else{
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendInstructionToServer) userInfo:nil repeats:NO];
    }
}
@end
