//
//  MyEAcControlViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-18.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcControlViewController.h"
#import "MyEAcManualControlViewController.h"
#import "MyEAcUserModelViewController.h"

@interface MyEAcControlViewController ()

@end

@implementation MyEAcControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
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

    if (!self.device.isSystemDefined) {
        MyEAcUserModelViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"customControl"];
        vc.accountData = self.accountData;
        vc.device = self.device;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
    }else{
        MyEAcManualControlViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"standerdControl"];
        vc.accountData = self.accountData;
        vc.device = self.device;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
    }
}
#pragma mark - IBAction methods
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)refreshTemperatureAndHumidity:(UIBarButtonItem *)sender {
    [self downloadTemperatureHumidityFromServer];
}
#pragma mark - URL private methods
- (void) downloadTemperatureHumidityFromServer
{
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld",URL_FOR_AC_TEMPERATURE_HUMIDITY_VIEW, self.device.tId, (long)self.device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"acStatus"  userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"acStatus"]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            [MyEUtil showMessageOn:nil withMessage:@"用户已注销登录"];
        }else if ([MyEUtil getResultFromAjaxString:string] != 1){
            [MyEUtil showMessageOn:nil withMessage:@"下载数据失败"];
        }else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dict = [parser objectWithString:string];
            self.device.status.temperature = [[dict objectForKey:@"temperature"] intValue];
            self.device.status.humidity = [[dict objectForKey:@"humidity"] intValue];
            if (!self.device.isSystemDefined) {
                MyEAcUserModelViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"customControl"];
                vc.tempLabel.text = [NSString stringWithFormat:@"%li℃",(long)self.device.status.temperature];
                vc.humidityLabel.text = [NSString stringWithFormat:@"%li%%",(long)self.device.status.humidity];
            }else{
                MyEAcManualControlViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"standerdControl"];
//                [vc.homeHumidityLabel setText:[NSString stringWithFormat:@"%li%%", (long)self.device.status.humidity]];
//                [vc.homeTemperatureLabel setText:[NSString stringWithFormat:@"%li℃", (long)self.device.status.temperature]];
                vc.statusDic = dict;
                [vc refreshUI];
            }
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [MyEUtil showMessageOn:nil withMessage:@"通讯出现错误，请稍候再试"];
}
@end
