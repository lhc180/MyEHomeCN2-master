//
//  MyECameraLandscapeViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "PPPPChannelManagement.h"
#import "MyECamera.h"

@interface MyECameraLandscapeViewController : UIViewController
@property (nonatomic) CPPPPChannelManagement* m_PPPPChannelMgt;
@property (nonatomic, weak) MyECamera *camera;
@end
