//
//  MyEAcPeriodViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/20/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MyEDataLoader.h"
@class MyEAutoControlPeriod;
@class MyEAccountData;
@class MyEDevice;
@class MyEAutoControlPeriod;

@protocol MyEAcPeriodViewControllerDelegate;

@interface MyEAutoPeriodViewController : UIViewController
<UITextFieldDelegate,MyEDataLoaderDelegate,MBProgressHUDDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    MBProgressHUD *HUD;
    NSInteger buttonTag;
    
    MyEAutoControlPeriod *period_copy;// 每次设置process时候，就拷贝一份，以便在每次返回此面板时，用来比较是否进程有变化，以便显示保存按钮，
    
    // 进行系统定义的指令补全验证的时候，用来保存从服务器获取的替换用的指令参数，然后在UIAlertView的代理回调函数里面使用
    NSInteger replaced_runMode;
    NSInteger replaced_setpoint;
    NSInteger replaced_windLevel;
}
@property (strong, nonatomic) id <MyEAcPeriodViewControllerDelegate> delegate;
@property (nonatomic, retain) MyEAutoControlPeriod *period;
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (weak, nonatomic) IBOutlet UIButton *timePeriodBtn;
@property (weak, nonatomic) IBOutlet UIButton *instructionButton;
@property (weak, nonatomic) IBOutlet UIView *pickerViewContainer;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic) BOOL isAddNew;

- (IBAction)timePeriodAction:(id)sender;
- (IBAction)instructionAction:(id)sender;
- (IBAction)hidePicker:(id)sender;
- (IBAction)saveAndReturnAction:(id)sender;
@end

@protocol MyEAcPeriodViewControllerDelegate <NSObject>

@optional
- (void)didFinishEditPeriod:(MyEAutoControlPeriod *)period isAddNew:(BOOL)flag; //这里面是传递一个时段，然后再传递一个是否新增的bool量
- (BOOL)isTimeFrameValidForPeriod:(MyEAutoControlPeriod *)period;

@end