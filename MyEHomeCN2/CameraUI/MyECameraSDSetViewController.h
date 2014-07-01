//
//  MyECameraSDSetViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-6-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPPChannelManagement.h"
#import "MyECamera.h"
#import "cmdhead.h"
#import "SdcardScheduleProtocol.h"
#import "SnapshotProtocol.h"
@interface MyECameraSDSetViewController : UITableViewController<SdcardScheduleProtocol,UIAlertViewDelegate>
@property (nonatomic, weak) MyECamera *camera;
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@property (weak, nonatomic) IBOutlet UILabel *totalLbl;
@property (weak, nonatomic) IBOutlet UILabel *delayLbl;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;

@end
