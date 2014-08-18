//
//  MyESocketElecViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-5-13.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EColumnChart.h"

@interface MyESocketElecViewController : UIViewController<EColumnChartDataSource,MyEDataLoaderDelegate>{
    NSArray *_data;
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) MyEDevice *device;
@property (strong, nonatomic) MyESwitchElec *elecStatus;

@property (strong, nonatomic) EColumnChart *eColumnChart;

@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSegment;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;


@end
