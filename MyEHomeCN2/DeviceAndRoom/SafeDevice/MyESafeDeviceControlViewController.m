//
//  MyESafeDeviceControlViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESafeDeviceControlViewController.h"

@interface MyESafeDeviceControlViewController (){
    CABasicAnimation *_theAnimation;
    MBProgressHUD *HUD;
}

@end

@implementation MyESafeDeviceControlViewController

#pragma mark - life circle method
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _device.name;
    [self animationInit];
    [self getBtnStatus];
    NSString *normal = nil;
    NSString *select = nil;
    if (_device.type == 8 ) {
        normal = @"ir-control-on";
        select = @"ir-control-off";
    }else if (_device.type == 9){
        normal = @"smoke-control-on";
        select = @"smoke-control-off";
    }else if (_device.type == 10){
        normal = @"door-control-on";
        select = @"door-control-off";
    }else{
        normal = @"slalarm-control-on";
        select = @"slalarm-control-off";
    }
    [_controlBtn setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [_controlBtn setImage:[UIImage imageNamed:select] forState:UIControlStateSelected];
    [self refreshData:nil];
}

#pragma mark - private method
-(void)getBtnStatus{
    self.controlBtn.selected = self.device.status.protectionStatus == 0?YES:NO;
//    self.alarmBtn.enabled = self.device.status.alertStatus == 0?NO:YES;
    if (_controlBtn.selected) {
        _tipLbl.text = @"点击按钮,启动探测";
    }else
        _tipLbl.text = @"点击按钮,关闭探测";
    [self addAnimationToButtonLayer];
}
-(void)animationInit{
    _theAnimation=[CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    _theAnimation.duration=0.2;
    _theAnimation.repeatCount=HUGE_VALF;
    _theAnimation.autoreverses=YES;
    _theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    _theAnimation.toValue=[NSNumber numberWithFloat:0.2];
}
-(void)addAnimationToButtonLayer{
    
    if (!_controlBtn.selected && _device.status.alertStatus == 1) {
        [_controlBtn.layer addAnimation:_theAnimation forKey:@"animateOpacity"];
        [_alarmBtn.layer addAnimation:_theAnimation forKey:@"animateOpacity"];
    }else{
        [_controlBtn.layer removeAllAnimations];
        [_alarmBtn.layer removeAllAnimations];
    }
}
#pragma mark - IBAction methods
- (IBAction)controlAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?tId=%@&protectionStatus=%i",URL_FOR_SAFE_CONTROL,_device.tId,1-_device.status.protectionStatus] postData:nil delegate:self loaderName:@"control" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}
- (IBAction)alarmAction:(UIButton *)sender {
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?tId=%@&protectionStatus=%i",URL_FOR_SAFE_ALARM,_device.tId,!sender.selected] postData:nil delegate:self loaderName:@"alarm" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}

- (IBAction)refreshData:(UIBarButtonItem *)sender {
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?deviceId=%i",URL_FOR_SAFE_INFO,_device.deviceId] postData:nil delegate:self loaderName:@"info" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    NSInteger i = [MyEUtil getResultFromAjaxString:string];
    if (i == 1) {
        if ([name isEqualToString:@"control"]) {
            _device.status.protectionStatus = 1 - _device.status.protectionStatus;
        }else if ([name isEqualToString:@"info"]){
            NSDictionary *dic = [string JSONValue];
            _device.status.protectionStatus = [dic[@"protectionStatus"] intValue];
            _device.status.alertStatus = [dic[@"alertStatus"] intValue];
        }else
            _device.status.alertStatus = 0;
    }else if (i == -3){
        [MyEUtil showMessageOn:nil withMessage:@"用户已注销"];
    }else
        [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
    
    [self getBtnStatus];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}
@end
