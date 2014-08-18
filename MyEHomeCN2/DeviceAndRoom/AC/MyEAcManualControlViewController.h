//
//  MyEDeviceAcViewController.h
//  MyEHome
//
//  Created by Ye Yuan on 10/8/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEAcManualControlViewController : UIViewController
<MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    NSTimer *timer;
    BOOL isBtnLocked; //表示锁定功能
    BOOL powerOn; //表示开关
    NSTimer *timerToRefreshTemperatureAndHumidity;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, weak) NSDictionary *statusDic;

@property (strong, nonatomic) IBOutlet UIImageView *runMode1;
@property (strong, nonatomic) IBOutlet UIImageView *runMode2;
@property (strong, nonatomic) IBOutlet UIImageView *runMode3;
@property (strong, nonatomic) IBOutlet UIImageView *runMode4;
@property (strong, nonatomic) IBOutlet UIImageView *runMode5;

@property (strong, nonatomic) IBOutlet UILabel *windLevel;
@property (strong, nonatomic) IBOutlet UILabel *windLevel0;
@property (strong, nonatomic) IBOutlet UIImageView *windLevel1;
@property (strong, nonatomic) IBOutlet UIImageView *windLevel2;
@property (strong, nonatomic) IBOutlet UIImageView *windLevel3;
@property (strong, nonatomic) IBOutlet UIImageView *runImage;
@property (strong, nonatomic) IBOutlet UILabel *runLabel;
@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *sheshiduLabel;

@property (strong, nonatomic) IBOutlet UILabel *homeHumidityLabel;
@property (strong, nonatomic) IBOutlet UILabel *homeTemperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *tipsLabel;

@property (strong, nonatomic) IBOutlet UILabel *lockLabel;
@property (strong, nonatomic) IBOutlet UIButton *powerBtn;
@property (strong, nonatomic) IBOutlet UIButton *lockBtn;
@property (strong, nonatomic) IBOutlet UIButton *temperaturePlusBtn;
@property (strong, nonatomic) IBOutlet UIButton *temperatureMinusBtn;
@property (strong, nonatomic) IBOutlet UIButton *modeBtn;
@property (strong, nonatomic) IBOutlet UIButton *windLevelBtn;
@property (strong, nonatomic) IBOutlet UIView *acControlView;

- (IBAction)poweOnOrOff:(UIButton *)sender;
- (IBAction)lock:(UIButton *)sender;
- (IBAction)temperaturePlus:(UIButton *)sender;
- (IBAction)temperatureMinus:(UIButton *)sender;
- (IBAction)runModeChange:(UIButton *)sender;
- (IBAction)windLevelChange:(UIButton *)sender;

-(void)refreshUI;


@end
