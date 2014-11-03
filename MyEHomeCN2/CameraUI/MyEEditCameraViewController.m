//
//  MyEEditCameraViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/25/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import "MyEEditCameraViewController.h"
#import "MyECameraTableViewController.h"
#import "MyECameraAlarmViewController.h"
#import "MyECameraDateSetViewController.h"
#import "MyECameraSDRecordViewController.h"
@interface MyEEditCameraViewController (){
    MBProgressHUD *HUD;
    NSCondition* _m_PPPPChannelMgtCondition;
    BOOL _isPushSub;
}
@end

@implementation MyEEditCameraViewController

#pragma life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.UIDlbl.text = self.camera.UID;
    self.nameTxt.text = self.camera.name;
    self.passwordTxt.text = self.camera.password;
    self.nameTxt.delegate = self;
    self.passwordTxt.delegate = self;
    _m_PPPPChannelMgtCondition = [[NSCondition alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (!_isPushSub) {
        _isPushSub = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}
#pragma mark - Notification methods
- (void) didEnterBackground{
    [_m_PPPPChannelMgtCondition lock];
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->StopAll();
    [_m_PPPPChannelMgtCondition unlock];
}

- (void) willEnterForeground{
    [_m_PPPPChannelMgtCondition lock];
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->StopAll();
    _m_PPPPChannelMgt->Start([_camera.UID UTF8String], [self.camera.username UTF8String], [self.camera.password UTF8String]);
    [_m_PPPPChannelMgtCondition unlock];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - private methods

-(void) saveCamera
{
    if ([self.nameTxt.text length] == 0)
    {
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"名称不能为空!"];
        return;
    }
    
//    UITextField *UID_tf = (UITextField *)[self.view viewWithTag:101];
//    [UID_tf resignFirstResponder];
//    if ([UID_tf.text length] < 15)
//    {
//        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"UID长度必须是15位！"];
//        return;
//    }
    
    if ([self.passwordTxt.text length] <6)
    {
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"密码必须包含6个字符！"];
        return;
    }
    self.camera.name = self.nameTxt.text;
    self.camera.password = self.passwordTxt.text;
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%i&did=%@&user=%@&pwd=%@&name=%@&action=2",GetRequst(URL_FOR_CAMERA_EDIT),_camera.deviceId,_camera.UID,_camera.username,_camera.password,_camera.name] postData:nil delegate:self loaderName:@"edit" userDataDictionary:nil];

}
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.view endEditing:YES];
//}
#pragma mark - UITableView dataSource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_camera.isOnline) {
        return 3;
    }else
        return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (_camera.isOnline) {
            return 2;
        }else
            return 3;
    }else if (section == 1){
        return 2;
//        return 6;
    }else
        return 2;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否重启摄像机?" message:[NSString stringWithFormat:@"设备名称:%@",_camera.name] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 100;
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否恢复出厂设置?" message:[NSString stringWithFormat:@"设备名称:%@",_camera.name] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 101;
            [alert show];
        }
    }
}
#pragma mark UITextField delegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length > 0) {
        [textField endEditing:YES];
        [self saveCamera];
        return YES;
    }
    return NO;
}
#pragma mark Navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *vc = segue.destinationViewController;
    _isPushSub = YES;
    [vc setValue:self.camera forKey:@"camera"];
    if ([segue.identifier isEqualToString:@"wifi"]) {
        MyECameraWIFISetViewController *wifi = (MyECameraWIFISetViewController *)vc;
        wifi.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    }
    if ([segue.identifier isEqualToString:@"password"]) {
        MyECameraPasswordSetTableViewController *pwd = (MyECameraPasswordSetTableViewController *)vc;
        pwd.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    }
    if ([segue.identifier isEqualToString:@"sd"]) {
        MyECameraSDSetViewController *sd = (MyECameraSDSetViewController *)vc;
        sd.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    }
    if ([segue.identifier isEqualToString:@"alarm"]) {
        MyECameraAlarmViewController *alarm = (MyECameraAlarmViewController *)vc;
        alarm.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    }
    if ([segue.identifier isEqualToString:@"date"]) {
        MyECameraDateSetViewController *date = (MyECameraDateSetViewController *)vc;
        date.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    }
    if ([segue.identifier isEqualToString:@"record"]) {
        MyECameraSDRecordViewController *record = (MyECameraSDRecordViewController *)vc;
        record.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    }
}
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        NSInteger result = _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_REBOOT_DEVICE, NULL, 0);
        if (result == 1) {
            [MyEUtil showMessageOn:nil withMessage:@"摄像头正在重启"];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
    }
    if (alertView.tag == 101 && buttonIndex == 1) {
        NSInteger result = _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_RESTORE_FACTORY, NULL, 0);
        if (result == 1) {
            [MyEUtil showMessageOn:nil withMessage:@"摄像头正在恢复出厂设置"];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"操作失败"];
    }
}

#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if ([name isEqualToString:@"edit"]) {
        NSInteger i = [MyEUtil getResultFromAjaxString:string];
        if (i == 1) {
            MyECameraTableViewController *vc = self.navigationController.childViewControllers[0];
            vc.needRefresh = YES;
        }else if (i == 0){
            [MyEUtil showMessageOn:nil withMessage:@"传入数据有误"];
        }else if (i == -3){
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"设置失败"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器连接失败"];
}
@end
