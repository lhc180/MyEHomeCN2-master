//
//  MyEsettingsGatewayViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-31.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEsettingsMediatorViewController.h"

#import "MyEMainTabBarController.h"

#import "MyEDevicesViewController.h"
#import "MyERoomsViewController.h"
#import "MyEScenesViewController.h"
#import "MyESettingsViewController.h"

@interface MyEsettingsMediatorViewController ()

@end

@implementation MyEsettingsMediatorViewController
@synthesize midLabel,midTextField,changeLabel,pinTextField,onlineLabel,deleteBtn,accountData,changeValue,scanBtn;


#pragma mark
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self defineTapGestureRecognizer];
    
    if (changeValue == 1) {   //1表示绑定
        [self setButtonNameForBind];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setFrame:CGRectMake(0, 0, 50, 30)];
        if (!IS_IOS6) {
            [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"back-ios6"] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitle:@"返回" forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                    contentText:@"检测到您未绑定网关，请先绑定网关"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"知道了"];
        [alert show];
    }else if(!accountData.mId || [accountData.mId isEqualToString:@""]){
        [self setButtonNameForBind];
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                    contentText:@"检测到您未绑定网关，请先绑定网关"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"知道了"];
        [alert show];
    }else{  //这里表示的是删除
        [self setButtonNameForDelete];
    }
    self.mainView.layer.masksToBounds = YES;
    self.mainView.layer.cornerRadius = 4;
    self.mainView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.mainView.layer.borderWidth = 0.5;
}
#pragma mark
#pragma mark - private methods
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setOnlineStatus{
    if (accountData.mStatus ==1) {
        onlineLabel.text = @"在线";
    }else{
        onlineLabel.text = @"离线";
    }
}
-(void)setButtonNameForBind{
    
    midTextField.hidden = NO;
    midLabel.hidden = YES;
    changeLabel.text = @"PIN码:";
    pinTextField.hidden = NO;
    onlineLabel.hidden = YES;
    midTextField.pattern = @"^([0-9a-zA-Z]{2}(?:-)){7}[0-9a-zA-Z]{2}$";
    [deleteBtn setTitle:@"绑定网关" forState:UIControlStateNormal];
    //这里需要清空一下文本框的值，否则再次出现时，容易显示文字，这样不好
    pinTextField.text = @"";
    scanBtn.hidden = NO;
    
    if (changeValue != 1) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        midTextField.text = [defaults objectForKey:@"mId"];
    }
}
-(void)setButtonNameForDelete{
    [deleteBtn setTitle:@"删除网关" forState:UIControlStateNormal];
    midTextField.hidden = YES;
    pinTextField.hidden = YES;
    onlineLabel.hidden = NO;
    midLabel.hidden = NO;
    changeLabel.text = @"在线状态:";
    scanBtn.hidden = YES;
    if (changeValue == 1) {
        midLabel.text = midTextField.text;
        onlineLabel.text = @"在线";
    }else if([midTextField.text length] != 0){
        midLabel.text = midTextField.text;
    }else{
        midLabel.text = accountData.mId;
    }
    [self setOnlineStatus];
}
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}
-(void)hideKeyboard{
    [midTextField endEditing:YES];
    [pinTextField endEditing:YES];
}
- (void)deleteMedator{
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                contentText:@"删除网关将导致所有已经添加的设备信息丢失，您确定要继续么？"
                                            leftButtonTitle:@"取消"
                                           rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^() {
        [self deleteMediatorToServer];
    };
}

#pragma mark
#pragma mark - memoryWarning methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark - IBAction methods
- (IBAction)deleteOrBind:(UIButton *)sender {
    if ([deleteBtn.currentTitle isEqualToString:@"删除网关"]) {
        [self deleteMedator];
    }else{
        [midTextField endEditing:YES];
        [pinTextField endEditing:YES];
        if ([midTextField.text length] == 0 || [pinTextField.text length] == 0) {
            [MyEUtil showMessageOn:nil withMessage:@"请检查输入"];
            return;
        }
        [self bindMediatorToServer];
    }
}
- (IBAction)scanQR:(UIButton *)sender {
    UIStoryboard *story;
    if (self.jumpFromSettings) {
        story = self.storyboard;
    }else{
        story = [UIStoryboard storyboardWithName:@"settings" bundle:nil];
    }
    UINavigationController *nav = [story instantiateInitialViewController];
    MyEQRScanViewController *vc = [nav childViewControllers][0];
    vc.delegate = self;
    [self presentViewController:nav animated:YES completion:nil];
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark
#pragma mark - downloadOrUpload data methods
-(void)bindMediatorToServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=1&mId=%@&pin=%@",URL_FOR_SETTINGS_BIND_MEDIATOR,self.accountData.userId,midTextField.text,pinTextField.text];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsBindMedatorUploader" userDataDictionary:nil];
    NSLog(@"SettingsBindMedatorUploader is %@",loader.name);
    
}
-(void)deleteMediatorToServer{
    
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=0&mId=%@",URL_FOR_SETTINGS_BIND_MEDIATOR, accountData.userId,accountData.mId];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsDeleteMedatorUploader" userDataDictionary:nil];
    NSLog(@"SettingsDeleteMedatorUploader is %@",loader.name);
}

-(void)downloadDeviceAndRoomListFromServer{
    NSString *urlStr= [NSString stringWithFormat:@"%@?gid=%@",URL_FOR_DEVICE_ROOM_LIST,accountData.userId];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deviceAndRoomList"  userDataDictionary:nil];
    NSLog(@"deviceAndRoomList is %@",uploader.name);
}
- (void) downloadSettingsDataFromServer{
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@",URL_FOR_SETTINGS_VIEW, self.accountData.userId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"settingsLoader" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark
#pragma mark - MyEDataLoader Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    
    [HUD hide:YES];
    
    if([name isEqualToString:@"deviceAndRoomList"]) {
        NSLog(@"deviceAndRoomList string is = %@", string);
        MyEAccountData *account = [[MyEAccountData alloc] initWithJSONString:string];
        accountData.devices = account.devices;
        accountData.terminals = account.terminals;
        accountData.rooms = account.rooms;
        [self performSegueWithIdentifier:@"ShowMainTabViewDirectly" sender:self];
    }

    if([name isEqualToString:@"SettingsDeleteMedatorUploader"]) {
        NSLog(@"SettingsDeleteMedator JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.view withMessage:@"删除网关失败！"];
        }else{
            [self setButtonNameForBind];
            accountData.mStatus = 0;
            //当删除网关之后所有的数据都会刷新一遍.目前看来，devices的刷新在setting里面已经做了，tabitem的禁用也在setting面板做了
            MyESettingsViewController *setting = [self.navigationController childViewControllers][0];
            setting.needRefresh = YES;
            //网关删除之后不允许用户点击其他tab
        }
    }
    if([name isEqualToString:@"SettingsBindMedatorUploader"]) {
        NSLog(@"SettingsBindMedator JSON String from server is \n%@",string);
    
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == -2) {
            [MyEUtil showMessageOn:self.view withMessage:@"此网关的MID已注册！"];
        }else if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:self.view withMessage:@"绑定网关失败,请检查是否输入有误！"];
        }else if([MyEUtil getResultFromAjaxString:string] == -4){
            [MyEUtil showMessageOn:nil withMessage:@"此网关已绑定"];
        }else{
            [self downloadSettingsDataFromServer];
            //这里之所以注释掉，是为了能够准确获取到网关的状态。之前写的accountData.mStatus = 1这句代码有漏洞
//            accountData.mStatus = 1;
//            if (changeValue == 1) {
//                changeValue = 0;
//                [self downloadDeviceAndRoomListFromServer];
//                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                [prefs setObject:midTextField.text forKey:@"mId"];
//            }else{
//                //如果不是跳转的刷新
//                MyESettingsViewController *setting = [self.navigationController childViewControllers][0];
//                setting.needRefresh = YES;
//            }
//           [self setButtonNameForDelete];
        }
    }
    if ([name isEqualToString:@"settingsLoader"]) {
        MyESettings *setting = [[MyESettings alloc] initWithJSONString:string];
        accountData.mStatus = setting.status;
        if (changeValue == 1) {
            changeValue = 0;
            [self downloadDeviceAndRoomListFromServer];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:midTextField.text forKey:@"mId"];
        }else{
            //如果不是跳转的刷新
            MyESettingsViewController *setting = [self.navigationController childViewControllers][0];
            setting.needRefresh = YES;
        }
        [self setButtonNameForDelete];
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
    [HUD hide:YES];
}
#pragma mark
#pragma mark - segue Navgation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"ShowMainTabViewDirectly"]) {
        MyEMainTabBarController *tabBarController = [segue destinationViewController];
        
        [tabBarController setTitle:self.accountData.userName];
        tabBarController.accountData = self.accountData;
        
        UINavigationController *nc = [[tabBarController childViewControllers] objectAtIndex:0];
        MyEDevicesViewController *devicesViewController = [[nc childViewControllers] objectAtIndex:0];
        devicesViewController.accountData = self.accountData;
        devicesViewController.devices = self.accountData.devices;
        devicesViewController.preivousPanelType = 0;
        devicesViewController.jumpFromMediator = 1;
        
        nc = [[tabBarController childViewControllers] objectAtIndex:1];
        MyERoomsViewController *roomsViewController = [[nc childViewControllers] objectAtIndex:0];
        roomsViewController.accountData = self.accountData;
        
        nc = [[tabBarController childViewControllers] objectAtIndex:2];
        MyEScenesViewController *scenesViewController = [[nc childViewControllers] objectAtIndex:0];
        scenesViewController.accountData = self.accountData;
        
        
        nc = [[tabBarController childViewControllers] objectAtIndex:3];
        MyESettingsViewController *settingsViewController = [[nc childViewControllers] objectAtIndex:0];
        settingsViewController.accountData = self.accountData;
        
    }
    if ([segue.identifier isEqualToString:@"scan"]) {
        UINavigationController *nav = segue.destinationViewController;
        MyEQRScanViewController *vc = [nav childViewControllers][0];
        vc.delegate = self;
    }
}
#pragma mark - MyEQRScanViewControllerDelegate methods
-(void)passMID:(NSString *)mid andPIN:(NSString *)pin{
    midTextField.text = mid;
    pinTextField.text = pin;
    [self deleteOrBind:nil];
}
@end
