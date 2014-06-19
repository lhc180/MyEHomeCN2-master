//
//  MyESocketManualControlViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyESocketManualControlViewController : UIViewController
<MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    NSInteger _stopTs;
    NSTimer *_timer;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (weak, nonatomic) IBOutlet UILabel *currentPowerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *powerSwitch;
@property (weak, nonatomic) IBOutlet UILabel *timerInfoLabel;

@end
