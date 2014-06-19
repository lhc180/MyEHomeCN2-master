//
//  MyEDeviceAddOrEditViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/13/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEInstructionManageViewController.h"
#import "MyEDevicesViewController.h"

@interface MyEDeviceAddOrEditViewController : UIViewController<UITextFieldDelegate,MyEDataLoaderDelegate,MBProgressHUDDelegate,IQActionSheetPickerView>{
    MBProgressHUD *HUD;
    NSMutableArray *_terminalArray;// 所有的智控星的列表
    NSMutableArray *_validTypeArray;// 插座/开关这两个类型是不能在App添加的, 今后有可能又更多类型不能在App添加.
    NSArray *_terminalArrayForAc; // 为添加或修改空调设备而准备的有效智控性列表. 已经被其他空调设备占用的智控星不在次数组中.
    NSDictionary *_initDic;  //这里使用字典对初始值和后来更改的值进行比较，用于判断【保存】btn是否可以被点击
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, strong) MyEDevice *device; //设备编辑肯定是要传过来一个device了
@property (nonatomic, strong) MyEDevice *deviceNew;
@property (nonatomic, weak) MyERoom *room;  //当为从房间跳转过来是，传递此值

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *terminalBtn;
@property (weak, nonatomic) IBOutlet UIButton *roomBtn;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;
@property (weak, nonatomic) IBOutlet UIButton *brandBtn;

@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (nonatomic) NSInteger preivousPanelType;// 0表示登录后直接到设备面板在到此面板， 1表示从Rooms面板转移到设备再到此面板
@property (nonatomic) NSInteger actionType; // 0表示添加，1表示编辑

@property (weak, nonatomic) IBOutlet UIButton *downloadInstructionBtn;

- (IBAction)confirmAction:(id)sender;

@end
