//
//  MYEDeviceEditViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-9-12.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LeveyPopListView.h"
#import "MyEDataLoader.h"
#import "MyEUtil.h"
#import "MyEUniversal.h"
#import "MyEQRScanViewController.h"
#import "SBJson.h"
#import "MyEInstructionManageViewController.h"

#import "MyEAccountData.h"
#import "MyEDevice.h"
#import "MyEDeviceType.h"
#import "MyETerminal.h"
#import "MyERoom.h"
#import "MyEDeviceStatus.h"


@interface MYEDeviceEditViewController : UITableViewController<MyEDataLoaderDelegate,MyEQRScanViewControllerDelegate,UIAlertViewDelegate,LeveyPopListViewDelegate>

@property (strong, nonatomic) MyEDevice *device;

@property (nonatomic) NSInteger preivousPanelType;// 0表示登录后直接到设备面板在到此面板， 1表示从Rooms面板转移到设备再到此面板
@property (nonatomic) NSInteger actionType; // 0表示添加，1表示编辑

@property (nonatomic, assign) BOOL isAdd;

@end
