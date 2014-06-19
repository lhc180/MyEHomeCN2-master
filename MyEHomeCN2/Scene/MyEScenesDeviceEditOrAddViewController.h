//
//  MyEDeviceEditOrAddViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-4.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyEScenesDeviceEditOrAddViewControllerDelegate <NSObject>

-(void)passValue:(NSDictionary *)dic;  //新增设备时调用

-(void)refreshData:(NSDictionary *)dic byIndexPath:(NSIndexPath *)index;  //修改设备时调用

@end
@interface MyEScenesDeviceEditOrAddViewController : UIViewController<IQActionSheetPickerView,UITableViewDataSource,UITableViewDelegate>{
    NSInteger _selectedDeviceTypeIndex;//记录当前选择的设备类型在deviceTypeArray里面的序号
    NSInteger _selectedDeviceIndex;//记录当前选择的设备在deviceArray/deviceIdArray里面的序号
    NSInteger _selectedPowerIndex;//记录当前选择的power的序号
    NSInteger _selectedRunmodeIndex;//记录当前选择的Runmode的序号
    NSInteger _selectedWindlevelIndex;//记录当前选择的Windlevel的序号
    NSInteger _selectedSetpointIndex;//记录当前选择的Setpoint的序号

    MyESceneDevice *_scendDevice;// 记录当前选择的设备对应的场景设备
    
    NSMutableArray *_acArray;
    NSMutableArray *_tvArray;
    NSMutableArray *_audioArray;
    NSMutableArray *_otherArray;
    NSMutableArray *_curturnArray;
    NSMutableArray *_socketArray;
    NSMutableArray *_smartArray;
    
    NSInteger _deviceTypeIndex;
    MyEDevice *_device;

}
@property (weak, nonatomic) MyEAccountData *accountData;
@property (strong, nonatomic) MyEDeviceControl *deviceControl;
@property (weak, nonatomic) MyESceneInstructionRecived *instructionRecived;

@property (nonatomic, assign) id <MyEScenesDeviceEditOrAddViewControllerDelegate> delegate;

@property (nonatomic) NSInteger jumpFromBarBtn; //值为1时表示新增设备

@property (strong, nonatomic) NSIndexPath *sceneIndex;// 记录当前编辑的场景在场景列表里面的序号.

@property (nonatomic, strong) NSDictionary *dictionaryRecived;
@property (nonatomic, strong) NSArray *deviceIdArrayRecived;  //里面用于存放上一级传递过来的场景中所有设备的ID，用于重复性判断
@property (nonatomic, strong) NSMutableArray *tableArray;

@property (strong, nonatomic) IBOutlet UIButton *deviceTypeBtn;
@property (strong, nonatomic) IBOutlet UIButton *deviceBtn;
@property (strong, nonatomic) IBOutlet UIButton *powerBtn;
@property (strong, nonatomic) IBOutlet UIButton *windLevelBtn;
@property (strong, nonatomic) IBOutlet UIButton *modeBtn;
@property (strong, nonatomic) IBOutlet UIButton *temperatureBtn;

@property (strong, nonatomic) IBOutlet UILabel *powerLabel;
@property (strong, nonatomic) IBOutlet UILabel *windLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *modeLabel;
@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;


@property (strong, nonatomic) NSArray *deviceTypeArray,*deviceArray,*powerArray,*windLevelArray,*modeArray,*temperatureArray;
@property (strong, nonatomic) NSArray *instructionIdArray;
@property (strong, nonatomic) NSArray *deviceIdArray;
@property (strong, nonatomic) NSArray *deviceTypeNameArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveEditorBtn;

@end
