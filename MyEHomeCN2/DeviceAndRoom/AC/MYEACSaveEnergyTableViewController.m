//
//  MYEACSaveEnergyTableViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACSaveEnergyTableViewController.h"
#import "MYETimePicker.h"
#import "MBProgressHUD.h"
#import "MyEDataLoader.h"
#import "MYECitySetViewController.h"

#define AC_COMFORT_DOWNLOADER_NMAE @"AcComfortDownloader"
#define AC_COMFORT_UPLOADER_NMAE @"AcComfortUploader"


@interface MYEACSaveEnergyTableViewController ()<MyEDataLoaderDelegate,MYETimePickerDelegate>{
    MBProgressHUD *HUD;
    MyEProvinceAndCity *_allCities;
}
@property (weak, nonatomic) IBOutlet UISwitch *comfortFlagSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lblRiseTime;
@property (weak, nonatomic) IBOutlet UILabel *lblSleepTime;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;

@property (weak, nonatomic) IBOutlet UILabel *tableFooterView;

@end

@implementation MYEACSaveEnergyTableViewController

- (void)viewDidLoad {
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
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (![self.comfort.cityId isEqualToString:MainDelegate.accountData.cityId]) {
        self.comfort.provinceId = MainDelegate.accountData.provinceId;
        self.comfort.cityId = MainDelegate.accountData.cityId;
        [self getCity];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)refreshUI{
    [self.comfortFlagSwitch setOn:self.comfort.comfortFlag animated:YES ];
   
    self.lblRiseTime.text = self.comfort.comfortRiseTime;
    self.lblSleepTime.text = self.comfort.comfortSleepTime;
    
    [self.tableView reloadData];
    if (self.comfort.comfortFlag) {
        self.tableView.tableFooterView = nil;
    }else
        self.tableView.tableFooterView = self.tableFooterView;
}
-(void)getCity{
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
    [self.lblLocation setText:[NSString stringWithFormat:@"%@ %@",provinceName,cityName]];
}
#pragma mark - IBAction methods
- (IBAction)enableEnergySaving:(UISwitch *)sender {
    self.comfort.comfortFlag = sender.isOn;
    [self refreshUI];
}
- (IBAction)saveEditor:(id)sender {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld&comfortFlag=%ld&comfortRiseTime=%@&comfortSleepTime=%@",
                        GetRequst(URL_FOR_AC_COMFORT_SAVE),
                        self.device.tId,
                        (long)self.device.deviceId,
                        (long)(self.comfort.comfortFlag),
                        self.comfort.comfortRiseTime,
                        self.comfort.comfortSleepTime];
    MyEDataLoader *uploader = [[MyEDataLoader alloc]
                               initLoadingWithURLString:urlStr
                               postData:nil delegate:self
                               loaderName:AC_COMFORT_UPLOADER_NMAE
                               userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.comfort.comfortFlag) {
        return 3;
    }
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {  //设置时间
        if (indexPath.row == 0) {
            MYETimePicker *timePicker = [[MYETimePicker alloc] initWithView:self.view andTag:1 title:@"请选择起床时间" interval:30 andDelegate:self];
            timePicker.time = self.lblRiseTime.text;
            [timePicker show];
        }else{
            MYETimePicker *timePicker = [[MYETimePicker alloc] initWithView:self.view andTag:2 title:@"请选择睡觉时间" interval:30 andDelegate:self];
            timePicker.time = self.lblSleepTime.text;
            [timePicker show];
        }
    }
    if (indexPath.section == 2) {  //设置城市
        MYECitySetViewController *vc = [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateViewControllerWithIdentifier:@"citySet"];
        vc.comfort = self.comfort;
        vc.isProvince = YES;
        vc.allCities = _allCities;
        [self.navigationController pushViewController:vc animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
            MainDelegate.accountData.provinceId = self.comfort.provinceId;
            MainDelegate.accountData.cityId = self.comfort.cityId;

            [self getCity];
            [self refreshUI];
        }
    }
    if([name isEqualToString:AC_COMFORT_UPLOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载空调舒适度时发生错误！"];
        }else{
            
        }
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
#pragma mark - MYETimePicker delegate methods
-(void)MYETimePicker:(UIView *)timePicker didSelectString:(NSString *)title{
    if (timePicker.tag == 1) {
        self.comfort.comfortRiseTime = title;
    }else {
        self.comfort.comfortSleepTime = title;
    }
    [self refreshUI];
}

@end
