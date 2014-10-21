//
//  MyESafeDeviceControlViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDevice.h"

@interface MyESafeDeviceControlViewController : UIViewController<MyEDataLoaderDelegate>
@property (nonatomic, weak) MyEDevice *device;
@property (weak, nonatomic) IBOutlet UIButton *controlBtn;
@property (weak, nonatomic) IBOutlet UIButton *alarmBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLbl;

@end
