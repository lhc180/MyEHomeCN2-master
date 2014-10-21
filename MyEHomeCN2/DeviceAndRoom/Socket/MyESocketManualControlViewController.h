//
//  MyESocketManualControlViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYESocket.h"

@interface MyESocketManualControlViewController : UIViewController <MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
    NSTimer *_timer,*_timerToDownloadInfo;
}
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, strong) MYESocket *socket;

@property (weak, nonatomic) IBOutlet UILabel *currentPowerTipLbl;

@property (weak, nonatomic) IBOutlet UILabel *currentPowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;

@end
