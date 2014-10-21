//
//  MyESwitchScheduleSettingViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MyESwitchManualControlViewController.h"
#import "MYETimePicker.h"
#import "MultiSelectSegmentedControl.h"

@interface MyESwitchScheduleSettingViewController : UITableViewController<MultiSelectSegmentedControlDelegate,MyEDataLoaderDelegate,UIAlertViewDelegate,MYETimePickerDelegate>{
    MBProgressHUD *HUD;
    MyESwitchSchedule *_scheduleNew;
}

@property (weak, nonatomic) MyEDevice *device;
@property (strong, nonatomic) MyESwitchSchedule *schedule;
@property (strong, nonatomic) MyESwitchAutoControl *control;
@property (nonatomic) NSInteger actionType;  //1表示新增，2表示编辑

@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *channelSeg;
@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *weekSeg;

@end
