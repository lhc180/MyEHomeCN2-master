//
//  MyECameraUsefullTableViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-21.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraUsefullTableViewController.h"
#import "MyECameraAlarmViewController.h"
#import "MyECameraDateSetViewController.h"
@interface MyECameraUsefullTableViewController (){
    NSArray *_data;
}

@end

@implementation MyECameraUsefullTableViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_jumpValue == 1) {  //移动侦测灵敏度
        _data = [_alarm motion_sensitivityArray];
    }else if (_jumpValue == 2){ // 触发方式
        _data = [_alarm ioin_levelArray];
    }else if (_jumpValue == 3){ //预置位联动
        _data = [_alarm alarmpresetsitArray];
    }else if (_jumpValue == 4){ // 输出电平
        _data = [_alarm ioout_levelArray];
    }else if (_jumpValue == 5){  //摄像头选择时区
        _data = [_cameraDate timeZoneArray];
    }else if (_jumpValue == 6){  //摄像头选择自动获取时间的服务器
        _data = [_cameraDate timeServerArray];
    }
    self.tableView.tableFooterView = [[UIView alloc] init];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    UIViewController *vc = self.navigationController.childViewControllers[self.navigationController.childViewControllers.count-1];
    if ([vc isKindOfClass:[MyECameraAlarmViewController class]]) {
        MyECameraAlarmViewController *alarmVC = (MyECameraAlarmViewController *)vc;
        alarmVC.needRefresh = YES;
    }
    if ([vc isKindOfClass:[MyECameraDateSetViewController class]]) {
        MyECameraDateSetViewController *date = (MyECameraDateSetViewController *)vc;
        date.needRefresh = YES;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = _data[indexPath.row];
    if (_jumpValue == 5) {
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    if ((_jumpValue == 1 && indexPath.row == [_alarm getMotion_sensitivity]) ||
        (_jumpValue == 2 && indexPath.row == _alarm.ioin_level) ||
        (_jumpValue == 3 && indexPath.row == _alarm.alarmpresetsit) ||
        (_jumpValue == 4 && indexPath.row == _alarm.ioout_level) ||
        (_jumpValue == 5 && indexPath.row == _cameraDate.timeZoneIndex) ||
        (_jumpValue == 6 && indexPath.row == _cameraDate.timeServerIndex)) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_jumpValue == 1) {
//        _alarm.motion_sensitivity = indexPath.row;
        if (indexPath.row == 0) {
            _alarm.motion_sensitivity = 1;
        }else if (indexPath.row == 1){
            _alarm.motion_sensitivity = 5;
        }else
            _alarm.motion_sensitivity = 10;
    }else if (_jumpValue == 2){
        _alarm.ioin_level = indexPath.row;
    }else if (_jumpValue == 3){
        _alarm.alarmpresetsit = indexPath.row;
    }else if (_jumpValue == 4){
        _alarm.ioout_level = indexPath.row;
    }else if (_jumpValue == 5){
        _cameraDate.timeZoneIndex = indexPath.row;
    }else if (_jumpValue == 6){
        _cameraDate.timeServerIndex = indexPath.row;
    }
    [tableView reloadData];
}
@end
