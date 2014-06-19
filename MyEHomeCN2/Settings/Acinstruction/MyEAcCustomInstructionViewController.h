//
//  MyEAcCustomInstructionViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAcAddNewBrandAndModuleViewController.h"
#import "MyEAcStandardInstructionViewController.h"
#import "MyEAcInstructionListViewController.h"
#import "MyEInstructionManageViewController.h"
@class MyEAcBrandsAndModels;
@interface MyEAcCustomInstructionViewController : UIViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate,MyEAcStandardInstructionViewControllerDelegate,MyEAcInstructionListViewControllerDelegate,IQActionSheetPickerView>{
    MBProgressHUD *HUD;
    NSTimer *timer;
    UITapGestureRecognizer *tapGestureToHideHUD;
    BOOL deleteToDownload; //删除后刷新数据
    NSInteger requestTimes;
    NSInteger requestCircles;
    float progressLast;
    NSInteger acInitFailureTimes;
    UIButton *cancelButton;
    KAProgressLabel *progressLabel;
    __block UIImageView *imageView;
    int _selectBrandIndex,_selectModelIndex,_brandDownloadTimes;
}
@property(nonatomic,weak) MyEAccountData *accountData;
@property(nonatomic,strong) MyEDevice *device;
@property(nonatomic,weak) MyEAcBrandsAndModels *brandsAndModels;
@property(nonatomic,strong) NSMutableArray *brandNameArray;
@property(nonatomic,strong) NSMutableArray *brandIdArray;
@property(nonatomic,strong) NSMutableArray *modelNameArray;
@property(nonatomic,strong) NSMutableArray *modelIdArray;

@property (nonatomic) BOOL jumpFromInstructionList;

@property (strong, nonatomic) IBOutlet UIButton *brandBtn;
@property (strong, nonatomic) IBOutlet UIButton *modelBtn;
@property (strong, nonatomic) IBOutlet UIButton *deleteBrandAndModelBtn;
@property (strong, nonatomic) IBOutlet UIButton *downloadBtn;
@property (strong, nonatomic) IBOutlet UIButton *editInstructionBtn;


- (IBAction)brandBtnPress:(UIButton *)sender;
- (IBAction)modelBtnPress:(UIButton *)sender;

- (IBAction)deleteBrandAndModel:(UIButton *)sender;
- (IBAction)addBrandAndModel:(UIButton *)sender;

- (IBAction)downloadInstruction:(UIButton *)sender;

@end
