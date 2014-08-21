//
//  MyECameraPasswordSetTableViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-6-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraPasswordSetTableViewController.h"

@interface MyECameraPasswordSetTableViewController ()

@end

@implementation MyECameraPasswordSetTableViewController

#pragma mark - lifecircle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    //下面代码用于查看该摄像头的三个用户名及相对应的密码
//    _m_PPPPChannelMgt->SetUserPwdParamDelegate((char *)[_camera.UID UTF8String], self);
//    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_PARAMS, NULL, 0);
//    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_USER_INFO, NULL, 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods
- (IBAction)resetPassword:(UIBarButtonItem *)sender {
    [self.Pwdold resignFirstResponder];
    [self.Pwdnew resignFirstResponder];
    [self.Pwdnew1 resignFirstResponder];
    if ([self.Pwdold.text isEqualToString:self.Pwdnew.text]) {
        [MyEUtil showMessageOn:nil withMessage:@"新旧密码相同"];
        return;
    }
    if (![self.Pwdnew.text isEqualToString:self.Pwdnew1.text]) {
        [MyEUtil showMessageOn:nil withMessage:@"新密码前后不匹配"];
        return;
    }
    if (self.Pwdnew.text.length < 6) {
        [MyEUtil showMessageOn:nil withMessage:@"密码长度不能少于6位"];
        return;
    }
    NSInteger result = _m_PPPPChannelMgt->SetUserPwd((char *)[_camera.UID UTF8String], (char *)[@"" UTF8String], (char *)[@"" UTF8String], (char *)[@"" UTF8String], (char *)[@"" UTF8String], (char *)[_camera.username UTF8String], (char *)[self.Pwdnew1.text UTF8String]);
    if (result == 1) {
        self.camera.password = self.Pwdnew.text;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码设置成功,需要摄像头重启后才能生效,现在重启摄像机么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }else
        [MyEUtil showMessageOn:nil withMessage:@"修改失败"];
}
#pragma mark - UserPwdProtocol delegate methods
-(void)UserPwdResult:(NSString *)did user1:(NSString *)strUser1 pwd1:(NSString *)strPwd1 user2:(NSString *)strUser2 pwd2:(NSString *)strPwd2 user3:(NSString *)strUser3 pwd3:(NSString *)strPwd3{
    /*2014-07-01 03:19:02.972 MyEHomeCN2[243:6413] UID:VSTC323869KTUZJ
     user1: pwd1:
     user2: pwd2:
     user3:admin pwd3:888888
     */
    NSLog(@"UID:%@\n user1:%@ pwd1:%@\n user2:%@ pwd2:%@ \n user3:%@ pwd3:%@",did,strUser1,strPwd1,strUser2,strPwd2,strUser3,strPwd3);
}

#pragma mark - UIAlertView delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_REBOOT_DEVICE, NULL, 0);
        [MyEUtil showMessageOn:nil withMessage:@"摄像机重启时间较长,请耐心等待"];
    }
}
@end
