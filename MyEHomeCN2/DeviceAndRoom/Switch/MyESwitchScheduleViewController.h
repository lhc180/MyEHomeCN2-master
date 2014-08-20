//
//  MyESwitchScheduleViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESwitchScheduleSettingViewController.h"
@interface MyESwitchScheduleViewController : UITableViewController<MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *_index;
}

@property(nonatomic,strong) MyEDevice *device;
@property(nonatomic,strong) MyESwitchAutoControl *control;
@end
