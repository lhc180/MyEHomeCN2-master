//
//  MyECameraDateSetViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-22.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraDateSetViewController.h"

@interface MyECameraDateSetViewController ()

@end

@implementation MyECameraDateSetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _cameraDate = [[MyECameraDate alloc] init];
    _m_PPPPChannelMgt->SetDateTimeDelegate((char*)[_camera.UID UTF8String], self);
    _m_PPPPChannelMgt->PPPPSetSystemParams((char*)[_camera.UID UTF8String], MSG_TYPE_GET_PARAMS, NULL, 0);
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    _m_PPPPChannelMgt->SetDateTimeDelegate((char*)[_camera.UID UTF8String], nil);
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (_needRefresh) {
        _needRefresh = NO;
        [self refreshUI];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private methods
-(void)refreshUI{
    NSTimeInterval se=(long)_cameraDate.now;
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:se];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-_cameraDate.timeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.currentTimeLbl.text = [formatter stringFromDate:date];
    self.timeServerLbl.text = [_cameraDate timeServerArray][_cameraDate.timeServerIndex];
    [self.checkTimeSwitch setOn:_cameraDate.ntp_enable animated:YES];
    self.timeZoneLbl.text = [_cameraDate timeZoneArray][_cameraDate.timeZoneIndex];

    [self.tableView reloadData];
}
#pragma mark - IBAction methods
- (IBAction)timeCheck:(UISwitch *)sender {
    _cameraDate.ntp_enable = sender.isOn;
}
- (IBAction)saveEditor:(UIBarButtonItem *)sender {
    _cameraDate.ntp_svr = [_cameraDate timeServerArray][_cameraDate.timeServerIndex];
    _cameraDate.timeZone = [[_cameraDate timeZoneIdArray][_cameraDate.timeZoneIndex] intValue];
    NSInteger i = _m_PPPPChannelMgt->SetDateTime((char *)[_camera.UID UTF8String], _cameraDate.now, _cameraDate.timeZone, _cameraDate.ntp_enable, (char *)[_cameraDate.ntp_svr UTF8String]);
    [MyEUtil showMessageOn:nil withMessage:i==1?@"设置成功":@"设置失败"];
}

#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyECameraUsefullTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"usefull"];
    vc.cameraDate = _cameraDate;
    if (indexPath.row == 1) {
        vc.jumpValue = 5;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 3){
        vc.jumpValue = 6;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - DateTime protocol
-(void)DateTimeProtocolResult:(int)now tz:(int)tz ntp_enable:(int)ntp_enable net_svr:(NSString *)ntp_svr{
    //now: 1406012123  timezone: -28800  timeEnable: YES  timeserver: time.nist.gov
    _cameraDate.now = now;
    _cameraDate.timeZone = tz;
    _cameraDate.ntp_enable = ntp_enable;
    _cameraDate.ntp_svr = ntp_svr;
    NSLog(@"%@",_cameraDate);
    NSArray *array = [_cameraDate timeZoneIdArray];
    if ([array containsObject:@(_cameraDate.timeZone)]) {
        NSInteger i = [array indexOfObject:@(_cameraDate.timeZone)];
        _cameraDate.timeZoneIndex = i;
    }
    _cameraDate.timeServerIndex = [[_cameraDate timeServerArray] indexOfObject:_cameraDate.ntp_svr];

    [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
}
@end
