//
//  MyEDelayTimeSetViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-5.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESwitchManualControl.h"
#import "MZFormSheetController.h"

@interface MyEDelayTimeSetViewController : UITableViewController<MyEDataLoaderDelegate,UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    NSMutableArray *_tableArray;
    NSInteger _selectedRow;
}
@property (nonatomic) NSIndexPath *index;
@property (weak, nonatomic) MyESwitchChannelStatus *status;
@property (nonatomic, strong) MyEDevice *device;
@property (nonatomic, strong) MyESwitchManualControl *control;
@property (nonatomic) NSInteger selectedBtnIndex;
@end
