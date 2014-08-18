//
//  MyESceneDetailViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-4.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEScenesDeviceEditOrAddViewController.h"
@interface MyESceneDetailViewController : UIViewController<MBProgressHUDDelegate,MyEDataLoaderDelegate,UITableViewDataSource,UITableViewDelegate,MyEScenesDeviceEditOrAddViewControllerDelegate>{
    MBProgressHUD *HUD;
    NSMutableArray *tableviewArray;
}

@property(nonatomic, strong) MyEScene *scene;
@property(nonatomic, weak) MyEAccountData *accountData;
@property(nonatomic, weak) MyESceneInstructionRecived *instructionRecived;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UISwitch *byOrder;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *applySceneBtn;

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveEditorBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reorderBtn;


@end
