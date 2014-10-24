//
//  MyESwitchManualControlViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-24.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESwitchAutoViewController.h"
#import "MYESwitchCell.h"
#import "MyESwitchManualControl.h"


@interface MyESwitchManualControlViewController : UITableViewController<MyEDataLoaderDelegate,UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *_selectedIndex;
    NSTimer *_timer;
}
@property (strong, nonatomic) MyESwitchManualControl *control;
@property (strong, nonatomic) MyEDevice *device;
@property (nonatomic) BOOL needRefresh;
@end
