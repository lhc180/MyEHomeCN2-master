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
{
    NSArray *_initArray;  //初始化数组，用于记录设备的各项信息
    NSMutableArray *_txtArray;
}
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
    // Do any additional setup after loading the view.
    UITextField *name_tf = (UITextField *)[self.view viewWithTag:100];
    name_tf.text = self.camera.name;
    
    UITextField *UID_tf = (UITextField *)[self.view viewWithTag:101];
    UID_tf.text = self.camera.UID;
    
    UITextField *username_tf = (UITextField *)[self.view viewWithTag:102];
    username_tf.text = self.camera.username;
    
    UITextField *password_tf = (UITextField *)[self.view viewWithTag:103];
    password_tf.text = self.camera.password;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    _initArray = @[_camera.name,_camera.UID,_camera.username,_camera.password];
    _txtArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *noti){
        [_txtArray removeAllObjects];
        for (UITextField *txt in self.view.subviews) {
            if ([txt isKindOfClass:[UITextField class]]) {
                [_txtArray addObject:txt.text];
            }
        }
        self.navigationItem.rightBarButtonItem.enabled = [_txtArray isEqualToArray:_initArray]?NO:YES;
    }];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}
#pragma mark - private methods
-(void) saveCamera
{
    UITextField *name_tf = (UITextField *)[self.view viewWithTag:100];
    [name_tf resignFirstResponder];
    if ([name_tf.text length] == 0)
    {
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"名称不能为空！"];
        return;
    }
    
    UITextField *UID_tf = (UITextField *)[self.view viewWithTag:101];
    [UID_tf resignFirstResponder];
    if ([UID_tf.text length] < 15)
    {
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"UID长度必须是15位！"];
        return;
    }
    
    UITextField *username_tf = (UITextField *)[self.view viewWithTag:102];
    [username_tf resignFirstResponder];
    if ([username_tf.text length] == 0)
    {
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"用户名不能为空！"];
        return;
    }
    UITextField *password_tf = (UITextField *)[self.view viewWithTag:103];
    [password_tf resignFirstResponder];
    
    if ([password_tf.text length] <6)
    {
        [MyEUtil showErrorOn:self.navigationController.view withMessage:@"密码必须包含6个字符！"];
        return;
    }
    self.camera.name = name_tf.text;
    self.camera.UID = UID_tf.text;
    self.camera.username = username_tf.text;
    self.camera.password = password_tf.text;
    MyECameraTableViewController *vc = self.navigationController.childViewControllers[0];
    vc.needRefresh = YES;
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - IBAction methods
- (IBAction)confirm:(id)sender {
    [self saveCamera];
}
@end
