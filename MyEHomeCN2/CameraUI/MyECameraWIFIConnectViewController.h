//
//  MyECameraWIFIConnectViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-6-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyECamera.h"
#import "PPPPChannelManagement.h"
#import "MyECameraWIFISetViewController.h"
@interface MyECameraWIFIConnectViewController : UITableViewController
@property (weak, nonatomic) MyECameraWifi *wifi;
@property (nonatomic) CPPPPChannelManagement* m_PPPPChannelMgt;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end
