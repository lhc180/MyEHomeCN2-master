//
//  MyESettingsViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-15.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyEUserNameResetViewController.h"
#import "MyEPasswordResetViewController.h"
#import "MyESettingFeedbackViewController.h"
#import "MyESettingsTerminalsViewController.h"
#import "MyESettingsMediatorViewController.h"
#import "MyESettings.h"
#import "MyEProvinceAndCity.h"

@interface MyESettingsViewController : UITableViewController<MyEDataLoaderDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIAlertViewDelegate>{
         MBProgressHUD *HUD;
}

@property(nonatomic, retain) MyESettings *settings;
@property(nonatomic, strong) MyEProvinceAndCity *pAndC;

@property(nonatomic, strong) NSString *provinceName;
@property(nonatomic, strong) NSString *cityName;
@property(nonatomic) BOOL needRefresh,isFresh;

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UISwitch *notification;

@property (strong, nonatomic) IBOutlet UILabel *cityLabel;

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *terminalsCount;
@property (weak, nonatomic) IBOutlet UILabel *subSwitchCount;

@end
