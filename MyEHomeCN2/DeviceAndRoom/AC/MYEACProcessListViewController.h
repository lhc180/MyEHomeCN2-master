//
//  MYEACProcessListViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAutoControlProcessList.h"

@interface MYEACProcessListViewController : UITableViewController
@property (nonatomic, strong) MyEAutoControlProcessList *list;
@property (nonatomic, strong) MyEDevice *device;
@end
