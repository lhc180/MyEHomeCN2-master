//
//  MyESocketScheduleSettingViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-17.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYETimePicker.h"
#import "MultiSelectSegmentedControl.h"
#import "MyESwitchAutoControl.h"

@interface MyESocketScheduleSettingViewController : UITableViewController<MultiSelectSegmentedControlDelegate,MyEDataLoaderDelegate,MYETimePickerDelegate>{
    MBProgressHUD *HUD;
    MyESwitchSchedule *_scheduleNew;
}

@property (weak, nonatomic) MyEDevice *device;
@property (strong, nonatomic) MyESwitchSchedule *schedule;
@property (strong, nonatomic) MyESwitchAutoControl *control;
@property (nonatomic) NSInteger actionType;  //1表示新增，2表示编辑
@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *weekSeg;


@end
