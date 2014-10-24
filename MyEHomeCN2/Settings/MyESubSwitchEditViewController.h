//
//  MyESubSwitchEditViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-14.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MYEPickerView.h"
#import "MyESettings.h"
@interface MyESubSwitchEditViewController : UITableViewController<MyEDataLoaderDelegate,MYEPickerViewDelegate>
@property(nonatomic, strong) MyESettingSubSwitch *subSwitch;
@property(nonatomic, weak) MyEMediator *mediator;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTid;
@property (weak, nonatomic) IBOutlet UIImageView *imgSignal;
@property (weak, nonatomic) IBOutlet UILabel *lblMainTid;

@end
