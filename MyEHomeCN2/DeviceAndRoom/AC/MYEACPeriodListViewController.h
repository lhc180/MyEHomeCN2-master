//
//  MYEACPeriodListViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAutoControlProcessList.h"

@interface MYEACPeriodListViewController : UITableViewController

@property (nonatomic, strong) MyEDevice *device;
@property (nonatomic, strong) MyEAutoControlProcessList *list;
@property (nonatomic, strong) MyEAutoControlProcess *process;
@property (nonatomic, strong) NSArray *unavailableDays;

@property (nonatomic) BOOL isAddNew;

@end
