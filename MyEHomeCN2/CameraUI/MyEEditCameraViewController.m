//
//  MyEEditCameraViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/25/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import "MyEEditCameraViewController.h"
#import "MyECameraTableViewController.h"
@interface MyEEditCameraViewController ()
@end

@implementation MyEEditCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.UIDlbl.text = self.camera.UID;
    self.nameTxt.text = self.camera.name;
    self.passwordTxt.text = self.camera.password;
    self.nameTxt.delegate = self;
    self.passwordTxt.delegate = self;
    [self defineTapGestureRecognizer];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}
-(void)hideKeyboard{
    [self.nameTxt endEditing:YES];
    [self.passwordTxt endEditing:YES];
}

-(void) saveCamera
{
    if ([self.nameTxt.text length] == 0)
    {
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"名称不能为空！"];
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
    MyECameraTableViewController *vc = self.navigationController.childViewControllers[0];
    vc.needRefresh = YES;
}
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.view endEditing:YES];
//}
#pragma mark - UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (_camera.isOnline) {
            return 2;
        }else
            return 3;
    }else if (section == 1){
        return 3;
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
@end
