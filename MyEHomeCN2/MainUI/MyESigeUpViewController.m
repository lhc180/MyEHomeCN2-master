//
//  MyESigeUpViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-25.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESigeUpViewController.h"
#import "MyEMainTabBarController.h"
#import "MyEDevicesViewController.h"
#import "MyEScenesViewController.h"
#import "MyERoomsViewController.h"
#import "MyESettingsViewController.h"

#import "MyEsettingsMediatorViewController.h"

@interface MyESigeUpViewController ()

@end

@implementation MyESigeUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - life circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    userNameField.pattern = @"^([0-9a-fA-F]{2}(?:-)){7}[0-9a-fA-F]{2}$";
    if (IS_IPHONE5) {
        //这里之前出了问题，主要是因为images.xcassets里面的imageset的名字和里面图片的名字不一样，这个得注意了，以后要保证名字是一样的才可以找到相应的资源文件
        [self.loginImage setImage:[UIImage imageNamed:@"signup-568h@2x"]];
    }
    userNameField.delegate = self;
    passwoedField.delegate = self;
    
    [userNameField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [passwoedField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
}
-(void)viewDidDisappear:(BOOL)animated{
    [self setAccountData:nil];
    [self setLoginImage:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction methods

- (IBAction)dismissVC:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)signUp:(id)sender {
    if ([userNameField.text length] == 0 || [passwoedField.text length] == 0) {
        [MyEUtil showMessageOn:nil withMessage:@"请输入正确的MID和PIN码"];
        return;
    }
    [self _doLogin];
}

#pragma mark - private methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(NSString *)dataFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:@"users.plist"];
}
-(NSMutableArray *)getUsersFromPlist{
    NSMutableArray *array = nil;
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    }else
        array = [NSMutableArray array];
    return array;
}
-(void)writeUserInfoInPlist{
    NSMutableArray *array = [self getUsersFromPlist];
    BOOL canWrite = YES;
    if ([array count]) {
        for (NSDictionary *d in [NSArray arrayWithArray:array]) {     //只有不存在的情况下才可以添加
            if ([d[@"username"] isEqualToString:userNameField.text] &&
                [d[@"password"] isEqualToString:passwoedField.text]) {
                canWrite = NO;
                break;
            }else if ([d[@"username"] isEqualToString:userNameField.text] &&
                      ![d[@"password"] isEqualToString:passwoedField.text]){
                [d setValue:passwoedField.text forKey:@"password"];
                [array writeToFile:[self dataFilePath] atomically:YES];
                return;
            }
        }
    }
    if (canWrite) {
        [array addObject:@{@"username": userNameField.text,
                           @"password": passwoedField.text}];
        [array writeToFile:[self dataFilePath] atomically:YES];
    }
}
-(void)saveSettings{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:userNameField.text forKey:@"username"];
    [prefs setObject:passwoedField.text forKey:@"password"];
    [prefs setBool:YES forKey:@"rememberme"];
    [self writeUserInfoInPlist];
    [prefs synchronize];
}

-(void)_doLogin {
    // 1.判断是否联网：
    if (![MyEDataLoader isConnectedToInternet]) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                    contentText:@"没有网络连接，请打开网络后重试"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"确定"];
        [alert show];
        return;
    }
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?username=%@&password=%@&type=1", URL_FOR_LOGIN, userNameField.text, passwoedField.text] ;
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"LoginDownloader" userDataDictionary:nil];
    NSLog(@"downloader.name is  %@ urlStr =  %@",downloader.name, urlStr);
}


#pragma mark - MyEQRScanViewControllerDelegate methods

-(void)passMID:(NSString *)mid andPIN:(NSString *)pin{
    userNameField.text = mid;
    passwoedField.text = pin;
    [self _doLogin];
}

#pragma mark - URL methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"Login account JSON String from server is \n%@",string);
    [HUD hide:YES];
    if([name isEqualToString:@"LoginDownloader"]) {
        MyEAccountData *anAccountData = [[MyEAccountData alloc] initWithJSONString:string];
        if(anAccountData && anAccountData.loginSuccess) {
            self.accountData = anAccountData;
        }
        //MARK:新增内容
        if (self.accountData.mStatus != 1) {
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示" contentText:@"检测到网关离线,请给网关通电并连接网络后重试!" leftButtonTitle:nil rightButtonTitle:@"知道了"];
            [alert show];
            return;
        }
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:self.accountData.mId forKey:@"mId"];
        
        if (self.accountData.loginSuccess == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }else if (self.accountData.loginSuccess == 1){
            [self saveSettings];
            [self performSegueWithIdentifier:@"ShowMainTabViewDirectly" sender:self];
        }else if(self.accountData.loginSuccess == -1){
            [MyEUtil showMessageOn:self.view withMessage:@"密码输入错误！"];
        }else if(self.accountData.loginSuccess == -5){
            [MyEUtil showToastOn:nil withMessage:@"此M-ID对应的账户已经修改了用户名，请使用新用户名和密码登陆" backgroundColor:nil];
        }else if(self.accountData.loginSuccess == 2){
            [MyEUtil showMessageOn:self.view withMessage:@"此网关的MID已注册"];
        }else{
            [MyEUtil showMessageOn:self.view withMessage:@"登录失败，请检查输入是否有误"];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"错误"
                                                contentText:@"通信错误，请稍候重试"
                                            leftButtonTitle:nil
                                           rightButtonTitle:@"确定"];
    [alert show];
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [HUD hide:YES];
}

#pragma mark - navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"ShowMainTabViewDirectly"]) {
        MyEMainTabBarController *tabBarController = [segue destinationViewController];
        //在这里为每个tab view设置houseId和userId, 同时要为每个tab viewController中定义这两个变量，并实现一个统一的签名方法，以保存这个变量。
        
//        [tabBarController setTitle:self.accountData.userName];
        tabBarController.accountData = self.accountData;
        
        UINavigationController *nc = [[tabBarController childViewControllers] objectAtIndex:0];
        MyEDevicesViewController *devicesViewController = [[nc childViewControllers] objectAtIndex:0];
        devicesViewController.accountData = self.accountData;
        devicesViewController.preivousPanelType = 0;
        
        nc = [[tabBarController childViewControllers] objectAtIndex:2];
        MyERoomsViewController *roomsViewController = [[nc childViewControllers] objectAtIndex:0];
        roomsViewController.accountData = self.accountData;
        
        
        nc = [[tabBarController childViewControllers] objectAtIndex:3];
        MyEScenesViewController *scenesViewController = [[nc childViewControllers] objectAtIndex:0];
        scenesViewController.accountData = self.accountData;
        
        nc = [[tabBarController childViewControllers] objectAtIndex:4];
        MyESettingsViewController *settingsViewController = [[nc childViewControllers] objectAtIndex:0];
        settingsViewController.accountData = self.accountData;
    }
    if ([segue.identifier isEqualToString:@"scan"]) {
        UINavigationController *nav = segue.destinationViewController;
        MyEQRScanViewController *vc = [nav childViewControllers][0];
        vc.delegate = self;
        vc.isAddCamera = NO;
    }
}
#pragma mark - UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == userNameField) {
        [passwoedField becomeFirstResponder];
    }else{
        [self _doLogin];
    }
    return YES;
}
@end
