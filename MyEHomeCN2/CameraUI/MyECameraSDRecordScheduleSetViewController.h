//
//  MyECameraSDRecordScheduleSetViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-25.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyECamera.h"
@interface MyECameraSDRecordScheduleSetViewController : UITableViewController
@property (nonatomic, weak) MyECameraSDSchedule *schedule;

@property (nonatomic, weak) IBOutlet UILabel *weekLbl;
@end
