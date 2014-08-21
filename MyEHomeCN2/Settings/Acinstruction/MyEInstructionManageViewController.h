//
//  MyEInstructionManageViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-17.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEInstructionManageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) MyEAccountData *accountData;
@property (strong, nonatomic) MyEDevice *device;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectSeg;

@end
