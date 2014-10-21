//
//  MyESwitchAutoViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchAutoViewController.h"

@interface MyESwitchAutoViewController (){
    NSIndexPath *_selectIndex;
}

@end

@implementation MyESwitchAutoViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadSchedulesFromServer];
    NSLog(@"device id is %i",_device.deviceId);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = bgView;

    UIRefreshControl *rc = [[UIRefreshControl alloc] init];
    rc.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [rc addTarget:self
           action:@selector(downloadSchedulesFromServer)
 forControlEvents:UIControlEventValueChanged];
    self.refreshControl = rc;

}
-(void)viewWillAppear:(BOOL)animated{
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadSchedulesFromServer];
    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction methods
- (IBAction)enableSchedule:(UISwitch *)sender {
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    _selectIndex = indexPath;
    NSLog(@"index is %i",indexPath.row);
    MyESwitchSchedule *schedule = self.control.SSList[indexPath.row];
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li&channels=%@&action=2",GetRequst(URL_FOR_SWITCH_TIME_DELAY),(long)self.device.deviceId,[schedule.channels componentsJoinedByString:@","]] andName:@"check"];
}

#pragma mark - private methods
-(void)downloadSchedulesFromServer{
    if (self.refreshControl.isRefreshing) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"加载中..."];
    }
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li",GetRequst(URL_FOR_SWITCH_SCHEDULE_LIST),(long)self.device.deviceId] andName:@"scheduleList"];
}
-(void)uploadInfoToServer{
    MyESwitchSchedule *schedule = self.control.SSList[_selectIndex.row];
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%i&scheduleId=%i&onTime=%@&offTime=%@&channels=%@&weeks=%@&runFlag=%i&action=2",GetRequst(URL_FOR_SWITCH_SCHEDULE_SAVE),self.device.deviceId,schedule.scheduleId,schedule.onTime,schedule.offTime,[schedule.channels componentsJoinedByString:@","],[schedule.weeks componentsJoinedByString:@","],1-schedule.runFlag] andName:@"scheduleControl"];
}
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@ is %@",name,loader.name);
}
#pragma mark - UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.control.SSList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyEScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scheduleCell" forIndexPath:indexPath];
    UIView *bgView = (UIView *)[cell.contentView viewWithTag:1024];
    bgView.layer.cornerRadius = 4;
    MyESwitchSchedule *schedule = self.control.SSList[indexPath.row];
    cell.maxChannel = self.control.numChannel;
    cell.time = [NSString stringWithFormat:@"%@-%@",schedule.onTime,schedule.offTime];
    cell.isOn = schedule.runFlag == 1?YES:NO;
    cell.weeks = schedule.weeks;
    cell.channels = schedule.channels;
    return cell;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除该进程?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 110;
    _selectIndex = indexPath;
    [alert show];
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
#pragma mark - navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MyESwitchScheduleSettingViewController *vc = segue.destinationViewController;
    vc.device = self.device;
    vc.control = self.control;
    if ([segue.identifier isEqualToString:@"add"]) {
        vc.actionType = 1;  //表示新增进程
        vc.schedule = [[MyESwitchSchedule alloc] init];
    }else{
        vc.actionType = 2; //表示编辑进程
        vc.schedule = self.control.SSList[[self.tableView indexPathForCell:sender].row];
    }
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"add"]) {
        if (self.control.SSList.count >= 10) {
            [MyEUtil showMessageOn:nil withMessage:@"当前进程已有十条,无法继续添加"];
            return NO;
        }
    }
    return YES;
}
#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([MyEUtil getResultFromAjaxString:string] == -3) {
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    if ([name isEqualToString:@"scheduleControl"]) {
        NSLog(@"scheduleControl string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            UINavigationController *nav = self.tabBarController.childViewControllers[0];
            MyESwitchManualControlViewController *vc = nav.childViewControllers[0];
            vc.needRefresh = YES;
            MyESwitchSchedule *schedule = self.control.SSList[_selectIndex.row];
            schedule.runFlag = 1 - schedule.runFlag;
            [self.tableView reloadData];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [self.tableView reloadData];
            [MyEUtil showMessageOn:nil withMessage:@"设置进程失败"];
        }
    }
    if ([name isEqualToString:@"scheduleDelete"]) {
        NSLog(@"scheduleDelete is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            [self.control.SSList removeObjectAtIndex:_selectIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"删除进程失败"];
    }
    if ([name isEqualToString:@"scheduleList"]) {
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
        NSLog(@"scheduleList string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyESwitchAutoControl *control = [[MyESwitchAutoControl alloc] initWithString:string];
            self.control = control;
            [self.tableView reloadData];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载进程数据失败"];
        }
    }
    if ([name isEqualToString:@"check"]) {
        NSLog(@"check string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 2) {
            [self uploadInfoToServer];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前开关路数已经开启了延时控制,确定保存此定时设置吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 100;
            [alert show];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [self.tableView reloadData];
            [MyEUtil showMessageOn:nil withMessage:@"获取数据失败"];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [MyEUtil showErrorOn:nil withMessage:@"与服务器通讯失败"];
}
#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            //这里也要进行手动控制面板的刷新
            UINavigationController *nav = self.tabBarController.childViewControllers[0];
            MyESwitchManualControlViewController *vc = nav.childViewControllers[0];
            vc.needRefresh = YES;
            [self uploadInfoToServer];
        }else
            [self.tableView reloadData];
    }
    if (alertView.tag == 110) {
        MyESwitchSchedule *schedule = self.control.SSList[_selectIndex.row];
        [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%i&scheduleId=%i&action=3",GetRequst(URL_FOR_SWITCH_SCHEDULE_SAVE),self.device.deviceId,schedule.scheduleId] andName:@"scheduleDelete"];
    }
}
@end
