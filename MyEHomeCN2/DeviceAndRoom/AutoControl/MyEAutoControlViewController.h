//
//  MyEAcAutoControlViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/17/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MyEDataLoader.h"
#import "MyEAutoProcessViewController.h"
@class MyEAccountData;
@class MyEDevice;
@class MyEAutoControlProcessList;

@interface MyEAutoControlViewController : UIViewController <MyEDataLoaderDelegate,MBProgressHUDDelegate,MyEAcProcessViewControllerDelegate>{
    MBProgressHUD *HUD;
}
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, retain) MyEAutoControlProcessList *processList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *enableProcessSegmentedControl;

- (IBAction)enableProcessAction:(id)sender;
- (void)resetAddNewButtonWithAvailableDays;
@end
