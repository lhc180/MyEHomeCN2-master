//
//  MyESafeDeviceEditViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-6.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyESafeDeviceEditViewController : UIViewController<MyEDataLoaderDelegate,IQActionSheetPickerView>
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, weak) MyEAccountData *accountData;
@property (weak, nonatomic) IBOutlet UITextField *nameTxt;
@property (weak, nonatomic) IBOutlet UIButton *roomBtn;
@property (weak, nonatomic) IBOutlet UILabel *idLbl;
@property (weak, nonatomic) IBOutlet UILabel *typeLbl;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end
