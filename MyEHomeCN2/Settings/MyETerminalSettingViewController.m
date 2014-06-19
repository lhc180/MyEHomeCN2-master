//
//  MyETerminalSettingViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-19.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyETerminalSettingViewController.h"
#import "MyEDevicesViewController.h"

@interface MyETerminalSettingViewController ()

@end

@implementation MyETerminalSettingViewController

@synthesize terminal,accountData,deviceId,deviceName,deviceType,saveModeSwitch,signal,dataCollectSwitch,saveDeviceNameBtn;

#pragma mark
#pragma mark - view lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    deviceName.text = terminal.name;
    deviceId.text = terminal.tId;
    deviceName.delegate = self;

    [self setDeviceType];
    [self setSaveModeSwitch];
    [self setDataCollect];
    [self setSignal];
    [self defineTapGestureRecognizer];
}
#pragma mark
#pragma mark - private methods
-(void)setDeviceType{
    switch (terminal.irType) {
        case 1:
            deviceType.text = @"智控星";
            break;
        case 2:
            deviceType.text = @"智能插座";
            break;
        default:
            break;
    }
}
-(void)setSaveModeSwitch{
    if (terminal.powerSaveMode == 1) {
        saveModeSwitch.on = YES;
    }else{
        saveModeSwitch.on = NO;
    }
}
-(void)setDataCollect{
    if (terminal.enableDataCollect == 2) {
        dataCollectSwitch.on = YES;
    }else{
        dataCollectSwitch.on = NO;
    }
}
-(void)setSignal{
    switch (terminal.conSignal) {
        case 1:
            signal.image = [UIImage imageNamed:@"signal1"];
            break;
        case 2:
            signal.image = [UIImage imageNamed:@"signal2"];
            break;
        case 3:
            signal.image = [UIImage imageNamed:@"signal3"];
            break;
        case 4:
            signal.image = [UIImage imageNamed:@"signal4"];
            break;
        default:
            signal.image = [UIImage imageNamed:@"signal0"];
            break;
    }

}
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [deviceName endEditing:YES];
}

#pragma mark
#pragma mark - memoryWarnig methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - tableView delegate methods
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (IS_IOS6) {
        return 10;
    }else{
        return 1;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [saveModeSwitch setOn:!saveModeSwitch.isOn animated:YES];
            [self setSaveMode:saveModeSwitch];
        }else{
            [dataCollectSwitch setOn:!dataCollectSwitch.isOn animated:YES];
            [self setDataCollect:dataCollectSwitch];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark
#pragma mark - downloadOrUpload data methods

- (void)uploadModelToServerWithEnableDataCollect{
    NSString *urlStr = nil;
    urlStr = [NSString stringWithFormat:@"%@?tId=%@&status=%i",URL_FOR_SETTINGS_ENABLE_DATA_COLLECT,terminal.tId,dataCollectSwitch.isOn?2:0];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsEnableDataCollectUploader" userDataDictionary:nil];
    NSLog(@"SettingsEnableDataCollectUploader is %@",loader.name);
}
- (void)uploadModelToServerWithEnablePowerSaveMode{
    NSString *urlStr = nil;
    urlStr = [NSString stringWithFormat:@"%@?gid=%@&tId=%@&powerSaveMode=%i&name=%@",URL_FOR_SETTINGS_TERMINAL_SAVE,accountData.userId,terminal.tId,saveModeSwitch.isOn?1:0,deviceName.text];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsEnablePowerSaveModeUploader" userDataDictionary:nil];
    NSLog(@"SettingsEnablePowerSaveModeUploader is %@",loader.name);
}
- (void)uploadModelToServerWithDeviceName{
    if (![deviceName.text isEqualToString:terminal.name]) {
        NSString *urlStr = nil;
        urlStr = [NSString stringWithFormat:@"%@?gid=%@&tId=%@&name=%@",URL_FOR_SETTINGS_TERMINAL_SAVE,accountData.userId,terminal.tId,deviceName.text];
        MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsChangeDeviceNameUploader" userDataDictionary:nil];
        NSLog(@"SettingsChangeDeviceNameUploader is %@",loader.name);
    }else{
        [MyEUtil showMessageOn:nil withMessage:@"终端名称没有变更，请变更后保存"];
    }
}
#pragma mark
#pragma mark MyEDataLoader - Delegate methods

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    
    if([name isEqualToString:@"SettingsEnableDataCollectUploader"]) {
        NSLog(@"SettingsEnableDataCollectUploader JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:nil withMessage:@"数据采集设置失败"];
            [dataCollectSwitch setOn:NO animated:YES];
        }
    }
    if([name isEqualToString:@"SettingsDisableDataCollectUploader"]) {
        NSLog(@"SettingsDisableDataCollectUploader JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:nil withMessage:@"数据采集设置失败"];
            [dataCollectSwitch setOn:YES animated:YES];
        }
    }
    if([name isEqualToString:@"SettingsEnablePowerSaveModeUploader"]) {
        NSLog(@"SettingsEnablePowerSaveModeUploader JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:nil withMessage:@"省电模式设置失败"];
            [saveModeSwitch setOn:NO animated:YES];
        }
    }
    if([name isEqualToString:@"SettingsDisablePowerSaveModeUploader"]) {
        NSLog(@"SettingsDisablePowerSaveModeUploader JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:nil withMessage:@"省点模式设置失败"];
            [saveModeSwitch setOn:YES animated:YES];
        }
    }
    if([name isEqualToString:@"SettingsChangeDeviceNameUploader"]) {
        NSLog(@"SettingsChangeDeviceNameUploader JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showErrorOn:nil withMessage:@"终端名称变更失败"];
        }else{
            [saveDeviceNameBtn setTitle:@"更改名称" forState:UIControlStateNormal];
            deviceName.userInteractionEnabled = NO;
            //当名称修改成功后要及时修改本地数据，达到数据一致性要求
            UINavigationController *nav = [self.navigationController.tabBarController childViewControllers][0];
            MyEDevicesViewController *vc = [nav childViewControllers][0];
            for (MyETerminal *t in vc.accountData.terminals) {
                if ([t isKindOfClass:[MyETerminal class]]) {
                    if ([t.tId isEqualToString:self.terminal.tId]) {
                        t.name = self.deviceName.text;
                    }
                }
            }
            [MyEUtil showMessageOn:self.navigationController.view withMessage:@"终端名称更改成功"];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
}

#pragma mark
#pragma mark - IBAction methods
- (IBAction)saveDeviceName:(UIButton *)sender {
    if ([saveDeviceNameBtn.currentTitle isEqualToString:@"更改名称"]) {
        deviceName.userInteractionEnabled = YES;
        [deviceName becomeFirstResponder];
        [saveDeviceNameBtn setTitle:@"保存更改" forState:UIControlStateNormal];
    }else{
        [deviceName endEditing:YES];
        [self uploadModelToServerWithDeviceName];
    }
}

- (IBAction)setSaveMode:(UISwitch *)sender {
    [self uploadModelToServerWithEnablePowerSaveMode];
}

- (IBAction)setDataCollect:(UISwitch *)sender {
    [self uploadModelToServerWithEnableDataCollect];
}
#pragma mark - UITextField delegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self uploadModelToServerWithDeviceName];
    return YES;
}
@end
