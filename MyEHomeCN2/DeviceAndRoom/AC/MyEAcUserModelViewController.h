//
//  MyEAcUserModelControlViewController.h
//  MyEHome
//
//  Created by Ye Yuan on 10/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEAcUserModelViewController : UITableViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    NSTimer *timerToRefreshTemperatureAndHumidity;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (strong, nonatomic) IBOutlet UILabel *tempLabel;
@property (strong, nonatomic) IBOutlet UILabel *humidityLabel;

@end
