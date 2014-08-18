//
//  MyESwitchAutoViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEScheduleCell.h"
#import "MyESwitchScheduleSettingViewController.h"
@interface MyESwitchAutoViewController : UITableViewController<MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
}
@property(strong, nonatomic) MyEDevice *device;
@property(strong, nonatomic) MyESwitchAutoControl *control;
@property(nonatomic) BOOL needRefresh;
@end
