//
//  MyEAcComfortViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEAcEnergySavingViewController : UIViewController
<MyEDataLoaderDelegate,MBProgressHUDDelegate,
UIPickerViewDataSource,UIPickerViewDelegate,UINavigationBarDelegate>{
    MBProgressHUD *HUD;
    NSInteger buttonTag;
    NSMutableArray *_timeArray;
    BOOL _saveToExit;
    MyEAcComfort *_comfort_copy;// 每次设置comfort_copy时候，就拷贝一份，以便在每次返回此面板时，用来比较是否进程有变化，以便显示保存按钮，
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, retain) MyEAcComfort *comfort;

@property (weak, nonatomic) IBOutlet UISwitch *comfortFlagSwitch;
@property (weak, nonatomic) IBOutlet UIButton *riseTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *sleepTimeBtn;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (weak, nonatomic) IBOutlet UIView *overView;

@property (strong, nonatomic) UIView *pickerViewContainer;
@property (strong, nonatomic) UIPickerView *picker;

@end
