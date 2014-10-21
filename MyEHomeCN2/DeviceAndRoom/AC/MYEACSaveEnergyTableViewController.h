//
//  MYEACSaveEnergyTableViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAcComfort.h"
#import "MyEDevice.h"


@interface MYEACSaveEnergyTableViewController : UITableViewController

@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, retain) MyEAcComfort *comfort;

@end
