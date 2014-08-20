//
//  MyESocketEditViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/13/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyESocketEditViewController : UIViewController
<MyEDataLoaderDelegate,MBProgressHUDDelegate,IQActionSheetPickerView>{
    MBProgressHUD *HUD;
    NSInteger btnTag;
    BOOL _isAdvanced;
    NSMutableArray *_roomArray,*_maxElecArray;
    NSDictionary *_initDic;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, strong) MyEDevice *device;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *roomBtn;
@property (weak, nonatomic) IBOutlet UIButton *maxCurrentBtn;

@property (nonatomic) NSInteger preivousPanelType;// 0表示登录后直接到设备面板在到此面板， 1表示从Rooms面板转移到设备再到此面板

@end
