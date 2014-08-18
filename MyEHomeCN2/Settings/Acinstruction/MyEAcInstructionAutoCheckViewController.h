//
//  MyEAcInstructionAutoCheckViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-25.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MyEDataLoader.h"
#import "MyEAcBrandsAndModels.h"
#import "MyEDevice.h"
#import "MyEUtil.h"
#import "MZFormSheetController.h"

@interface MyEAcInstructionAutoCheckViewController : UIViewController<MBProgressHUDDelegate,MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
//    NSTimer *timer;
    BOOL autoCheckStop;   //表示自动匹配是否停止    添加这个字段是为了标识程序是否继续进行
    BOOL manualSendInstruction;   //表示手动发送指令，那么只发送一条指令就停止，有别于自动匹配
    NSInteger failureTimes;  //失败次数，表示发送指令的时候失败的次数
    NSInteger _roundTimes;  //表示匹配过程中当前品牌匹配的第几轮。如果匹配了两轮，那么停止匹配
   
}

@property (nonatomic,strong) MyEDevice *device;
@property (nonatomic,strong) MyEAcBrandsAndModels *brandsAndModules;

@property (nonatomic,strong) NSArray *brandIdArray;//这个接收上面传过来的值
@property (nonatomic,strong) NSArray *brandNameArray;//这个接收上面传过来的值
@property (nonatomic,strong) NSArray *moduleIdArray;//这个是利用brand查找后得到的
@property (nonatomic,strong) NSArray *moduleNameArray;//这个是利用brand查找后得到的

@property (nonatomic) NSInteger brandIdIndex,moduleIdIndex;
@property (nonatomic) NSInteger startIndex;     //刚开始进入这个页面进行匹配时的model索引，当匹配过程中modelIndex的值再次等于_startIndex时，表示此时进行了一轮

@property (strong, nonatomic) IBOutlet UILabel *brandLabel;
@property (strong, nonatomic) IBOutlet UILabel *modelLabel;

@property (strong, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;


- (IBAction)startToCheck:(UIButton *)sender;
- (IBAction)stopToCheck:(UIButton *)sender;
- (IBAction)lastModule:(UIButton *)sender;
- (IBAction)nextModule:(UIButton *)sender;
- (IBAction)sendInstructionByUser:(UIButton *)sender;
- (IBAction)cancel:(UIButton *)sender;


@end
