//
//  MYEACTemMonitorViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAcTempMonitor.h"


@interface MYEACTemMonitorViewController : UITableViewController
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, strong) MyEAcTempMonitor *acTempMonitor;
@end
