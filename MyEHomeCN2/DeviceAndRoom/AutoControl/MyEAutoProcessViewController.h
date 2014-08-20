//
//  MyEAcProcessViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiSelectSegmentedControl.h"
#import "MyEAutoPeriodViewController.h"
@class MyEAutoControlProcess;
@class MyEAccountData;
@class MyEDevice;
@protocol MyEAcProcessViewControllerDelegate;

@interface MyEAutoProcessViewController : UIViewController <MyEDataLoaderDelegate,MBProgressHUDDelegate,MultiSelectSegmentedControlDelegate, MyEAcPeriodViewControllerDelegate>{
    MyEAutoControlProcess *process_copy;// 每次设置process时候，就拷贝一份，以便在每次返回此面板时，用来比较是否进程有变化，以便显示保存按钮，
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) id <MyEAcProcessViewControllerDelegate> delegate;
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, retain) MyEAutoControlProcess *process;
@property (nonatomic, retain) NSArray *unavailableDays;
@property (nonatomic) BOOL isAddNew;

@property (weak, nonatomic) IBOutlet UIButton *saveProcessBtn;
@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *daySegmentedControl;
- (IBAction)saveProcessAction:(id)sender;

- (BOOL)decideIfProcessedChanged;
@end

@protocol MyEAcProcessViewControllerDelegate <NSObject>

@optional
- (void)didFinishEditProcess:(MyEAutoControlProcess *)process isAddNew:(BOOL)flag;

@end