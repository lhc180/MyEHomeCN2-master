//
//  MyEAcTempMonitorViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/24/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcTempMonitorViewController.h"
#define AC_TEMP_MONITOR_DOWNLOADER_NMAE @"AcTempMonitorDownloader"
#define AC_TEMP_MONITOR_UPLOADER_NMAE @"AcTempMonitorUploader"

@interface MyEAcTempMonitorViewController ()

@end

@implementation MyEAcTempMonitorViewController
@synthesize accountData, device, acTempMonitor = _acTempMonitor;
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
    [self downloadTempMonitorDataFromServer];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIView *view1 = [self.view viewWithTag:200];
    for (UIView *v in self.view.subviews) {
        if (v.tag == 200 || v.tag == 201) {
            v.layer.masksToBounds = YES;
            v.layer.borderWidth = 0.5;
            v.layer.borderColor = [UIColor lightGrayColor].CGColor;
            v.layer.cornerRadius = 4;
        }
    }

//    if (!IS_IOS6) {
        for (UIButton *btn in view1.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn"] forState:UIControlStateNormal];
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
            }
        }
//    }else{
//        for (UIButton *btn in view1.subviews) {
//            if ([btn isKindOfClass:[UIButton class]]) {
//                [btn setBackgroundImage:[UIImage imageNamed:@"detailBtn-ios6"] forState:UIControlStateNormal];
//                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
//            }
//        }
//    }
    lowTempArray = [NSMutableArray array];
    highTempArray = [NSMutableArray array];
    for (int i=0; i<19; i++) {
        [lowTempArray addObject:[NSString stringWithFormat:@"%i℃",i]];
    }
    for (int i = 22 ; i<36; i++) {
        [highTempArray addObject:[NSString stringWithFormat:@"%i℃",i]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - setter methods
-(void)setAcTempMonitor:(MyEAcTempMonitor *)acTempMonitor
{
    if(_acTempMonitor != acTempMonitor){
        _acTempMonitor = acTempMonitor;
        _acTempMonitor_copy = [acTempMonitor copy];
        [self _refreshUI];
    }
}
#pragma mark - URL private methods
- (void)downloadTempMonitorDataFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
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
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?tId=%@&id=%ld&temperatureRangeFlag=%ld&autoRunAcFlag=%ld&tmin=%ld&tmax=%ld",
                        GetRequst(URL_FOR_AC_TEMP_MONITOR_SAVE),
                        self.device.tId,
                        (long)self.device.deviceId,
                        (long)(self.acTempMonitor.monitorFlag?1:0),//这里这种方法不错，也可以使用[NSNumber numberWithBool],这个一样可以进行0和1的判断
                        (long)(self.acTempMonitor.autoRunFlag?1:0),
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
        }
    }
    if([name isEqualToString:AC_TEMP_MONITOR_UPLOADER_NMAE]) {
        NSLog(@"AC_TEMP_MONITOR_UPLOADER_NMAE string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
 //           [MyEUtil showErrorOn:self.navigationController.view withMessage:@"用户会话超时，需要重新登录！"];
        } else if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"空调温度监控设置发生错误！"];
            self.acTempMonitor = [_acTempMonitor_copy copy];// revert the value
        } else  {
            _acTempMonitor_copy = [self.acTempMonitor copy];// clone the backup data
            
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
            if (_saveToExit) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    [self decideIfComfortChanged];
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
#pragma mark - privates method
-(void)_refreshUI
{
    [self.enableTempMonitorSwitch setOn:self.acTempMonitor.monitorFlag animated:YES];
    if (!self.device.isSystemDefined) {
        [self.enableAcAutoRunSwitch setOn:NO];
        self.enableAcAutoRunSwitch.enabled = NO;
    }else{
        if (self.enableTempMonitorSwitch.isOn) {
            [self.enableAcAutoRunSwitch setOn:self.acTempMonitor.autoRunFlag animated:YES];
        }else
            [self.enableAcAutoRunSwitch setOn:NO];
    }
//    [self.enableAcAutoRunSwitch setOn:self.acTempMonitor.autoRunFlag animated:YES ];
    //这里增加了限制条件，因为有时候数据的显示超出了设定范围
    if (self.acTempMonitor.minTemp > 18) {
        [self.lowTemBtn setTitle:[NSString stringWithFormat:@"18℃"] forState:UIControlStateNormal];
    }else if(self.acTempMonitor.minTemp < 0){
        [self.lowTemBtn setTitle:[NSString stringWithFormat:@"0℃"] forState:UIControlStateNormal];
    }else{
        [self.lowTemBtn setTitle:[NSString stringWithFormat:@"%li℃",(long)self.acTempMonitor.minTemp] forState:UIControlStateNormal];
    }
    if (self.acTempMonitor.maxTemp < 22) {
        [self.highTemBtn setTitle:[NSString stringWithFormat:@"22℃"] forState:UIControlStateNormal];
    }else if (self.acTempMonitor.maxTemp > 35){
        [self.highTemBtn setTitle:[NSString stringWithFormat:@"35℃"] forState:UIControlStateNormal];
    }else{
        [self.highTemBtn setTitle:[NSString stringWithFormat:@"%li℃",(long)self.acTempMonitor.maxTemp] forState:UIControlStateNormal];
    }
    self.overlayView.hidden = self.acTempMonitor.monitorFlag;
}
- (void)decideIfComfortChanged
{
    if (self.acTempMonitor != Nil && _acTempMonitor_copy != Nil) {
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *original = [writer stringWithObject:[self.acTempMonitor JSONDictionary]];
        NSString *copy = [writer stringWithObject:[_acTempMonitor_copy JSONDictionary]];
        if ([original isEqualToString:copy]) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}
#pragma mark - IBAction methods
- (IBAction)tempMonitorSwitchChanged:(UISwitch *)sender {
    self.acTempMonitor.monitorFlag = self.enableTempMonitorSwitch.on;
    self.overlayView.hidden = self.acTempMonitor.monitorFlag;
    [self decideIfComfortChanged];
}

- (IBAction)acAutoRunSwitch:(id)sender {
    self.acTempMonitor.autoRunFlag = self.enableAcAutoRunSwitch.on;
    [self decideIfComfortChanged];
}
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    [self saveTempMonitorToServer];
}
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)lowTemBtnPress:(UIButton *)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择最低温度"
                                    andDelegate:self
                                         andTag:1
                                       andArray:lowTempArray
                                   andSelectRow:[lowTempArray indexOfObject:sender.currentTitle]
                              andViewController:self];
}
- (IBAction)highTemBtnPress:(UIButton *)sender {
    [MyEUniversal doThisWhenNeedPickerWithTitle:@"请选择最高温度"
                                    andDelegate:self
                                         andTag:2
                                       andArray:highTempArray
                                   andSelectRow:[highTempArray indexOfObject:sender.currentTitle]
                              andViewController:self];
}


#pragma mark -
#pragma mark UIPickerViewDelegate Protocol and UIPickerViewDataSource Method
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles{
    if (pickerView.tag == 1) {
        [self.lowTemBtn setTitle:titles[0] forState:UIControlStateNormal];
        if ([titles[0] length] < 3) {
            self.acTempMonitor.minTemp = [[titles[0] substringToIndex:2] intValue];
        }else
            self.acTempMonitor.minTemp = [[titles[0] substringToIndex:3] intValue];
    }else{
        [self.highTemBtn setTitle:titles[0]forState:UIControlStateNormal];
        self.acTempMonitor.maxTemp = [[titles[0] substringToIndex:3] intValue];
    }
    [self decideIfComfortChanged];
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    if (self.navigationItem.rightBarButtonItem.enabled) {
        [MyEUniversal doThisWhenNeedTellUserToSaveWhenExitWithLeftBtnAction:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } andRightBtnAction:^{
            _saveToExit = YES;
            [self saveTempMonitorToServer];
        }];
    }else
        [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    //这句代码添加之后，整个视图看上去好看多了，主要是label本身是白色的背景
    label.backgroundColor = [UIColor clearColor];
    switch (buttonTag) {
        case 1:
            //这里关于摄氏度符号的显示要注意
            label.text = [NSString stringWithFormat: @"%ld \u00B0C",  (long)row];
            break;
        default:
            label.text = [NSString stringWithFormat: @"%d \u00B0C",  row + 22];
            break;
    }
    return label;
}
@end
