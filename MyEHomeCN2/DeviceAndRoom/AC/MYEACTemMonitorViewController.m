//
//  MYEACTemMonitorViewController.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEACTemMonitorViewController.h"
#import "MBProgressHUD.h"
#import "MYEPickerView.h"

#define AC_TEMP_MONITOR_DOWNLOADER_NMAE @"AcTempMonitorDownloader"
#define AC_TEMP_MONITOR_UPLOADER_NMAE @"AcTempMonitorUploader"


@interface MYEACTemMonitorViewController ()<MyEDataLoaderDelegate,MYEPickerViewDelegate>{
    MBProgressHUD *HUD;
    NSMutableArray *lowTempArray;
    NSMutableArray *highTempArray;
}


@property (weak, nonatomic) IBOutlet UISwitch *enableTempMonitorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableAcAutoRunSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lblLow;
@property (weak, nonatomic) IBOutlet UILabel *lblHigh;
@property (strong, nonatomic) IBOutlet UILabel *tableFooterView;

@end

@implementation MYEACTemMonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self downloadTempMonitorDataFromServer];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    lowTempArray = [NSMutableArray array];
    highTempArray = [NSMutableArray array];
    for (int i=0; i<19; i++) {
        [lowTempArray addObject:[NSString stringWithFormat:@"%i℃",i]];
    }
    for (int i = 22 ; i<36; i++) {
        [highTempArray addObject:[NSString stringWithFormat:@"%i℃",i]];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)refreshUI{
    [self.enableTempMonitorSwitch setOn:self.acTempMonitor.monitorFlag animated:YES];
    [self.enableAcAutoRunSwitch setOn:self.acTempMonitor.autoRunFlag animated:YES];
    
    self.lblLow.text = [NSString stringWithFormat:@"%li℃",(long)self.acTempMonitor.minTemp];
    self.lblHigh.text = [NSString stringWithFormat:@"%li℃",(long)self.acTempMonitor.maxTemp];
    [self.tableView reloadData];
    if (self.acTempMonitor.monitorFlag) {
        self.tableView.tableFooterView = nil;
    }else
        self.tableView.tableFooterView = self.tableFooterView;
}
#pragma mark - IBAction methods
- (IBAction)tempMonitor:(UISwitch *)sender {
    self.acTempMonitor.monitorFlag = sender.isOn;
    [self refreshUI];
}
- (IBAction)autoRun:(UISwitch *)sender {
    self.acTempMonitor.autoRunFlag = sender.isOn;
}
-(IBAction)save:(id)sender{
    [self saveTempMonitorToServer];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.acTempMonitor.monitorFlag) {
        return 3;
    }
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:1 title:@"请选择最低温度" dataSource:lowTempArray andSelectRow:[lowTempArray containsObject:self.lblLow.text]?[lowTempArray indexOfObject:self.lblLow.text]:0];
            picker.delegate = self;
            [picker show];
        }else{
            MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:2 title:@"请选择最高温度" dataSource:highTempArray andSelectRow:[highTempArray containsObject:self.lblHigh.text]?[highTempArray indexOfObject:self.lblHigh.text]:0];
            picker.delegate = self;
            [picker show];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - URL private methods
- (void)downloadTempMonitorDataFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@",
                        GetRequst(URL_FOR_AC_TEMP_MONITOR_VIEW),
                        self.device.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil delegate:self
                                 loaderName:AC_TEMP_MONITOR_DOWNLOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void)saveTempMonitorToServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld&temperatureRangeFlag=%ld&autoRunAcFlag=%ld&tmin=%ld&tmax=%ld",
                        GetRequst(URL_FOR_AC_TEMP_MONITOR_SAVE),
                        self.device.tId,
                        (long)self.device.deviceId,
                        (long)self.acTempMonitor.monitorFlag,//这里这种方法不错，也可以使用[NSNumber numberWithBool],这个一样可以进行0和1的判断
                        (long)self.acTempMonitor.autoRunFlag,
                        (long)self.acTempMonitor.minTemp,
                        (long)self.acTempMonitor.maxTemp];
    MyEDataLoader *uploader = [[MyEDataLoader alloc]
                               initLoadingWithURLString:urlStr
                               postData:nil delegate:self
                               loaderName:AC_TEMP_MONITOR_UPLOADER_NMAE
                               userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
}

#pragma mark - URL delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AC_TEMP_MONITOR_DOWNLOADER_NMAE]) {
        NSLog(@"AC_TEMP_MONITOR_DOWNLOADER_NMAE string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"下载空调温度监控时发生错误！"];
        } else{
            MyEAcTempMonitor *tempMonitor = [[MyEAcTempMonitor alloc] initWithJSONString:string];
            if(tempMonitor){
                self.acTempMonitor = tempMonitor;
            }
            [self refreshUI];
        }
    }
    if([name isEqualToString:AC_TEMP_MONITOR_UPLOADER_NMAE]) {
        NSLog(@"AC_TEMP_MONITOR_UPLOADER_NMAE string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"空调温度监控设置发生错误！"];
        } else  {
            
            //这个才是正确的逻辑，用于指定正确的值
            if (self.enableTempMonitorSwitch.isOn) {
                if (self.enableAcAutoRunSwitch.isOn) {
                    self.device.status.tempMornitorEnabled = 1;
                }else
                    self.device.status.tempMornitorEnabled = 0;
            }else{
                self.device.status.tempMornitorEnabled = 0;
            }
            //            self.device.status.tempMornitorEnabled = self.acTempMonitor.monitorFlag?1:0;
            self.device.status.acTmin = self.acTempMonitor.minTemp;
            self.device.status.acTmax = self.acTempMonitor.maxTemp;
        }
    }
    if (!self.device.isSystemDefined) {
        return;
    }
    //只有enableAcAutoRunSwitch开启的时候才能限制tabbar的点击
    if (self.enableTempMonitorSwitch.isOn && self.enableAcAutoRunSwitch.isOn) {
        UINavigationController *nav1 = [self.tabBarController childViewControllers][1];
        UINavigationController *nav2 = [self.tabBarController childViewControllers][2];
        nav1.tabBarItem.enabled = NO;
        nav2.tabBarItem.enabled = NO;
    }else{
        UINavigationController *nav1 = [self.tabBarController childViewControllers][1];
        UINavigationController *nav2 = [self.tabBarController childViewControllers][2];
        nav1.tabBarItem.enabled = YES;
        nav2.tabBarItem.enabled = YES;
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:AC_TEMP_MONITOR_DOWNLOADER_NMAE])
        msg = @"获取空调温度监控通信错误，请稍后重试.";
    else if([name isEqualToString:AC_TEMP_MONITOR_UPLOADER_NMAE])
        msg = @"上传空调温度监控通信错误，请稍后重试.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

#pragma mark UIPickerViewDelegate Protocol and UIPickerViewDataSource Method
-(void)MYEPickerView:(UIView *)pickerView didSelectTitle:(NSString *)title andRow:(NSInteger)row{
    if (pickerView.tag == 1) {
        if ([title length] < 3) {
            self.acTempMonitor.minTemp = [[title substringToIndex:2] intValue];
        }else
            self.acTempMonitor.minTemp = [[title substringToIndex:3] intValue];
    }else{
        self.acTempMonitor.maxTemp = [[title substringToIndex:3] intValue];
    }
    [self refreshUI];
}
@end
