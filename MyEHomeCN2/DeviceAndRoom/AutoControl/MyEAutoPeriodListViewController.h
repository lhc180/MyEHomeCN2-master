//
//  MyEAcPeriodListViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAutoPeriodViewController.h"
#import "MyEDevice.h"

@interface MyEAutoPeriodListViewController : UITableViewController <MyEAcPeriodViewControllerDelegate>
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, weak) NSMutableArray *periodList;
@end
