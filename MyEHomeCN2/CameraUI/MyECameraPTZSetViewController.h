//
//  MyECameraPTZSetViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-22.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyECamera.h"
#import "PPPPChannelManagement.h"

@interface MyECameraPTZSetViewController : UITableViewController
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@property (nonatomic, weak) MyECamera *camera;
@property (nonatomic, strong) MyECameraPTZ *ptz;
@property (nonatomic, assign) BOOL needRefresh;
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *allSwitchs;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *allLabels;

@end
