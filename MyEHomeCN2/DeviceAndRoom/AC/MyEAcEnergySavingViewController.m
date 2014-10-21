//
//  MyEAcComfortViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcEnergySavingViewController.h"
#import "MYECitySetViewController.h"

#define AC_COMFORT_DOWNLOADER_NMAE @"AcComfortDownloader"
#define AC_COMFORT_UPLOADER_NMAE @"AcComfortUploader"
@interface MyEAcEnergySavingViewController (){
    MyEProvinceAndCity *_allCities;
}

@end

@implementation MyEAcEnergySavingViewController
@synthesize device, comfort = _comfort;

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
    
    
    [self downloadComfortDataFromServer];
    UIView *view1 = [self.view viewWithTag:200];
    UIView *view2 = [self.view viewWithTag:201];
    for (UIView *v in self.view.subviews) {
        if (v.tag == 200 || v.tag == 201) {
            v.layer.masksToBounds = YES;
            v.layer.borderWidth = 0.5;
            v.layer.borderColor = [UIColor lightGrayColor].CGColor;
            v.layer.cornerRadius = 4;
        }
    }
    for (UIButton *btn in view1.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
        }
    }
    for (UIButton *btn in view2.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            btn.layer.masksToBounds = YES;
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = MainColor.CGColor;
            btn.layer.cornerRadius = 4;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (![self.comfort.cityId isEqualToString:MainDelegate.accountData.cityId]) {
        self.comfort.provinceId = MainDelegate.accountData.provinceId;
        self.comfort.cityId = MainDelegate.accountData.cityId;
        [self setBtnTitle];
    }
}

#pragma mark - private methods
-(void)_refreshUI
{
    [self.comfortFlagSwitch setOn:self.comfort.comfortFlag animated:YES ];
    self.overView.hidden = self.comfort.comfortFlag;
    if (self.comfort.comfortRiseTime) {  //这里是要进行判断该值是否存在
        [self.riseTimeBtn setTitle:self.comfort.comfortRiseTime forState:UIControlStateNormal];
    }else
        [self.riseTimeBtn setTitle:@"0:00" forState:UIControlStateNormal];
    if (self.comfort.comfortSleepTime) {
        [self.sleepTimeBtn setTitle:self.comfort.comfortSleepTime forState:UIControlStateNormal];
    }else
        [self.sleepTimeBtn setTitle:@"0:00" forState:UIControlStateNormal];
}

-(void)setBtnTitle{
    NSString *provinceName,*cityName;
    if (_allCities == nil) {
        _allCities = [[MyEProvinceAndCity alloc] init];
    }
    
    for (MyEProvince *p in _allCities.provinceAndCity) {
        if ([p.provinceId isEqualToString:self.comfort.provinceId]) {
            provinceName = p.provinceName;
            for (MyECity *c in p.cities) {
                if ([c.cityId isEqualToString:self.comfort.cityId]) {
                    cityName = c.cityName;
                    break;
                }
            }
            break;   //break的必要性，这个可以加快程序的运行
        }
    }
    //这里特别值得注意，btn在enable未被选中的前提下，不允许修改btn的title
    UIView *view = (UIView *)[self.view viewWithTag:201];
    UIButton *btn = (UIButton *)[view viewWithTag:100];
    [btn setTitle:[NSString stringWithFormat:@"%@ %@",provinceName,cityName] forState:UIControlStateNormal];
}
- (void)decideIfComfortChanged
{
    if (self.comfort != Nil && _comfort_copy != Nil) {
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *original = [writer stringWithObject:[self.comfort JSONDictionary]];
        NSString *copy = [writer stringWithObject:[_comfort_copy JSONDictionary]];
        if ([original isEqualToString:copy]) {
            self.saveBtn.enabled = NO;
        }else
            self.saveBtn.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - setter methods
-(void)setComfort:(MyEAcComfort *)comfort
{
    if(_comfort != comfort){
        _comfort = comfort;
        _comfort_copy = [comfort copy];
        [self _refreshUI];
    }
}
#pragma mark - URL private methods
- (void)downloadComfortDataFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld",
                        GetRequst(URL_FOR_AC_COMFORT_VIEW),
                        self.device.tId,
                        (long)self.device.deviceId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil delegate:self
                                 loaderName:AC_COMFORT_DOWNLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AC_COMFORT_DOWNLOADER_NMAE]) {
        NSLog(@"ac comfort string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载空调舒适度时发生错误！"];
        } else  {
            MyEAcComfort *comfort = [[MyEAcComfort alloc] initWithJSONString:string];
            if(comfort){
                self.comfort = comfort;
            }
            [self setBtnTitle];
        }
        [self decideIfComfortChanged];
    }
    if([name isEqualToString:AC_COMFORT_UPLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载空调舒适度时发生错误！"];
            self.comfort = [_comfort_copy copy];// revert the value
        } else  {
            _comfort_copy = [self.comfort copy];// clone the backup data
        }
        [self decideIfComfortChanged];
    }
    
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:AC_COMFORT_DOWNLOADER_NMAE])
        msg = @"获取空调舒适度通信错误，请稍后重试.";
    else if([name isEqualToString:AC_COMFORT_UPLOADER_NMAE])
        msg = @"上传空调舒适度通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

#pragma mark - IBAction methods
- (IBAction)comfortSwitchChanged:(UISwitch *)sender {
    self.overView.hidden = sender.isOn;
    self.comfort.comfortFlag = self.comfortFlagSwitch.on;
    [self decideIfComfortChanged];
}
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)riseTimeAction:(UIButton *)sender {
    MYETimePicker *timePicker = [[MYETimePicker alloc] initWithView:self.view andTag:1 title:@"请选择起床时间" interval:30 andDelegate:self];
    timePicker.time = sender.currentTitle;
    [timePicker show];
}
- (IBAction)sleepTimeAction:(UIButton *)sender {
    MYETimePicker *timePicker = [[MYETimePicker alloc] initWithView:self.view andTag:2 title:@"请选择睡觉时间" interval:30 andDelegate:self];
    timePicker.time = sender.currentTitle;
    [timePicker show];
}
- (IBAction)setCity:(UIButton *)sender {
    MYECitySetViewController *vc = [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateViewControllerWithIdentifier:@"citySet"];
    vc.comfort = self.comfort;
    vc.isProvince = YES;
    vc.allCities = _allCities;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)saveComfortAction:(UIBarButtonItem *)sender {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld&comfortFlag=%ld&comfortRiseTime=%@&comfortSleepTime=%@",
                        GetRequst(URL_FOR_AC_COMFORT_SAVE),
                        self.device.tId,
                        (long)self.device.deviceId,
                        (long)(self.comfort.comfortFlag?1:0),
                        self.comfort.comfortRiseTime,
                        self.comfort.comfortSleepTime];
    MyEDataLoader *uploader = [[MyEDataLoader alloc]
                               initLoadingWithURLString:urlStr
                               postData:nil delegate:self
                               loaderName:AC_COMFORT_UPLOADER_NMAE
                               userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
}

//    [self.mainContainer setFrame:CGRectMake(self.mainContainer.frame.origin.x, 0, self.mainContainer.frame.size.width, self.mainContainer.frame.size.height)];

#pragma mark - MYETimePicker delegate methods
-(void)MYETimePicker:(UIView *)timePicker didSelectString:(NSString *)title{
    if (timePicker.tag == 1) {
        self.comfort.comfortRiseTime = title;
    }else {
        self.comfort.comfortSleepTime = title;
    }
    [self _refreshUI];
    [self decideIfComfortChanged];
    
}
@end
