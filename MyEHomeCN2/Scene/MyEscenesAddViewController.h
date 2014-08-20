//
//  MyEscenesAddViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-9.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEScenesDeviceEditOrAddViewController.h"

@interface MyEscenesAddViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MyEScenesDeviceEditOrAddViewControllerDelegate,MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) MyEAccountData *accountData;
@property (weak, nonatomic) MyESceneInstructionRecived *instructionRecived;

@property (strong, nonatomic) NSString *sceneName;
@property (strong, nonatomic) NSMutableArray *tableviewArray;

@property (strong, nonatomic) IBOutlet UISwitch *byOrderSwitch;
@property (strong, nonatomic) IBOutlet UILabel *sceneNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveEditorBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reorderBtn;

@end
