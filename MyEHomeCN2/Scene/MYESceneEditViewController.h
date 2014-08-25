//
//  MYESceneEditViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-21.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEScenesDeviceEditOrAddViewController.h"

@interface MYESceneEditViewController : UITableViewController<MyEDataLoaderDelegate,MyEScenesDeviceEditOrAddViewControllerDelegate>

@property(nonatomic, strong) MyEScene *scene;
@property(nonatomic, weak) MyEAccountData *accountData;
@property(nonatomic, weak) MyESceneInstructionRecived *instructionRecived;

@property (nonatomic, assign) BOOL isAdd;
@property (weak, nonatomic) IBOutlet UITextField *nameTxt;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *orderBtn;

@end
