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
#import "MYECitySetViewController.h"
@interface MyESettingsViewController (){
    BOOL _needRefreshCity;
}

@end

@implementation MyESettingsViewController


@synthesize settings,terminalsCount,cityLabel,cityName,provinceName,notification,statusLabel,userNameLabel;

#pragma mark
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delaysContentTouches = NO;
    
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self action:@selector(downloadSettingsDataFromServer) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
    
    if (!self.isFresh) {
        [self downloadSettingsDataFromServer];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    userNameLabel.text = MainDelegate.accountData.userName;
    if (self.needRefresh) {
        //这里刷新的时候，设备列表也要进行刷新
        self.needRefresh = NO;
        UINavigationController *nav = [self.navigationController.tabBarController childViewControllers][0];
        MyEDevicesViewController *vc = (MyEDevicesViewController *)[nav childViewControllers][0];
        vc.needRefresh = YES;
        [self downloadSettingsDataFromServer];
    }
    if (self.isFresh) {
        self.isFresh = NO;
        [self downloadSettingsDataFromServer];
    }
    if (![MainDelegate.accountData.cityId isEqualToString:self.settings.cityId] && self.settings.cityId != nil) {
        self.settings.provinceId = MainDelegate.accountData.provinceId;
        self.settings.cityId = MainDelegate.accountData.cityId;
        [self setCityLabelWithProvinceId:self.settings.provinceId andCityId:self.settings.cityId];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if (section == 3){
        if (self.settings.mediators != nil) {
            return 1;
        }else{
            if ([self.settings.subSwitchList count]) {
                return 3;
            }else
                return 2;
        }
    }else if (section == 4){
        return 2;
    }else
        return 1;
}
#pragma mark
#pragma mark - provite methods
-(void)setCityLabelWithProvinceId:(NSString *)provinceId andCityId:(NSString *)cityId{
    if ([cityId isEqualToString:@""]) {
        cityLabel.text = @"";
        return;
    }
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
    for (MyETerminal *t in MainDelegate.accountData.terminals) {
        if ([[t.tId substringToIndex:2] isEqualToString:@"01"]) {
            [array addObject:t];
        }
    }
    if ([array count] == 0) {
        return NO;
    }
    return YES;
}
#pragma mark - memoryWarnig methods
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark tableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"settings" bundle:nil];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                MyEUserNameResetViewController *vc = (MyEUserNameResetViewController *)[storyboard instantiateViewControllerWithIdentifier:@"userNameReset"];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                MyEPasswordResetViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"passwordReset"];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 1:{
            MYECitySetViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"citySet"];
            vc.allCities = self.pAndC;
            vc.isProvince = YES;
            vc.settings = self.settings;
            _needRefreshCity = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;}
        case 2:
//            [notification setOn:notification.isOn?NO:YES animated:YES];
//            [self valueChange:notification];
            break;
        case 3:
            if (indexPath.row == 0) {
                if (self.settings.mediators == nil) {
                    MYESettingsMediatorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gateway"];
                    vc.jumpFromSettings = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    UITableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"mediatorList"];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else if(indexPath.row == 1){
                MyESettingsTerminalsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"terminal"];
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
    } else
        [HUD show:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@",GetRequst(URL_FOR_SETTINGS_VIEW), MainDelegate.accountData.userId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"settingsLoader" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void)uploadModelToServerWithEnableNotification{
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@&enableNotification=%i",GetRequst(URL_FOR_SETTINGS_ENABLE_NOTIFICATION), MainDelegate.accountData.userId,notification.isOn];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"SettingsEnableNotificationUploader" userDataDictionary:nil];
    NSLog(@"SettingsEnableNotificationUploader is %@",loader.name);
}
- (void)uploadModelToServerToDeleteUserInfo{
    NSString *urlStr = [NSString stringWithFormat:@"%@",GetRequst(URL_FOR_SETTINGS_SYSTEM_EXIT)];
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
            
            [notification setOn:settings.enableNotification animated:YES];
            MainDelegate.accountData.provinceId = self.settings.provinceId;
            MainDelegate.accountData.cityId = self.settings.cityId;
            [self setCityLabelWithProvinceId:self.settings.provinceId andCityId:self.settings.cityId];

            if (self.settings.mediators != nil ){
                MainDelegate.accountData.mediators = self.settings.mediators;
                self.statusLabel.text = [NSString stringWithFormat:@"%i",self.settings.mediators.count];
            }else{
                //更改主数据
                MainDelegate.accountData.allTerminals = setting.terminals;
                MainDelegate.accountData.mStatus = setting.status;
                if (setting.mId) {
                    MainDelegate.accountData.mId = setting.mId;
                }else{
                    MainDelegate.accountData.mId = @"";
                }
                
                //UI更新
                if (MainDelegate.accountData.mStatus == 1) {
                    statusLabel.text = @"在线";
                }else if (MainDelegate.accountData.mStatus == 0 && [MainDelegate.accountData.mId isEqualToString:@""]){
                    statusLabel.text = @"未注册网关";
                }else
                    statusLabel.text = @"离线";
                
                terminalsCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[MainDelegate.accountData.allTerminals count]];
                self.subSwitchCount.text = [NSString stringWithFormat:@"%i",self.settings.subSwitchList.count];
                
            }
            
            //by YY
            // 根据网关情况, 确定是否允许进入其他面板, 如果网关不在线或没有连接,就提示用户刷新, 并不允许转移到其他面板.
            MyEMainTabBarController *mtc = (MyEMainTabBarController *)self.tabBarController;
            if ([MainDelegate.accountData hasNoMediator]) {//先看有没有网关
                [mtc setTabbarButtonEnable:NO];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"检测到未绑定智能网关,您将无法操作任何设备,现在需要绑定么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"绑定网关", nil];
                alert.tag = 100;
                [alert show];
            }else if ([MainDelegate.accountData allMediatorOffLine]) { //再看网关在不在线
                [mtc setTabbarButtonEnable:NO];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"检测到智能网关离线,您将无法操作任何设备,请检查网络状况或给网关断电后重试!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"刷新", nil];
                alert.tag = 110;
                [alert show];
            }else{  //最后允许用户进行任何操作
                [mtc setTabbarButtonEnable:YES];
            }
        }
        
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"此操作将使您与服务器断开连接,您确定退出登录吗?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil, nil];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheet delegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs removeObjectForKey:@"mId"];
        [defs removeObjectForKey:@"provinceId"];
        [defs removeObjectForKey:@"cityId"];
        MainDelegate.accountData = nil;
        [MainDelegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        MyELoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:IS_IPAD?@"loginForIPad":@"LoginViewController"];
        MainDelegate.window.rootViewController = vc;
        [self uploadModelToServerToDeleteUserInfo];
    }
}

#pragma mark - UIAlertView delegate 
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        UINavigationController *nav = [self.navigationController.tabBarController childViewControllers][0];
        MyEDevicesViewController *vc0 = (MyEDevicesViewController *)[nav childViewControllers][0];
        NSLog(@"devices needRefresh is %i",vc0.needRefresh);
        vc0.needRefresh = YES;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"settings" bundle:nil];
        MYESettingsMediatorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"gateway"];
        vc.jumpFromSettings = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (alertView.tag == 110 && buttonIndex == 1) {
        UINavigationController *nav = [self.navigationController.tabBarController childViewControllers][0];
        MyEDevicesViewController *vc = (MyEDevicesViewController *)[nav childViewControllers][0];
        NSLog(@"devices needRefresh is %i",vc.needRefresh);
        vc.needRefresh = YES;
        
        [self downloadSettingsDataFromServer];
    }
}
@end
