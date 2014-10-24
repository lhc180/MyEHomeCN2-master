//
//  MyESwitchManualControlViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-24.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchManualControlViewController.h"
#import "MYEPickerView.h"

@interface MyESwitchManualControlViewController ()<MYEPickerViewDelegate>{
    NSInteger _delayTime;
}

@end

@implementation MyESwitchManualControlViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self downloadInfo];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self downloadInfo];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (_timer.isValid) {
        [_timer invalidate];
    }
}
#pragma mark - private methods
-(void)handleTimer:(NSTimer *)timer{
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li",GetRequst(URL_FOR_SWITCH_FIND_SWITCH_CHANNERL),(long)self.device.deviceId] postData:nil delegate:self loaderName:@"dowmloadChannelInfo" userDataDictionary:nil];
}
-(void)downloadInfo{
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li",GetRequst(URL_FOR_SWITCH_FIND_SWITCH_CHANNERL),(long)self.device.deviceId] andName:@"dowmloadChannelInfo" andDictionary:nil];
}
-(void)doThisToChangeStatus{
    MyESwitchChannelStatus *status = self.control.SCList[_selectedIndex.row];
    status.delayMinute = _delayTime;
    status.remainMinute = _delayTime;
    status.delayStatus = 1;
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?allChannel=%@",GetRequst(URL_FOR_SWITCH_TIME_DELAY_SAVE),[[MyESwitchChannelStatus alloc] jsonStringWithStatus:status]] andName:@"uploadDelayInfo" andDictionary:nil];
}
-(void)doThisWhenNeedDownLoadOrUploadInfoWithURLString:(NSString *)url andName:(NSString *)name andDictionary:(NSDictionary *)dic{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    NSLog(@"%@ string is %@",name,url);
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:dic];
    NSLog(@"%@ is %@",name,loader.name);
}
-(void)setDelayTimeWithStatus:(MyESwitchChannelStatus *)status{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:60];
    for (int i = 1; i <= 60; i++) {
        [array addObject:[NSString stringWithFormat:@"%i分钟",i]];
    }
    MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:1 title:@"请选择延时时间" dataSource:array andSelectRow:0];
    picker.delegate = self;
    [picker show];
//    //#warning 这里是精简至极的MZFormSheetController用法
//    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"timeDelay"];
//    MyEDelayTimeSetViewController *vc = nav.childViewControllers[0];
//    MZFormSheetController *formsheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(260, 294) viewController:nav];
//    //    vc.delegate = self;
//    vc.index = _selectedIndex;
//    vc.status = status;
//    vc.control = self.control;
//    vc.device = self.device;
//    formsheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
//        if (vc.selectedBtnIndex == 100) {  //说明是从确定按钮过来的
//            [self downloadInfo];
//            UINavigationController *nav = self.tabBarController.childViewControllers[1];
//            MyESwitchAutoViewController *vc = nav.childViewControllers[0];
//            vc.needRefresh = YES;
//        }
//    };
//    
//    [formsheet presentAnimated:YES completionHandler:nil];
}
-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//-(void)timeCount:(NSTimer *)timer{
//    UIButton *switchBtn = (UIButton *)timer.userInfo[0];
//    UILabel *remainTimeLabel = (UILabel *)timer.userInfo[1];
//    MyESwitchChannelStatus *status = self.control.SCList[[_UIArray indexOfObject:timer.userInfo]];
//    if (status.timerValue <= 0) {
//        [timer invalidate];
//        status.switchStatus = 0;
//        switchBtn.selected = YES;
//        remainTimeLabel.text = @"剩余:0分钟";
//    }else{
//        status.timerValue --;
//        remainTimeLabel.text = [NSString stringWithFormat:@"剩余:%i分钟",(int)status.timerValue/60];
//    }
//}
#pragma mark - UITableView dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.control.SCList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MYESwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell hide];
    MyESwitchChannelStatus *status = self.control.SCList[indexPath.row];
    cell.disable = status.disable;
    cell.lightOn = status.switchStatus;
    cell.timeOn = status.delayStatus;
    cell.timeSet = [NSString stringWithFormat:@"时长:%li分钟",(long)status.delayMinute];
    cell.timeDelay = [NSString stringWithFormat:@"剩余:约%li分钟",(long)status.remainMinute];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IS_IPAD?240:120;
}
#pragma mark - IBActionMethods
- (IBAction)switchControl:(MYEActiveBtn *)sender forEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:sender] anyObject];
    CGPoint location = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    MYESwitchCell *cell = (MYESwitchCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell show];
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];   //这里有两个方法来指定当前的collectionView
    //    NSIndexPath *indexPath = [(UICollectionView *)self.view.subviews[0] indexPathForCell:cell];
    MyESwitchChannelStatus *status = self.control.SCList[indexPath.row];
    _selectedIndex = indexPath;
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%li&switchStatus=%li&action=2",GetRequst(URL_FOR_SWITCH_CONTROL),(long)status.channelId,1-(long)status.switchStatus] postData:nil delegate:self loaderName:@"controlSwitch" userDataDictionary:@{@"status": status}];
}
- (IBAction)timeControl:(UIButton *)sender forEvent:(UIEvent *)event{
    UITouch *touch = [[event touchesForView:sender] anyObject];
    CGPoint location = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];

//    MYESwitchCell *cell = (MYESwitchCell *)sender.superview.superview;
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    _selectedIndex = indexPath;
    MyESwitchChannelStatus *status = self.control.SCList[_selectedIndex.row];
    if (!sender.selected) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定关闭该通道的延时设置么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 100;
        [alert show];
        return;
    }
    [self setDelayTimeWithStatus:status];
}
- (IBAction)refreshData:(UIBarButtonItem *)sender {
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li",GetRequst(URL_FOR_SWITCH_FIND_SWITCH_CHANNERL),(long)self.device.deviceId] andName:@"dowmloadChannelInfo" andDictionary:nil];
}

#pragma mark - url delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if ([name isEqualToString:@"dowmloadChannelInfo"]) {
        NSLog(@"dowmloadChannelInfo string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyESwitchManualControl *control = [[MyESwitchManualControl alloc] initWithString:string];
            self.control = control;
            
            //这里这么做是为了能够将数据保持一致,这里也不是必需这么写的
            NSMutableArray *array = [NSMutableArray array];
            for(MyESwitchChannelStatus *status in control.SCList){
                [array addObject:@(status.switchStatus)];
            }
            self.device.status.switchStatus = [NSMutableString stringWithString:[array componentsJoinedByString:@""]];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载数据时发生错误"];
        }
    }
    if ([name isEqualToString:@"controlSwitch"]) {
        NSLog(@"controlSwitch string is %@",string);
        MYESwitchCell *cell = (MYESwitchCell *)[self.tableView cellForRowAtIndexPath:_selectedIndex];
        [cell hide];
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            MyESwitchChannelStatus *status = dict[@"status"];
            status.switchStatus = 1 - status.switchStatus;
            if (status.switchStatus == 1) {
                status.remainMinute = status.delayMinute;
            }
            //下面这三句代码主要是为了更改switch在device列表中的状态，这样做的好处就是不需要刷新数据，就可以实时更改开关的状态了
            NSInteger i = [self.control.SCList indexOfObject:status];
            [self.device.status.switchStatus replaceCharactersInRange:NSMakeRange(i, 1)withString:[NSString stringWithFormat:@"%i",status.switchStatus]];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"开关控制失败"];
        }
    }
    if ([name isEqualToString:@"powerOffDelayTime"]) {
        NSLog(@"powerOffDelayTime string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 0) {
            [MyEUtil showMessageOn:nil withMessage:@"传入的数据有问题"];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"与服务器通讯失败"];
        }
    }
    if([name isEqualToString:@"checkIfRight"]){
        NSLog(@"checkIfRight string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设置延时的开关路数与启用的定时控制有冲突,确定需要保存么?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 101;
            [alert show];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 2) {
            [self doThisToChangeStatus];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"数据获取失败"];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 0) {
            [MyEUtil showMessageOn:nil withMessage:@"传入的数据有误"];
        }
    }
    if ([name isEqualToString:@"uploadDelayInfo"]) {
        NSLog(@"uploadDelayInfo string is %@",string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            [self downloadInfo];
            UINavigationController *nav = self.tabBarController.childViewControllers[1];
            MyESwitchAutoViewController *vc = nav.childViewControllers[0];
            vc.needRefresh = YES;
        }
        if ([MyEUtil getResultFromAjaxString:string] == -3) {
            [MyEUniversal doThisWhenUserLogOutWithVC:self];
        }
        if ([MyEUtil getResultFromAjaxString:string] == 0) {
            [MyEUtil showMessageOn:nil withMessage:@"上传数据有误"];
        }
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showMessageOn:nil withMessage:@"下载数据出错"];
        }
    }
    [self.tableView reloadData];  //任何情况下都要reloadData
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    MYESwitchCell *cell = (MYESwitchCell *)[self.tableView cellForRowAtIndexPath:_selectedIndex];
    [cell hide];
    [MyEUtil showMessageOn:nil withMessage:@"与服务器通讯失败"];
    [self.tableView reloadData];
}

#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        MyESwitchChannelStatus *status = self.control.SCList[_selectedIndex.row];
        status.delayStatus = 0;
        [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?allChannel=%@",GetRequst(URL_FOR_SWITCH_TIME_DELAY_SAVE),[[MyESwitchChannelStatus alloc] jsonStringWithStatus:status]] andName:@"powerOffDelayTime" andDictionary:nil];
    }
    if (alertView.tag == 101 && buttonIndex == 1) {
        [self doThisToChangeStatus];
    }
}
#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitle:(NSString *)title andRow:(NSInteger)row{
    _delayTime = row+1;
    [self doThisWhenNeedDownLoadOrUploadInfoWithURLString:[NSString stringWithFormat:@"%@?deviceId=%li&channels=%@&action=1",GetRequst(URL_FOR_SWITCH_TIME_DELAY),(long)self.device.deviceId,[NSString stringWithFormat:@"%i",_selectedIndex.row+1]] andName:@"checkIfRight" andDictionary:nil];
}
@end
