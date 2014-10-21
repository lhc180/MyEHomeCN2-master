//
//  MyESwitchElecInfoViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EColumnChart.h"
#import "MyEDevice.h"
#import "MBProgressHUD.h"
#import "MyESwitchElec.h"
#import "MyEDataLoader.h"

@interface MyESwitchElecInfoViewController : UIViewController<EColumnChartDataSource,MyEDataLoaderDelegate>{
    NSArray *_data;
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) MyEDevice *device;
@property (strong, nonatomic) MyESwitchElec *elecStatus;

@property (strong, nonatomic) EColumnChart *eColumnChart;

@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSegment;
@end
