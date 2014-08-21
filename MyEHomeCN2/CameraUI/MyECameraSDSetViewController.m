//
//  MyECameraSDSetViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-6-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraSDSetViewController.h"

@interface MyECameraSDSetViewController (){
    NSArray *_contents;
}

@end

@implementation MyECameraSDSetViewController

#pragma mark - lifecircle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_RECORD, NULL, 0);
    _m_PPPPChannelMgt->SetSDcardScheduleDelegate((char*)[_camera.UID UTF8String], self);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private method
-(void)refreshUI{
    NSString *statusStr = nil;
    if (_schedule.status == 0) {
        statusStr = @"没有插卡或者需要格式化";
    }else if (_schedule.status == 1){
        statusStr = @"停止录像";
    }else
        statusStr = @"正在录像...";

    self.totalLbl.text = [NSString stringWithFormat:@"%i",_schedule.total];
    self.delayLbl.text = [NSString stringWithFormat:@"%i",_schedule.remain];
    self.statusLbl.text = statusStr;
    [self.recordSwitch setOn:_schedule.fixedTimeRecord animated:YES];
    [self.tableView reloadData];
}

#pragma mark - IBAction method
-(IBAction)save:(UIBarButtonItem *)sender{
    NSInteger i = _m_PPPPChannelMgt->SetSDcardScheduleParams((char *)[_camera.UID UTF8String], _schedule.cover, _schedule.timeLength, _schedule.fixedTimeRecord, _schedule.sun_0, _schedule.sun_1, _schedule.sun_2,_schedule.mon_0, _schedule.mon_1, _schedule.mon_2, _schedule.tue_0, _schedule.tue_1, _schedule.tue_2, _schedule.wed_0, _schedule.wed_1, _schedule.wed_2, _schedule.thu_0, _schedule.thu_1, _schedule.thu_2, _schedule.fri_0, _schedule.fri_1, _schedule.fri_2, _schedule.sat_0, _schedule.sat_1, _schedule.sat_2);
    [MyEUtil showMessageOn:nil withMessage:i==1?@"设置成功":@"设置失败,请确认摄像机在线"];
}
-(IBAction)setRecordMode:(UISwitch *)sender{
    _schedule.fixedTimeRecord = sender.isOn;
    NSArray *array = @[@"sun",@"mon",@"tue",@"wed",@"thu",@"fri",@"sat"];
    for (int i =0; i<7; i++) {
        for (int j = 0; j < 3; j++) {
            [_schedule setValue:@(sender.isOn?-1:0) forKey:[NSString stringWithFormat:@"%@_%i",array[i],j]];
        }
    }
    [self.tableView reloadData];
}
#pragma mark - UITableView dataSource methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }else{
        return _schedule.fixedTimeRecord==1?1:2;
    }
}
#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定要格式化SD卡?" message:@"格式化操作后,SD卡里的数据会被全部删除,格式化操作大概需要20秒钟,请在20秒后刷新页面" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}
#pragma mark SdcardScheduleProtocol <NSObject>
-(void)sdcardScheduleParams:(NSString *)did Tota:(int)total/*SD卡总容量*/  RemainCap:(int)remain/*SD卡剩余容量*/ SD_status:(int)status/*1:停止录像 2:正在录像 0:未检测到卡*/ Cover:(int) cover_enable/*0:不自动覆盖1:自动覆盖 */ TimeLength:(int)timeLength/*录像时长*/ FixedTimeRecord:(int)ftr_enable/*0:未开启实时录像 1:开启实时录像*/ RecordSize:(int)recordSize/*录像总容量*/ record_schedule_sun_0:(int) record_schedule_sun_0 record_schedule_sun_1:(int) record_schedule_sun_1 record_schedule_sun_2:(int) record_schedule_sun_2 record_schedule_mon_0:(int) record_schedule_mon_0 record_schedule_mon_1:(int) record_schedule_mon_1 record_schedule_mon_2:(int) record_schedule_mon_2 record_schedule_tue_0:(int) record_schedule_tue_0 record_schedule_tue_1:(int) record_schedule_tue_1 record_schedule_tue_2:(int) record_schedule_tue_2 record_schedule_wed_0:(int) record_schedule_wed_0 record_schedule_wed_1:(int) record_schedule_wed_1 record_schedule_wed_2:(int) record_schedule_wed_2 record_schedule_thu_0:(int) record_schedule_thu_0 record_schedule_thu_1:(int) record_schedule_thu_1 record_schedule_thu_2:(int) record_schedule_thu_2 record_schedule_fri_0:(int) record_schedule_fri_0 record_schedule_fri_1:(int) record_schedule_fri_1 record_schedule_fri_2:(int) record_schedule_fri_2 record_schedule_sat_0:(int) record_schedule_sat_0 record_schedule_sat_1:(int) record_schedule_sat_1 record_schedule_sat_2:(int) record_schedule_sat_2{
    NSLog(@"Camera %@ SD Status total %d ....",did, total);
    NSLog(@"自动覆盖 %i 录像时长 %i 实时录像 %i 录像总容量 %i \nsun_0: %i sun_1: %i sun_2: %i \n mon_0 %i mon_1:%i mon_2:%i \nthur_0:%i thur_1:%i thur_2:%i",cover_enable,timeLength,ftr_enable,recordSize,record_schedule_sun_0,record_schedule_sun_1,record_schedule_sun_2,record_schedule_mon_0,record_schedule_mon_1,record_schedule_mon_2,record_schedule_thu_0,record_schedule_thu_1,record_schedule_thu_2);
    _schedule = [[MyECameraSDSchedule alloc] init];
    _schedule.total = total;
    _schedule.remain = remain;
    _schedule.status = status;
    _schedule.cover = cover_enable;
    _schedule.timeLength = timeLength;
    _schedule.fixedTimeRecord = ftr_enable;
    _schedule.recordSize = recordSize;
    _schedule.sun_0 = record_schedule_sun_0;
    _schedule.sun_1 = record_schedule_sun_1;
    _schedule.sun_2 = record_schedule_sun_2;
    _schedule.mon_0 = record_schedule_mon_0;
    _schedule.mon_1 = record_schedule_mon_1;
    _schedule.mon_2 = record_schedule_mon_2;
    _schedule.tue_0 = record_schedule_tue_0;
    _schedule.tue_1 = record_schedule_tue_1;
    _schedule.thu_2 = record_schedule_tue_2;
    _schedule.wed_0 = record_schedule_wed_0;
    _schedule.wed_1 = record_schedule_wed_1;
    _schedule.wed_2 = record_schedule_wed_2;
    _schedule.thu_0 = record_schedule_thu_0;
    _schedule.thu_1 = record_schedule_thu_1;
    _schedule.thu_2 = record_schedule_thu_2;
    _schedule.fri_0 = record_schedule_fri_0;
    _schedule.fri_1 = record_schedule_fri_1;
    _schedule.fri_2 = record_schedule_fri_2;
    _schedule.sat_0 = record_schedule_sat_0;
    _schedule.sat_1 = record_schedule_sat_1;
    _schedule.sat_2 = record_schedule_sat_2;
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
}
#pragma mark - Navigation method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *vc = segue.destinationViewController;
    [vc setValue:_schedule forKey:@"schedule"];
}
#pragma mark - UIAlertView delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSInteger i = _m_PPPPChannelMgt->GetCGI([_camera.UID UTF8String], CGI_IEFORMATSD);
        if (i == 1) {
            [MyEUtil showMessageOn:nil withMessage:@"正在格式化"];
        }else
            [MyEUtil showMessageOn:nil withMessage:@"格式化失败"];
    }
}
@end
