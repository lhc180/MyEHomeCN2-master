//
//  MyEAcStandardInstructionViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
//MARK: 出现Cannot find protocol declaration这种错误，是因为头文件相互交叉导入造成的
//#import "MyEAcCustomInstructionViewController.h"
#import "MyEAcInstructionAutoCheckViewController.h"
#import "MyEInstructionManageViewController.h"
#import "KAProgressLabel.h"
#import "MyEAcBrandsAndModels.h"

@protocol MyEAcStandardInstructionViewControllerDelegate <NSObject>
//这个协议主要是用来向customVC中传值,之前是在tabbar内部传值，只需要找到目标VC即可，现在两个是没有联系的，只能通过代理传值
-(void)passValue:(MyEAcBrandsAndModels *)brand;

@end

@interface MyEAcStandardInstructionViewController : UIViewController<MBProgressHUDDelegate,MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
    NSInteger pickerTag;
    NSInteger requestTimes;
    NSInteger requestCircles;
    float progressLast;
    UIButton *cancelButton;
    KAProgressLabel *progressLabel;
    __block UIImageView *imageView;
    UITapGestureRecognizer *tapGestureToHideHUD;
    NSInteger acInitFailureTimes;
    NSTimer *timer;
    NSInteger _brandDownloadTimes;
}

@property(nonatomic,strong) MyEDevice *device;
@property(nonatomic,retain) MyEAcBrandsAndModels *brandsAndModels;
@property(strong, nonatomic) id <MyEAcStandardInstructionViewControllerDelegate> delegate;

@property(nonatomic,strong) NSArray *brandNameArray;
@property(nonatomic,strong) NSArray *brandIdArray;
@property(nonatomic,strong) NSArray *modelNameArray;
@property(nonatomic,strong) NSArray *modelIdArray;


@property (strong, nonatomic) IBOutlet UIButton *brandBtn;
@property (strong, nonatomic) IBOutlet UIButton *modelBtn;

- (IBAction)brandBtnPress:(UIButton *)sender;
- (IBAction)modelBtnPress:(UIButton *)sender;


- (IBAction)check:(UIButton *)sender;
- (IBAction)AcInit:(UIButton *)sender;

@end
