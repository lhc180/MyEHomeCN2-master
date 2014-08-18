//
//  MyECameraUsefullTableViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-21.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyECamera.h"
@interface MyECameraUsefullTableViewController : UITableViewController
@property (nonatomic, assign) NSInteger jumpValue;
@property (nonatomic, weak) MyECameraAlarm *alarm;
@property (nonatomic, weak) MyECameraDate *cameraDate;
@end
