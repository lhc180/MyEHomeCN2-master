//
//  MyECameraAlarmViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-21.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPPChannelManagement.h"
#import "cmdhead.h"
#import "AlarmProtocol.h"
#import "MyECamera.h"
#import "MyECameraUsefullTableViewController.h"
@interface MyECameraAlarmViewController : UITableViewController<AlarmProtocol>
@property (nonatomic, strong) MyECameraAlarm *alarm;
@property (nonatomic, weak) MyECamera *camera;
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@property (nonatomic, assign) BOOL needRefresh;
@property (weak, nonatomic) IBOutlet UISwitch *motion_armedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *motion_sensitivityLbl;
@property (weak, nonatomic) IBOutlet UISwitch *input_armedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *ioin_levelLbl;
@property (weak, nonatomic) IBOutlet UILabel *ioout_levelLbl;
@property (weak, nonatomic) IBOutlet UISwitch *iolinkageSwitch;
@property (weak, nonatomic) IBOutlet UILabel *alarmpresetsitLbl;
@property (weak, nonatomic) IBOutlet UISwitch *recordSwitch;

@end
