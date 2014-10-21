//
//  MyEPasswordResetViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEPasswordResetViewController.h"

@interface MyEPasswordResetViewController ()

@end

@implementation MyEPasswordResetViewController
@synthesize currentPasswordTextField,npaswdTextField0,npaswdTextField1;

#pragma mark
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentPasswordTextField.delegate = self;
    self.npaswdTextField0.delegate = self;
    self.npaswdTextField1.delegate = self;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self defineTapGestureRecognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UITextFieldTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    if (IS_IOS6) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = TableViewGroupBGColor;
        self.tableView.backgroundView = view;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)viewDidUnload
{
    [self setCurrentPasswordTextField:nil];
    [self setNpaswdTextField0:nil];
    [self setNpaswdTextField1:nil];
    [super viewDidUnload];
}

#pragma mark
#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [currentPasswordTextField endEditing:YES];
    [npaswdTextField0 endEditing:YES];
    [npaswdTextField1 endEditing:YES];
}
-(void)UITextFieldTextDidChange:(UITextField *)text{
    if ([currentPasswordTextField.text length] > 5 &&
        [npaswdTextField0.text length] > 5 &&
        [npaswdTextField1.text length] > 5) {   //只有当所有的textfiled进行了判断之后才能决定是否显示保存按钮
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}
-(void)doThisWhenNeedPopUp{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)_doResetPassword {
    
    [self hideKeyboard];
    if ([currentPasswordTextField.text isEqualToString:npaswdTextField0.text]) {
        [MyEUtil showErrorOn:nil withMessage:@"新旧密码相同"];
        return;
    }
    if (![self.npaswdTextField0.text isEqualToString:self.npaswdTextField1.text]) {
        [MyEUtil showMessageOn:nil withMessage:@"新密码前后输入不匹配"];
    }else{
        [self uploadModelToServerWithCurrentPassword:self.currentPasswordTextField.text newPassword:self.npaswdTextField0.text];
    }
}
#pragma mark - tableView methods
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (IS_IOS6) {
        return 10;
    }else{
        return 1;
    }
}
#pragma mark
#pragma mark - downloadOrUpload data methods
- (void)uploadModelToServerWithCurrentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.dimBackground = YES;//容易产生灰条
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&oldPassword=%@&newPassword=%@",GetRequst(URL_FOR_SETTINGS_CHANGE_PASSWORD), MainDelegate.accountData.userId, currentPassword, newPassword];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:@"" delegate:self loaderName:@"SettingsPasswordUploader" userDataDictionary:nil];
    NSLog(@"SettingsUploader is %@",loader.name);
}


#pragma mark
#pragma mark - MyEDataLoader Delegate methods

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"SettingsPasswordUploader"]) {
        NSLog(@"Password upload with result: %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            [MyEUtil showThingsSuccessOn:self.view WithMessage:@"修改成功" andTag:YES];
            [self performSelector:@selector(doThisWhenNeedPopUp) withObject:nil afterDelay:1.5];
        }else{
            [MyEUtil showErrorOn:nil withMessage:@"密码重置失败，请重试"];
       }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
    [HUD hide:YES];
}


#pragma mark
#pragma mark - IBAction methods
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    [self _doResetPassword];
}

#pragma mark
#pragma mark - UITextFieldDelegate methods

// 这个是点击return键盘时发生的动作，这是协议方法
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if( textField == currentPasswordTextField){
        [npaswdTextField0 becomeFirstResponder];
    }
    if( textField == npaswdTextField0){
        [npaswdTextField1 becomeFirstResponder];
    }
    if( textField == npaswdTextField1){
        [self _doResetPassword];
    }
    return YES;
}

@end
