//
//  MyETvUserViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/31/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEIrDeviceAddKeyModalViewController.h"
#import "MyEIrStudyEditKeyModalViewController.h"
@interface MyEIrUserKeyViewController : UITableViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate, MyEIrDeviceAddKeyModalViewControllerDelegate>{
    MBProgressHUD *HUD;
    NSTimer *tapTimer;
    NSInteger tapCount;
    NSInteger tappedRow;

}
// Just for regular ir device(not TV and Audio, which has system default template panel), to tell the VC download key set after viewDidLoad
@property (nonatomic) BOOL needDownloadKeyset;
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic) BOOL jumpFromTv;
@property (nonatomic) BOOL jumpFromCurtain;
@property (nonatomic) BOOL isControlMode;

- (IBAction)addNewKey:(id)sender;
- (void) downloadKeySetFromServer;

@end
