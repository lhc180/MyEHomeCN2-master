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
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_CAMERA_PARAMS, NULL, 0);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_SNAPSHOT, NULL, 0);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_STATUS, NULL, 0);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refreshUI{
    self.totalLbl.text = _contents[0];
    self.delayLbl.text = _contents[1];
    self.statusLbl.text = _contents[2];
    [self.tableView reloadData];
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
    NSString *statusStr = nil;
    if (status == 0) {
        statusStr = @"没有插卡或者需要格式化";
    }else if (status == 1){
        statusStr = @"停止录像";
    }else
        statusStr = @"正在录像...";
    _contents = @[[NSString stringWithFormat:@"%i",total],[NSString stringWithFormat:@"%i",remain],statusStr];
    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:YES];
}
- (void) SnapshotNotify: (NSString*) strDID data:(char*) data length:(int) length{
    NSLog(@"UID:%@ length:%i",strDID,length);
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
