//
//  MyEAdapterSettingsViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-22.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESocketSettingsViewController.h"
#import "MyEDevicesViewController.h"
@interface MyESocketSettingsViewController ()

@end

@implementation MyESocketSettingsViewController
@synthesize terminal,deviceId,deviceType,signalImage;

#pragma mark
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _deviceNameLbl.text = terminal.name;
    deviceId.text = terminal.tId;
    
    if (terminal.irType < 4) {
        [self setSignalImage];
    }
    NSArray *nameArray = @[@"智能插座",@"智能开关",@"红外入侵探测器",@"烟雾探测器",@"门磁",@"声光报警器"];
    if (terminal.irType > 1 && terminal.irType < 8) {
        self.title = nameArray[terminal.irType - 2];
        deviceType.text = self.title;
    }
    if (IS_IOS6) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = TableViewGroupBGColor;
        self.tableView.backgroundView = view;
    }
}
#pragma mark
#pragma mark - private methods
//-(void)defineTapGestureRecognizer{
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    tapGesture.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:tapGesture];
//}
//
//-(void)hideKeyboard{
//    [self.view endEditing:YES];
//}
-(void)setSignalImage{
    switch (terminal.conSignal) {
        case 1:
            signalImage.image = [UIImage imageNamed:@"signal1"];
            break;
        case 2:
            signalImage.image = [UIImage imageNamed:@"signal2"];
            break;
        case 3:
            signalImage.image = [UIImage imageNamed:@"signal3"];
            break;
        case 4:
            signalImage.image = [UIImage imageNamed:@"signal4"];
            break;
        default:
            signalImage.image = [UIImage imageNamed:@"signal0"];
            break;
    }
}
-(void)uploadModelToServerWithDeviceName{
    if (![_deviceNameLbl.text isEqualToString:terminal.name]) {
        NSString *urlStr = nil;
        urlStr = [NSString stringWithFormat:@"%@?gid=%@&tId=%@&name=%@",GetRequst(URL_FOR_SETTINGS_TERMINAL_SAVE),MainDelegate.accountData.userId,terminal.tId,_deviceNameLbl.text];
        MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsChangeDeviceNameUploader" userDataDictionary:nil];
        NSLog(@"SettingsChangeDeviceNameUploader is %@",loader.name);
    }else{
        [MyEUtil showMessageOn:nil withMessage:@"终端名称没有变更，请变更后保存"];
    }
}

#pragma mark - memory methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - UITableView delegate method
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入终端名称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *txt = [alert textFieldAtIndex:0];
        txt.textAlignment = NSTextAlignmentCenter;
        txt.text = terminal.name;
        alert.tag = 100;
        [alert show];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        if (self.terminal.irType < 4) {  //这里是插座
            return 3;
        }
        return 2;
    }
    return 1;
}

#pragma mark - URL delegate method
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([MyEUtil getResultFromAjaxString:string] == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if ([MyEUtil getResultFromAjaxString:string] != 1) {
        [MyEUtil showErrorOn:nil withMessage:@"终端名称变更失败"];
    }else{
        terminal.name = _deviceNameLbl.text;
        //当名称修改成功后要及时修改本地数据，达到数据一致性要求
        for (MyETerminal *t in MainDelegate.accountData.terminals) {
            if ([t isKindOfClass:[MyETerminal class]]) {
                if ([t.tId isEqualToString:self.terminal.tId]) {
                    t.name = self.deviceNameLbl.text;
                }
            }
        }
        for (MyEDevice *device in MainDelegate.accountData.devices) {
            if ([device.tId isEqualToString:self.terminal.tId]) {
                device.name = self.deviceNameLbl.text;
            }
        }
        for (MyETerminal *t in MainDelegate.accountData.allTerminals) {
            if ([t isKindOfClass:[MyETerminal class]]) {
                if ([t.tId isEqualToString:self.terminal.tId]) {
                    t.name = self.deviceNameLbl.text;
                }
            }
        }
        [MyEUtil showMessageOn:self.navigationController.view withMessage:@"终端名称更改成功"];
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
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        UITextField *txt = [alertView textFieldAtIndex:0];
        _deviceNameLbl.text = txt.text;
        [self uploadModelToServerWithDeviceName];
    }
}

@end
