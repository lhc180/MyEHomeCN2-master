//
//  MyESettingsViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-15.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESettingsViewController.h"
#import "MyEMainTabBarController.h"
#import "MyESubSwitchListViewController.h"
@interface MyESettingsViewController ()

@end

@implementation MyESettingsViewController


@synthesize accountData,settings,terminalsCount,cityLabel,cityName,provinceName,notification,statusLabel,userNameLabel;

#pragma mark
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delaysContentTouches = NO;
    
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self
                            action:@selector(downloadSettingsDataFromServer)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    
    if (!self.isFresh) {
        [self downloadSettingsDataFromServer];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"province"] && [defaults objectForKey:@"city"]) {
        cityLabel.text = [NSString stringWithFormat:@"%@ %@",[defaults objectForKey:@"province"],[defaults objectForKey:@"city"]];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    userNameLabel.text = self.accountData.userName;
    if (self.needRefresh) {
        //这里刷新的时候，设备列表也要进行刷新
        UINavigationController *nav = [self.navigationController.tabBarController childViewControllers][0];
        MyEDevicesViewController *vc = (MyEDevicesViewController *)[nav childViewControllers][0];
        vc.needRefresh = YES;
        self.needRefresh = NO;
        [self downloadSettingsDataFromServer];
    }
    if (self.isFresh) {
        self.isFresh = NO;
        [self downloadSettingsDataFromServer];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if (section == 3){
        if ([self.settings.subSwitchList count]) {
            return 3;
        }else
            return 2;
    }else if (section == 4){
        return 2;
    }else
        return 1;
}
#pragma mark
#pragma mark - provite methods
-(void)setCityLabelWithProvinceId:(NSString *)provinceId andCityId:(NSString *)cityId{

    self.pAndC = [[MyEProvinceAndCity alloc] init];   //这里的逻辑刚开始写错了，还好现在及时更正过来了
    for (MyEProvince *p in self.pAndC.provinceAndCity) {
        if ([p.provinceId isEqualToString:provinceId]) {
            provinceName = p.provinceName;
            for (MyECity *c in p.cities) {
                if ([c.cityId isEqualToString:cityId]) {
                    cityName = c.cityName;
                    break;
                }
            }
            break;   //加入break加快循环的结束
        }
    }
    cityLabel.text = [NSString stringWithFormat:@"%@ %@",provinceName,cityName];
}
-(BOOL)checkIfHasT{
    NSMutableArray *array = [NSMutableArray array];
    for (MyETerminal *t in self.accountData.terminals) {
        if ([[t.tId substringToIndex:2] isEqualToString:@"01"]) {
            [array addObject:t];
        }
    }
    if ([array count] == 0) {
        return NO;
    }
    return YES;
}
#pragma mark
#pragma mark - memoryWarnig methods
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark - MyECitySettingViewControllerDelegate methods

-(void)passProvince:(NSString *)province andCity:(NSString *)city{
    
    cityLabel.text = [NSString stringWithFormat:@"%@ %@",province,city];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:province forKey:@"province"];
    [prefs setObject:city forKey:@"city"];
    
}
#pragma mark tableView delegate methods
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 3) {
        return 1;
    }else
        return 10;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"settings" bundle:nil];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                MyEUserNameResetViewController *vc = (MyEUserNameResetViewController *)[storyboard instantiateViewControllerWithIdentifier:@"userNameReset"];
                vc.accountData = self.accountData;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                MyEPasswordResetViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"passwordReset"];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 1:{
            MyECitySettingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"citySetting"];
            vc.pAndC = self.pAndC;
            [vc setValue:self forKey:@"delegate"];
            [vc setValue:self.accountData forKey:@"accountData"];
            [self.navigationController pushViewController:vc animated:YES];
            break;}
        case 2:
//            [notification setOn:notification.isOn?NO:YES animated:YES];
//            [self valueChange:notification];
            break;
        case 3:
            if (indexPath.row == 0) {
                MyESettingsTerminalsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"terminal"];
                [vc setValue:self.accountData forKey:@"accountData"];
                [self.navigationController pushViewController:vc animated:YES];
            }else if(indexPath.row == 1){
                MYESettingsMediatorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gateway"];
                vc.accountData = self.accountData;
                vc.jumpFromSettings = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                MyESubSwitchListViewController *vc = [[UIStoryboard storyboardWithName:@"settings" bundle:nil] instantiateViewControllerWithIdentifier:@"subSwitch"];
                vc.settings = self.settings;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 4:
            if (indexPath.row == 0) {
                id vc = [storyboard instantiateViewControllerWithIdentifier:@"feedback"];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                id vc = [storyboard instantiateViewControllerWithIdentifier:@"about"];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark
#pragma mark - URL Loading System methods
- (void) downloadSettingsDataFromServer{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@",URL_FOR_SETTINGS_VIEW, self.accountData.userId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"settingsLoader" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void)uploadModelToServerWithEnableNotification{
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&enableNotification=%i",URL_FOR_SETTINGS_ENABLE_NOTIFICATION, accountData.userId,notification.isOn];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsEnableNotificationUploader" userDataDictionary:nil];
    NSLog(@"SettingsEnableNotificationUploader is %@",loader.name);
}
- (void)uploadModelToServerToDeleteUserInfo{
    NSString *urlStr = [NSString stringWithFormat:@"%@",URL_FOR_SETTINGS_SYSTEM_EXIT];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsToDeleteUserInfoUploader" userDataDictionary:nil];
    NSLog(@"SettingsToDeleteUserInfoUploader is %@",loader.name);
}
#pragma mark
#pragma mark - MyEDataLoader Delegate methods

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"settingsLoader"]) {
        if (self.refreshControl.refreshing) {
           [self.refreshControl endRefreshing];
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
        }
        NSLog(@"Settings JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载设置面板数据时发生错误"];
        } else{
            MyESettings *setting = [[MyESettings alloc] initWithJSONString:string];
            self.settings = setting;
            //这里的这个数据会牵扯到整个逻辑
            accountData.allTerminals = setting.terminals;
            accountData.mStatus = setting.status;
            if (setting.mId) {
                accountData.mId = setting.mId;
            }else{
                accountData.mId = @"";
            }
            
            //by YY
            // 根据网关情况, 确定是否允许进入其他面板, 如果网关不在线或没有连接,就提示用户刷新, 并不允许转移到其他面板.
            MyEMainTabBarController *mtc = (MyEMainTabBarController *)self.tabBarController;
            if (!self.accountData.mId || [self.accountData.mId isEqualToString:@""]) {//先看有没有网关
                [mtc setTabbarButtonEnable:NO];
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"温馨提示"
                                                            contentText:@"检测到未绑定智能网关,您将无法操作任何设备,现在需要绑定么?"
                                                        leftButtonTitle:@"取消"
                                                       rightButtonTitle:@"绑定网关"];
                [alert show];
                alert.leftBlock = ^() {
//MARK: 这里是否需要刷新？
//                    [self downloadSettingsDataFromServer];
                };
                alert.rightBlock = ^{
                    //这里要同步刷新设备列表的数据
                    UINavigationController *nav = [self.navigationController.tabBarController childViewControllers][0];
                    MyEDevicesViewController *vc0 = (MyEDevicesViewController *)[nav childViewControllers][0];
                    NSLog(@"devices needRefresh is %i",vc0.needRefresh);
                    vc0.needRefresh = YES;

                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"settings" bundle:nil];
                    MYESettingsMediatorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gateway"];
                    vc.accountData = self.accountData;
                    vc.jumpFromSettings = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                };
            }else if (self.accountData.mStatus == 0 ) { //再看网关在不在线
//                mtc.selectedIndex = 3;
                [mtc setTabbarButtonEnable:NO];
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"温馨提示"
                                                            contentText:@"检测到智能网关离线,您将无法操作任何设备,请检查网络状况或给网关断电后重试!"
                                                        leftButtonTitle:@"取消"
                                                       rightButtonTitle:@"刷新"];
                [alert show];
                alert.rightBlock = ^() {
                    //这里必须要进行刷新
                    UINavigationController *nav = [self.navigationController.tabBarController childViewControllers][0];
                    MyEDevicesViewController *vc = (MyEDevicesViewController *)[nav childViewControllers][0];
                    NSLog(@"devices needRefresh is %i",vc.needRefresh);
                    vc.needRefresh = YES;
                    
                    [self downloadSettingsDataFromServer];
                };
            }else if([self.accountData.terminals count] == 0){//再检查有没有智控星
                [mtc setTabbarButtonEnable:NO];
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"温馨提示"
                                                            contentText:@"检测到未绑定任何智能设备,请先绑定!"
                                                        leftButtonTitle:@"取消"
                                                       rightButtonTitle:@"刷新"];
                [alert show];
                alert.rightBlock = ^() {
                    //这里必须要进行刷新
                    UINavigationController *nav = [self.navigationController.tabBarController childViewControllers][0];
                    MyEDevicesViewController *vc = (MyEDevicesViewController *)[nav childViewControllers][0];
                    NSLog(@"devices needRefresh is %i",vc.needRefresh);
                    vc.needRefresh = YES;

                    [self downloadSettingsDataFromServer];
                };
            }else{  //最后允许用户进行任何操作
                [mtc setTabbarButtonEnable:YES];
            }
        }
        if (accountData.mStatus == 1) {
            statusLabel.text = @"在线";
        }else if (accountData.mStatus == 0 && [accountData.mId isEqualToString:@""]){
            statusLabel.text = @"未注册网关";
        }else
            statusLabel.text = @"离线";
        [notification setOn:settings.enableNotification == 0?NO:YES animated:YES];
        [self setCityLabelWithProvinceId:self.settings.provinceId andCityId:self.settings.cityId];
        terminalsCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[accountData.allTerminals count]];
        self.subSwitchCount.text = [NSString stringWithFormat:@"%i",self.settings.subSwitchList.count];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:settings.provinceId forKey:@"provinceId"];
        [prefs setObject:settings.cityId forKey:@"cityId"];
        //这里必须要刷新一下tableview，否则有些内容不会显示
        [self.tableView reloadData];
    }
    if([name isEqualToString:@"SettingsEnableNotificationUploader"]) {
        NSLog(@"SettingsEnableNotification JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
           
            [MyEUtil showMessageOn:nil withMessage:@"推送消息设置发生错误"];
            [notification setOn:NO animated:YES];
        }
    }
    if([name isEqualToString:@"SettingsDisableNotificationUploader"]) {
        
        NSLog(@"SettingsDisableNotification JSON String from server is \n%@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:nil withMessage:@"推送消息设置发生错误"];
            [notification setOn:YES animated:YES];
        }
    }
    if([name isEqualToString:@"SettingsToDeleteUserInfoUploader"]) {
        NSLog(@"SettingsToDeleteUserInfoUploader JSON String from server is \n%@",string);
    }
    [HUD hide:YES];
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg = @"与服务器通信时发生错误，请稍后重试.";
    
    [MyEUtil showMessageOn:nil withMessage:msg];
    [HUD hide:YES];
}


#pragma mark
#pragma mark - IBAction methods
- (IBAction)valueChange:(UISwitch *)sender {
    [self uploadModelToServerWithEnableNotification];
}
- (IBAction)deleteUserInfo:(UIButton *)sender {
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"温馨提示"
                                                contentText:@"此操作将使您与服务器断开连接，您确定退出登录吗？"
                                            leftButtonTitle:@"取消"
                                           rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^() {
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs removeObjectForKey:@"mId"];
        [defs removeObjectForKey:@"provinceId"];
        [defs removeObjectForKey:@"cityId"];
        self.accountData = nil;
        [MainDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        MyELoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        MainDelegate.window.rootViewController = vc;
        [self uploadModelToServerToDeleteUserInfo];
    };
}
@end
