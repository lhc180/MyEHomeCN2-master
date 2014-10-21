//
//  MyESocketTimedControlViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYESocket.h"

@interface MyESocketTimedControlViewController : UIViewController <MyEDataLoaderDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    MBProgressHUD *HUD;
    NSInteger _stopTs;
    NSTimer *_timer;
    NSTimer *_timerToDownloadInfo;
    NSInteger _timingMinutes;//定时的分钟数目.
    BOOL _isTiming;
}
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, strong) MYESocket *socket;

@property (strong, nonatomic) IBOutlet UIButton *timerMinutesBtn;
@property (weak, nonatomic) IBOutlet UIButton *timerSwitchBtn;
@property (weak, nonatomic) IBOutlet UILabel *timerInfoLabel;

@property (weak, nonatomic) IBOutlet UIView *pickerViewContainer;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;


@end
