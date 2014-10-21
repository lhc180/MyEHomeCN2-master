//
//  MYEACPeriodSetViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAutoControlProcessList.h"

@interface MYEACPeriodSetViewController : UITableViewController

@property (nonatomic, strong) MyEAutoControlProcess *process;
@property (nonatomic, strong) MyEAutoControlPeriod *period;
@property (nonatomic, strong) MyEDevice *device;
@property (nonatomic, assign) BOOL isAddNew;
@end
