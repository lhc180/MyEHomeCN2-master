//
//  MyEACManualControlNavController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-19.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyEDevice.h"
@interface MyEACManualControlNavController : UINavigationController

@property(nonatomic,strong) MyEDevice *device;
@end
