//
//  MyEIrControlPageViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-17.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SUNSlideSwitchView.h"
#import "MyEAudioDefaultViewController.h"
#import "MyETvDefaultViewController.h"
#import "MyEIrUserKeyViewController.h"
#import "MyEIrDefaultViewController.h"

@interface MyEIrControlPageViewController : UIViewController<SUNSlideSwitchViewDelegate,MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
}
@property (weak, nonatomic) IBOutlet SUNSlideSwitchView *slideSwitchView;

@property (nonatomic, strong) MyETvDefaultViewController *tvDefaultViewController;
@property (nonatomic, strong) MyEIrUserKeyViewController *irUserKeyViewController;
@property (nonatomic, strong) MyEAudioDefaultViewController *audioDefaultViewController;
@property (nonatomic, strong) MyEIrDefaultViewController *irDefaultViewController;

@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;

@end
