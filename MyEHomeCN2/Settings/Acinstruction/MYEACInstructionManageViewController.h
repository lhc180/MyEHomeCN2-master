//
//  MYEACInstructionManageViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/9/22.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyEDevice.h"

@interface MYEACInstructionManageViewController : UITableViewController

@property (strong, nonatomic) MyEDevice *device;
@property (assign, nonatomic) NSInteger index;
@end
