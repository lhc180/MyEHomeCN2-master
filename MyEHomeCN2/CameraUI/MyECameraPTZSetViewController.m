//
//  MyECameraPTZSetViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-22.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraPTZSetViewController.h"

@interface MyECameraPTZSetViewController ()

@end

@implementation MyECameraPTZSetViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _ptz = [[MyECameraPTZ alloc] init];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self refreshUI];
    }
}
#pragma mark - private methods
-(void)refreshUI{
    NSArray *switchValue = @[@(_ptz.led_mode),@(_ptz.center_onstart),@(_ptz.disable_preset)];
    NSArray *labelValue = @[@(_ptz.run_times),@(_ptz.patrol_rate),@(_ptz.patrol_up_rate),@(_ptz.patrol_down_rate),@(_ptz.patrol_left_rate),@(_ptz.patrol_right_rate),@(_ptz.preset)];
    for (int i=0; i < _allSwitchs.count; i++) {
        UISwitch *s = _allSwitchs[i];
        NSNumber *n = switchValue[i];
        [s setOn:n.boolValue animated:YES];
    }
    for (int i = 0; i < _allLabels.count; i++) {
        UILabel *l = _allLabels[i];
        NSNumber *n = labelValue[i];
        if (i == 0) {
            l.text = [_ptz run_timesArray][n.intValue];
        }else if (i == _allLabels.count - 1){
            l.text = [_ptz presetArray][n.intValue];
        }else
            l.text = [_ptz rateArray][n.intValue];
    }
    [self.tableView reloadData];
//    UISwitch *ledSwitch = _allSwitchs[0];
//    UISwitch *centerSwitch = _allSwitchs[1];
//    UISwitch *disableSwitch = _allSwitchs[2];
//    [ledSwitch setOn:_ptz.led_mode animated:YES];
//    [centerSwitch setOn:_ptz.center_onstart animated:YES];
//    [disableSwitch setOn:_ptz.disable_preset animated:YES];
//    UILabel *runTimesLbl = _allLabels[0];
//    UILabel *rateLbl = _allLabels[1];
//    UILabel *upLbl = _allLabels[2];
    
}

#pragma mark - UITableView delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
@end
