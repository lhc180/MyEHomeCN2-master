//
//  MyEAcInstructionStudyViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-21.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYEPickerView.h"
#import "MyEAcStudyInstruction.h"
#import "MyEAcStudyInstructionList.h"
#import "MyEDevice.h"
@interface MyEAcInstructionStudyViewController : UIViewController<MyEDataLoaderDelegate,MYEPickerViewDelegate,UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    UIView *pickerContainer;
    UIPickerView *picker;
    NSInteger studyQueryTimes;
    int powerValue;
    int modeValue;
    int windValue;
    int setpointValue;
    BOOL _isAdd; //当成功添加指令后，该值变为YES
}

@property (weak, nonatomic) MyEAcStudyInstructionList *list;
@property (strong, nonatomic) MyEAcStudyInstruction *instruction;
@property (strong, nonatomic) MyEDevice *device;

@property (nonatomic) NSInteger brandId;
@property (nonatomic) NSInteger moduleId;
@property (nonatomic,strong) NSIndexPath *index;

@property (strong, nonatomic) NSArray *powerArray;
@property (strong, nonatomic) NSArray *modeArray;
@property (strong, nonatomic) NSArray *windLevelArray;
@property (strong, nonatomic) NSArray *setpointArray;

@property (assign, nonatomic) BOOL jumpFromBarBtn;

@property (strong, nonatomic) IBOutlet UIButton *powerBtn;
@property (strong, nonatomic) IBOutlet UIButton *modeBtn;
@property (strong, nonatomic) IBOutlet UIButton *windLevelBtn;
@property (strong, nonatomic) IBOutlet UIButton *setpointBtn;
@property (strong, nonatomic) IBOutlet UIButton *studyBtn;
@property (strong, nonatomic) IBOutlet UIButton *checkBtn;



- (IBAction)power:(UIButton *)sender;
- (IBAction)mode:(UIButton *)sender;
- (IBAction)windLevel:(UIButton *)sender;
- (IBAction)setpoint:(UIButton *)sender;

- (IBAction)study:(UIButton *)sender;
- (IBAction)check:(UIButton *)sender;



@end
