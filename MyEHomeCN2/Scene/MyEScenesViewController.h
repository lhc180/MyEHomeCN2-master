//
//  MyEScenesViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYESceneEditViewController.h"
#import "MyESceneList.h"
#import "MyESceneDeviceInstruction.h"

@interface MyEScenesViewController : UITableViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *deleteSceneIndex;
}
@property (nonatomic, retain) MyESceneList *sceneList;
@property (nonatomic, retain) MyESceneInstructionRecived *instructionRecived;

@property (nonatomic, strong) NSMutableArray *scenesArray;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

@end
