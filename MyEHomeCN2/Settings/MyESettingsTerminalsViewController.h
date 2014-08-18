//
//  MyETerminalsViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-18.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyESocketSettingsViewController.h"
#import "MyETerminalSettingViewController.h"
#import "MyEDevicesViewController.h"

@interface MyESettingsTerminalsViewController : UITableViewController<MBProgressHUDDelegate,MyEDataLoaderDelegate>
@property(nonatomic,weak) MyEAccountData *accountData;

@end
