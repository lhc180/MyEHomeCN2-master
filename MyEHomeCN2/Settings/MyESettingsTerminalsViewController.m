//
//  MyETerminalsViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-18.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESettingsTerminalsViewController.h"
#import "MyESettingsViewController.h"


@interface MyESettingsTerminalsViewController ()
{
    MBProgressHUD *HUD;
    NSIndexPath *deleteTerminalIndex;
    NSTimer *_checkTimer;   //用于检测红外设备是否成功删除的定时器
    NSInteger _checkTimes;  //用于表示检测的次数
}

@end

@implementation MyESettingsTerminalsViewController
@synthesize accountData;

#pragma mark
#pragma mark - View Lifecycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self
                            action:@selector(downloadSettingsDataFromServer)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    if (!accountData.mId ||[accountData.mId isEqualToString:@""]) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                    contentText:@"检测到网关已删除,请绑定网关后重试!"
                                                leftButtonTitle:nil
                                               rightButtonTitle:@"知道了"];
        [alert show];
    }else{
       if ([accountData.allTerminals count] == 0) {
           DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"提示"
                                                       contentText:@"没有有效智能终端,请绑定后重试!"
                                                   leftButtonTitle:nil
                                                  rightButtonTitle:@"知道了"];
           [alert show];
       }
    }
}
#pragma mark
#pragma mark - memoryWarning methods
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark - private methods
-(void)doThisWhenDeleteTidSuccessWithIndexPath:(NSIndexPath *)indexPath{
    [accountData.allTerminals removeObjectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        [self.tableView reloadData];
    }else{
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    //删除智控星成功后,这里要刷新所有数据
    UINavigationController *nav = [self.navigationController.tabBarController childViewControllers][0];
    MyEDevicesViewController *vc = (MyEDevicesViewController *)[nav.navigationController childViewControllers][0];
    [vc setNeedRefresh:YES];
    //下面这个方法是起作用的，但是上面的这个方法不起作用
    MyESettingsViewController *setting = [self.navigationController childViewControllers][0];
    setting.needRefresh = YES;
    [MyEUtil showSuccessOn:nil withMessage:@"删除红外终端成功！"];

}
#pragma mark
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([accountData.allTerminals count]==0) {
        return 1;
    }else{
        return [accountData.allTerminals count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!accountData.mId || [accountData.mId isEqualToString:@""]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"none"];
        cell.textLabel.text = @"没有检测到网关,请绑定!";
        return cell;
    }
    if ([accountData.allTerminals count]==0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"none"];
        cell.textLabel.text = @"网关没有绑定智能终端,请绑定!";
        return cell;
    }else{
        MyETerminal *terminal = [self.accountData.allTerminals objectAtIndex:indexPath.row];
        NSString *identifier = nil;
        if (terminal.irType == 1) {
            identifier = @"zhikongxing";
        }else
            identifier = @"zhinengchazuo";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        cell.textLabel.text = terminal.name;
        
        if (terminal.irType < 4) {
            switch (terminal.conSignal) {
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"signal1"];
                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"signal2"];
                    break;
                case 3:
                    cell.imageView.image = [UIImage imageNamed:@"signal3"];
                    break;
                case 4:
                    cell.imageView.image = [UIImage imageNamed:@"signal4"];
                    break;
                default:
                    cell.imageView.image = [UIImage imageNamed:@"signal0"]; //这个是不在线的图标
                    break;
            }
        }else{
            NSArray *array = @[@"ir",@"smoke",@"door",@"slalarm"];
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-off",array[terminal.irType - 4]]];
        }
        return cell;
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (IS_IOS6) {
        return 10;
    }else{
        return 1;
    }
}
#pragma mark
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    deleteTerminalIndex = indexPath;
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"警告"
                                                contentText:@"此操作将导致无法操作绑定到该智控星的所有设备，您确定继续么？"
                                            leftButtonTitle:@"取消"
                                           rightButtonTitle:@"确定"];
    [alert show];
    alert.rightBlock = ^() {
        [self deleteTerminalFromServerForRowAtIndexPath:indexPath];
    };
}

#pragma mark
#pragma mark - downloadOrUpload data methods
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
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?gid=%@",GetRequst(URL_FOR_SETTINGS_VIEW), self.accountData.userId];
    
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"settingsLoader" userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
-(void)deleteTerminalFromServerForRowAtIndexPath:(NSIndexPath *) indexPath{

    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    MyETerminal *terminal = [accountData.allTerminals objectAtIndex:indexPath.row];
    
    NSDictionary *dic = @{@"indexPath": indexPath};
    NSString *urlStr= [NSString stringWithFormat:@"%@?tId=%@",GetRequst(URL_FOR_SETTINGS_TERMINAL_DELETE),terminal.tId];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"deleteTerminalFromServer"  userDataDictionary:dic];
    NSLog(@"deleteTerminalFromServer is %@",uploader.name);
}
-(void)checkTerminalDelete{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSIndexPath *indexPath = (NSIndexPath *)_checkTimer.userInfo;
    MyETerminal *terminal = [accountData.allTerminals objectAtIndex:indexPath.row];
    NSDictionary *dic = @{@"indexPath": indexPath};
    NSString *urlStr= [NSString stringWithFormat:@"%@?tId=%@",GetRequst(URL_FOR_SETTINGS_TERMINAL_DELETE_CHECK),terminal.tId];
    MyEDataLoader *uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"checkDeleteTerminalFromServer"  userDataDictionary:dic];
    NSLog(@"checkDeleteTerminalFromServer is %@",uploader.name);

}
#pragma mark
#pragma mark - MyEDataLoader Delegate methods

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"deleteTerminalFromServer"]) {
        NSLog(@"deleteTerminalFromServer string is = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        if ([MyEUtil getResultFromAjaxString:string] == 1){
            NSIndexPath *indexPath = dict[@"indexPath"];
            [self doThisWhenDeleteTidSuccessWithIndexPath:indexPath];
        }else if([MyEUtil getResultFromAjaxString:string] == 2){
            NSIndexPath *indexPath = dict[@"indexPath"];
            _checkTimes = 0;
            _checkTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(checkTerminalDelete)
                                                userInfo:indexPath
                                                 repeats:NO];
        }else
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除红外终端失败，请稍后重试！"];
    }
    if ([name isEqualToString:@"checkDeleteTerminalFromServer"]) {
        NSLog(@"checkDeleteTerminalFromServer is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
            return;
        }
        NSIndexPath *indexPath = dict[@"indexPath"];
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            [self doThisWhenDeleteTidSuccessWithIndexPath:indexPath];
        }else if ([MyEUtil getResultFromAjaxString:string] == 0){
            [MyEUtil showMessageOn:nil withMessage:@"删除过程中发生错误"];
        }else if ([MyEUtil getResultFromAjaxString:string] == 2){
            _checkTimes++;
            if (_checkTimes < 6) {
                _checkTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTerminalDelete) userInfo:indexPath repeats:NO];
            } else {
                [_checkTimer invalidate];
                [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除红外终端失败，请稍后重试！"];
            }
        }else
            [MyEUtil showErrorOn:self.navigationController.view withMessage:@"删除红外终端失败，请稍后重试！"];
    }
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
            self.accountData.allTerminals = setting.terminals;
            [self.tableView reloadData];
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
    [HUD hide:YES];
}

#pragma mark
#pragma mark - Navigation segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id vc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    MyETerminal *terminal = [accountData.allTerminals objectAtIndex:indexPath.row];
    [vc setValue:terminal forKey:@"terminal"];
    if ([vc isKindOfClass:[MyETerminalSettingViewController class]]) {
        [vc setValue:self.accountData forKey:@"accountData"];
    }
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
