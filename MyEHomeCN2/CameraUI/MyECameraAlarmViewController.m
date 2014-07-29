//
//  MyECameraAlarmViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-21.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraAlarmViewController.h"

@interface MyECameraAlarmViewController ()

@end

@implementation MyECameraAlarmViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _alarm = [[MyECameraAlarm alloc] init];
    _m_PPPPChannelMgt->SetAlarmDelegate((char*)[_camera.UID UTF8String], self);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_PARAMS, NULL, 0);
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self refreshUI];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    _m_PPPPChannelMgt->SetAlarmDelegate((char*)[_camera.UID UTF8String], nil);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)refreshUI{
    [self.motion_armedSwitch setOn:_alarm.motion_armed animated:YES];
    self.motion_sensitivityLbl.text = [_alarm motion_sensitivityArray][[_alarm getMotion_sensitivity]];
//    self.motion_sensitivityLbl.text = [_alarm motion_sensitivityArray][_alarm.motion_sensitivity];
    [self.input_armedSwitch setOn:_alarm.input_armed animated:YES];
    self.ioin_levelLbl.text = [_alarm ioin_levelArray][_alarm.ioin_level];
    self.alarmpresetsitLbl.text = [_alarm alarmpresetsitArray][_alarm.alarmpresetsit];
    [self.iolinkageSwitch setOn:_alarm.iolinkage animated:YES];
    self.ioout_levelLbl.text = [_alarm ioout_levelArray][_alarm.ioout_level];
    [self.recordSwitch setOn:_alarm.record animated:YES];
    [self.tableView reloadData];
}
#pragma mark - IBAction methods
- (IBAction)changValue:(UISwitch *)sender {
    NSInteger i = sender.tag;
    if (i == 100) {  //移动侦测布防
        _alarm.motion_armed = sender.isOn;
    }else if (i == 101){
        _alarm.input_armed = sender.isOn;
    }else if (i == 102){
        _alarm.iolinkage = sender.isOn;
    }else{
        _alarm.record = sender.isOn;
    }
}

- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    int result = _m_PPPPChannelMgt->SetAlarm((char *)[_camera.UID UTF8String], _alarm.motion_armed, _alarm.motion_sensitivity, _alarm.input_armed, _alarm.ioin_level, _alarm.alarmpresetsit, _alarm.iolinkage, _alarm.ioout_level, _alarm.mail, _alarm.upload_interval, _alarm.record);
    if (result == 1) {
        [MyEUtil showMessageOn:nil withMessage:@"设置成功"];
    }else
        [MyEUtil showMessageOn:nil withMessage:@"设置失败"];
}

#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyECameraUsefullTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"usefull"];
    vc.alarm = self.alarm;
    if (indexPath.row == 1) {
        vc.jumpValue = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 3){
        vc.jumpValue = 2;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 4){
        vc.jumpValue = 3;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 6){
        vc.jumpValue = 4;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - alarm protocol
-(void)AlarmProtocolResult:(int)motion_armed motion_sensitivity:(int)motion_sensitivity input_armed:(int)input_armed ioin_level:(int)ioin_level alarmpresetsit:(int)alarmpresetsit iolinkage:(int)iolinkage ioout_level:(int)ioout_level mail:(int)mail snapshot:(int)snapshot upload_interval:(int)upload_interval record:(int)record{
    NSLog(@"获取数据成功");
    _alarm.motion_armed = motion_armed;
    _alarm.motion_sensitivity = motion_sensitivity;
    _alarm.input_armed = input_armed;
    _alarm.ioin_level = ioin_level;
    _alarm.alarmpresetsit = alarmpresetsit;
    _alarm.iolinkage = iolinkage;
    _alarm.ioout_level = ioout_level;
    _alarm.record = record;
    _alarm.mail = mail;
    _alarm.snapshot = snapshot;
    _alarm.upload_interval = upload_interval;
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:YES];
}
@end
