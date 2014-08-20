//
//  MyEAcAutoControlProcessListViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/17/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAutoProcessViewController.h"
@class MyEAccountData;
@class MyEDevice;
@class MyEAutoControlProcessList;

@interface MyEAutoProcessListViewController : UITableViewController <MyEDataLoaderDelegate,MBProgressHUDDelegate,MyEAcProcessViewControllerDelegate>{
    MBProgressHUD *HUD;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, weak) MyEAutoControlProcessList *processList;
@end
