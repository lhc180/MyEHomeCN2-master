//
//  MyESocketSettingsViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-22.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyESocketSettingsViewController : UITableViewController<MyEDataLoaderDelegate,UIAlertViewDelegate>

@property(nonatomic,weak) MyETerminal *terminal;

@property (strong, nonatomic) IBOutlet UILabel *deviceType;
@property (strong, nonatomic) IBOutlet UILabel *deviceId;
@property (strong, nonatomic) IBOutlet UIImageView *signalImage;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLbl;

@end
