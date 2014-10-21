//
//  MyETerminalSettingViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-19.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyETerminalSettingViewController : UITableViewController<MyEDataLoaderDelegate,UIAlertViewDelegate>{
}

@property(nonatomic, strong) MyETerminal *terminal;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLbl;

@property (strong, nonatomic) IBOutlet UILabel *deviceType;
@property (strong, nonatomic) IBOutlet UILabel *deviceId;

@property (strong, nonatomic) IBOutlet UISwitch *saveModeSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *dataCollectSwitch;

@property (strong, nonatomic) IBOutlet UIImageView *signal;

@end
