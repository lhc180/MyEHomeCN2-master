//
//  MYESettingsMediatorViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-19.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYESettingsMediatorViewController.h"

#import "MyEMainTabBarController.h"

#import "MyEDevicesViewController.h"
#import "MyERoomsViewController.h"
#import "MyEScenesViewController.h"
#import "MyESettingsViewController.h"


@interface MYESettingsMediatorViewController (){
    MBProgressHUD *HUD;
    BOOL _willBind;
}

@end

@implementation MYESettingsMediatorViewController

#pragma mark
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_jumpFromSettings) {
        if(!MainDelegate.accountData.mId || [MainDelegate.accountData.mId isEqualToString:@""]){
            [self hideOrShowViewsWith:NO];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到该帐号未注册网关，请先注册网关" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }else{  //这里表示的是删除
            [self hideOrShowViewsWith:YES];
        }

    }else{
        [self hideOrShowViewsWith:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到该帐号未注册网关，请先注册网关" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setFrame:CGRectMake(0, 0, 50, 30)];
        [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        if (!IS_IOS6) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        }
        [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    
    if (IS_IOS6) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = TableViewGroupBGColor;
        self.tableView.backgroundView = view;
    }
}
#pragma mark
#pragma mark - private methods
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setOnlineStatus{  //在线或者离线只是针对已经绑定了网关而言的
    if (MainDelegate.accountData.mStatus ==1) {
        _onlineLabel.text = @"在线";
    }else{
        if (_jumpFromSettings) {
            _onlineLabel.text = @"离线";
        }else
            _onlineLabel.text = @"已注册";
    }
}
-(void)hideOrShowViewsWith:(BOOL)flag{  //当值为YES时为解绑网关
    _midTextField.hidden = flag;
    _midLabel.hidden = !flag;
    _pinTextField.hidden = flag;
    _onlineLabel.hidden = !flag;
    if (flag) {
        _midLabel.text = MainDelegate.accountData.mId;
        _changeLabel.text = @"当前状态:";
        [self setOnlineStatus];
        [_deleteBtn setTitle:@"删除网关" forState:UIControlStateNormal];
    }else{
        _midTextField.pattern = @"^([0-9a-fA-F]{2}(?:-)){7}[0-9a-fA-F]{2}$";
        _changeLabel.text = @"PIN码:";
        _pinTextField.text = @"";
        [_deleteBtn setTitle:@"注册网关" forState:UIControlStateNormal];
    }
    _willBind = !flag;  //这个字段用于表示此时是绑定还是解绑
    [self.tableView reloadData];
}
- (void)deleteMedator{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"删除网关将导致所有已经添加的设备信息丢失,您确定要继续么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 100;
    [alert show];
}

#pragma mark
#pragma mark - memoryWarning methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView dataSource method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        if (_willBind) {
            return 2;
        }else
            return 1;
    }
    return 2;
}
#pragma mark
#pragma mark - IBAction methods
- (IBAction)deleteOrBind:(UIButton *)sender {
    if ([_deleteBtn.currentTitle isEqualToString:@"删除网关"]) {
        [self deleteMedator];
    }else{
        [_midTextField endEditing:YES];
        [_pinTextField endEditing:YES];
        if ([_midTextField.text length] == 0 || [_pinTextField.text length] == 0) {
            [MyEUtil showMessageOn:nil withMessage:@"请检查输入"];
            return;
        }
        [self bindMediatorToServer];
    }
}
- (IBAction)scanQR:(UIButton *)sender {
    UINavigationController *nav = [self.storyboard instantiateInitialViewController];
    MyEQRScanViewController *vc = [nav childViewControllers][0];
    vc.delegate = self;
    vc.isAddCamera = NO;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark
#pragma mark - downloadOrUpload data methods
-(void)bindMediatorToServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=1&mId=%@&pin=%@",GetRequst(URL_FOR_SETTINGS_BIND_MEDIATOR),MainDelegate.accountData.userId,_midTextField.text,_pinTextField.text];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsBindMedatorUploader" userDataDictionary:nil];
    NSLog(@"SettingsBindMedatorUploader is %@",loader.name);
    
}
-(void)deleteMediatorToServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&action=0&mId=%@",GetRequst(URL_FOR_SETTINGS_BIND_MEDIATOR), MainDelegate.accountData.userId,MainDelegate.accountData.mId];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsDeleteMedatorUploader" userDataDictionary:nil];
    NSLog(@"SettingsDeleteMedatorUploader is %@",loader.name);
}

-(void)downloadDeviceAndRoomListFromServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    } else
        [HUD show:YES];

    NSString *urlStr= [NSString stringWithFormat:@"%@?gid=%@",GetRequst(URL_FOR_DEVICE_ROOM_LIST),MainDelegate.accountData.userId];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deviceAndRoomList"  userDataDictionary:nil];
    NSLog(@"deviceAndRoomList is %@",uploader.name);
}
- (void) downloadSettingsDataFromServer{
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@",GetRequst(URL_FOR_SETTINGS_VIEW), MainDelegate.accountData.userId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"settingsLoader" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark
#pragma mark - MyEDataLoader Delegate methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    
    if([name isEqualToString:@"deviceAndRoomList"]) {
        NSLog(@"deviceAndRoomList string is = %@", string);
        [HUD hide:YES];
        MyEAccountData *account = [[MyEAccountData alloc] initWithJSONString:string];
        MainDelegate.accountData = [MainDelegate.accountData newAccoutData:account];
        MyEMainTabBarController *tabBarController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainTab"];
        UINavigationController *nc = [[tabBarController childViewControllers] objectAtIndex:0];
        MyEDevicesViewController *devicesViewController = [[nc childViewControllers] objectAtIndex:0];
        devicesViewController.devices = MainDelegate.accountData.devices;
        devicesViewController.preivousPanelType = 0;
        devicesViewController.jumpFromMediator = 1;
        
        [MainDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        MainDelegate.window.rootViewController = tabBarController;
    }
    
    if([name isEqualToString:@"SettingsDeleteMedatorUploader"]) {
        [HUD hide:YES];
        NSLog(@"SettingsDeleteMedator JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:self.view withMessage:@"删除网关失败！"];
        }else{
            [self hideOrShowViewsWith:NO];
            //当删除网关之后所有的数据都会刷新一遍.目前看来，devices的刷新在setting里面已经做了，tabitem的禁用也在setting面板做了
            MyESettingsViewController *setting = [self.navigationController childViewControllers][0];
            setting.needRefresh = YES;
            //网关删除之后不允许用户点击其他tab
        }
    }
    if([name isEqualToString:@"SettingsBindMedatorUploader"]) {
        NSLog(@"SettingsBindMedator JSON String from server is \n%@",string);
        
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [HUD hide:YES];
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == -2) {
            [HUD hide:YES];
            [MyEUtil showMessageOn:self.view withMessage:@"此网关的MID已注册！"];
        }else if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [HUD hide:YES];
            [MyEUtil showMessageOn:self.view withMessage:@"注册网关失败,请检查是否输入有误！"];
        }else if([MyEUtil getResultFromAjaxString:string] == -4){
            [HUD hide:YES];
            [MyEUtil showMessageOn:nil withMessage:@"此网关已被注册,请选择其他网关"];
        }else{
            MainDelegate.accountData.mId = _midTextField.text;  //这里必须这么做，否则数据无法正常更新
            [self hideOrShowViewsWith:YES];
            if (_jumpFromSettings) {
                [HUD hide:YES];
                MyESettingsViewController *setting = [self.navigationController childViewControllers][0];
                setting.needRefresh = YES;
            }else{
                [self downloadDeviceAndRoomListFromServer];
            }
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误,请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
    [HUD hide:YES];
}
#pragma mark - MyEQRScanViewControllerDelegate methods
-(void)passMID:(NSString *)mid andPIN:(NSString *)pin{
    _midTextField.text = mid;
    _pinTextField.text = pin;
    [self deleteOrBind:nil];
}

#pragma mark - UIAlertView Delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        [self deleteMediatorToServer];
    }
}
@end
