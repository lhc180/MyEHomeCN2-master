//
//  MyEAcTempMonitorViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/24/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEAcTempMonitorViewController : UIViewController
<MyEDataLoaderDelegate,MBProgressHUDDelegate,IQActionSheetPickerView,UINavigationBarDelegate>{
    MBProgressHUD *HUD;
    NSInteger buttonTag;
    MyEAcTempMonitor *_acTempMonitor_copy;// 每次设置ac_monitor_copy时候，就拷贝一份，以便在每次返回此面板时，用来比较是否进程有变化，以便显示保存按钮，
    NSMutableArray *lowTempArray;
    NSMutableArray *highTempArray;
    BOOL _saveToExit;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, retain) MyEAcTempMonitor *acTempMonitor;

@property (weak, nonatomic) IBOutlet UISwitch *enableTempMonitorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableAcAutoRunSwitch;

@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (weak, nonatomic) IBOutlet UIButton *lowTemBtn;
@property (weak, nonatomic) IBOutlet UIButton *highTemBtn;


- (IBAction)tempMonitorSwitchChanged:(id)sender;
- (IBAction)acAutoRunSwitch:(id)sender;


@end
