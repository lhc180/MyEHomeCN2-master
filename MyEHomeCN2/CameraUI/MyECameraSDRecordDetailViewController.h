//
//  MyECameraSDRecordDetailViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-22.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPPChannelManagement.h"
#import "MyECamera.h"
@interface MyECameraSDRecordDetailViewController : UITableViewController
@property (nonatomic, weak) NSDictionary *dic;
@property (nonatomic, weak) MyECamera *camera;
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@end
