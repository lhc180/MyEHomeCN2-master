//
//  MyEUserNameResetViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-29.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEUserNameResetViewController.h"

@interface MyEUserNameResetViewController ()

@end

@implementation MyEUserNameResetViewController
@synthesize userNameTextFiled;

#pragma mark - life circle methods
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    userNameTextFiled.text = self.accountData.userName;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [userNameTextFiled becomeFirstResponder];
    });
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *noti){
        if (![userNameTextFiled.text isEqualToString:self.accountData.userName]) {
//            if ([userNameTextFiled.text length] > 16) {
//                [self.view endEditing:YES];
//                [MyEUtil showMessageOn:nil withMessage:@"用户名长度太长"];
//            }else
                self.navigationItem.rightBarButtonItem.enabled = YES;
        }else{
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }];
}
#pragma mark - private methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)doThisWhenNeedPopUp{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    [userNameTextFiled endEditing:YES];
    if([userNameTextFiled.text length] < 4 || [userNameTextFiled.text length] >16){
        [MyEUtil showMessageOn:nil withMessage:@"用户名长度不正确"];
    }else
        [self resetUserNameToServer];
}
#pragma mark - URL private methods
-(void)resetUserNameToServer{
    NSString *urlStr= [NSString stringWithFormat:@"%@?gid=%@&name=%@",GetRequst(URL_FOR_SETTINGS_CHANGE_USERNAME),self.accountData.userId,userNameTextFiled.text];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"userNameReset"  userDataDictionary:nil];
    NSLog(@"userNameReset is %@",uploader.name);
}
#pragma mark - MyEDataLoader Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"userNameReset"]) {
        NSLog(@"userNameReset JSON String from server is \n%@",string);
        switch ([MyEUtil getResultFromAjaxString:string]) {
            case 1:{
                self.accountData.userName = userNameTextFiled.text;
                [MyEUtil showThingsSuccessOn:self.view WithMessage:@"修改成功" andTag:YES];
                [self performSelector:@selector(doThisWhenNeedPopUp) withObject:nil afterDelay:1.5];
            }
                break;
            case -3:
                [MyEUtil showMessageOn:nil withMessage:@"用户名已存在"];
                break;
            default:
                [MyEUtil showMessageOn:nil withMessage:@"修改用户名失败"];
                break;
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
@end
