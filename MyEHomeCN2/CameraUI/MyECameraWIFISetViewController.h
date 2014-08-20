//
//  MyECameraWIFISetViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-6-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyECamera.h"
#import "PPPPChannelManagement.h"
#import "WifiParamsProtocol.h"
#import "MyECameraWIFIConnectViewController.h"
@interface MyECameraWIFISetViewController : UITableViewController<WifiParamsProtocol>
@property (weak, nonatomic) MyECamera *camera;
@property (nonatomic) CPPPPChannelManagement* m_PPPPChannelMgt;
@property (nonatomic, assign) BOOL needRefresh;
@end
