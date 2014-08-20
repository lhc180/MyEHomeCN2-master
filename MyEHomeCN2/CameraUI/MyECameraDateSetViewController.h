//
//  MyECameraDateSetViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-22.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPPChannelManagement.h"
#import "MyECamera.h"
#import "MyECameraUsefullTableViewController.h"

@interface MyECameraDateSetViewController : UITableViewController<DateTimeProtocol>
@property (nonatomic, weak) MyECamera *camera;
@property (nonatomic, strong) MyECameraDate *cameraDate;
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@property (nonatomic, assign) BOOL needRefresh;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeZoneLbl;
@property (weak, nonatomic) IBOutlet UISwitch *checkTimeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *timeServerLbl;

@end
