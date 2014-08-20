//
//  MyEDevicesViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/4/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEScenesViewController.h"
#import "MyESwitchEditViewController.h"
#import "MyESwitchElecInfoViewController.h"
#import "MyESwitchManualControlViewController.h"
#import "MyESwitchAutoViewController.h"
@interface MyEDevicesViewController : UITableViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *deleteDeviceIndex;
    UILongPressGestureRecognizer *longGesture;
    UITapGestureRecognizer *tapOnTableView;
    NSString *temperatureStr;
    NSString *humidityStr;
    NSIndexPath *_selectIndexPath;
}
@property (nonatomic, strong) MyEAccountData *accountData;
@property (nonatomic, strong) MyERoom *room;
@property (nonatomic, strong) MyEDevice *device;
@property (nonatomic, strong) NSMutableArray *devices; // 用于引用deviceType 或 room属性里面的对应的devices数组，这样以便于统一处理
@property (nonatomic) NSInteger preivousPanelType;// 0表示登录后直接到此设备面板， 1表示从Rooms面板转移到此设备面板
@property (nonatomic) NSInteger jumpFromMediator;
@property (nonatomic) BOOL needRefresh;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deviceAddBtn;

@end
