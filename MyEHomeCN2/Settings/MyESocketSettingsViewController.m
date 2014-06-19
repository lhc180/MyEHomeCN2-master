//
//  MyEAdapterSettingsViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-22.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESocketSettingsViewController.h"

@interface MyESocketSettingsViewController ()

@end

@implementation MyESocketSettingsViewController
@synthesize terminal, nameTextField,deviceId,deviceType,signalImage;

#pragma mark
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    nameTextField.text = terminal.name;
    nameTextField.delegate = self;
    deviceId.text = terminal.tId;
    
    [self setDeviceType];
    [self setSignalImage];
    
    if (terminal.irType == 2) {
        self.title = @"智能插座";
    }else
        self.title = @"智能开关";
    [self defineTapGestureRecognizer];
}
#pragma mark
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

-(void)setDeviceType{
    switch (terminal.irType) {
        case 1:
            deviceType.text = @"智控星";
            break;
        case 2:
            deviceType.text = @"智能插座";
            break;
        default:
            deviceType.text = @"智能开关";
            break;
    }
}
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
    if (![nameTextField.text isEqualToString:terminal.name]) {
        NSString *urlStr = nil;
        urlStr = [NSString stringWithFormat:@"%@?gid=%@&tId=%@&name=%@",URL_FOR_SETTINGS_TERMINAL_SAVE,_accoutData.userId,terminal.tId,nameTextField.text];
        MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsChangeDeviceNameUploader" userDataDictionary:nil];
        NSLog(@"SettingsChangeDeviceNameUploader is %@",loader.name);
    }else{
        [MyEUtil showMessageOn:nil withMessage:@"终端名称没有变更，请变更后保存"];
    }

}
#pragma mark - IBAction methods
- (IBAction)save:(UIButton *)sender {
    if ([_saveBtn.currentTitle isEqualToString:@"更改名称"]) {
        nameTextField.userInteractionEnabled = YES;
        [nameTextField becomeFirstResponder];
        [_saveBtn setTitle:@"保存更改" forState:UIControlStateNormal];
    }else{
        [nameTextField endEditing:YES];
        [self uploadModelToServerWithDeviceName];
    }
}

#pragma mark - memory methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (IS_IOS6) {
        return 10;
    }else{
        return 1;
    }
}
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([MyEUtil getResultFromAjaxString:string] == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if ([MyEUtil getResultFromAjaxString:string] != 1) {
        [MyEUtil showErrorOn:nil withMessage:@"终端名称变更失败"];
    }else{
        [_saveBtn setTitle:@"更改名称" forState:UIControlStateNormal];
        nameTextField.userInteractionEnabled = NO;
        terminal.name = nameTextField.text;
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

@end
