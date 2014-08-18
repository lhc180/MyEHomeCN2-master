//
//  MyEScenesViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyESceneDetailViewController.h"
#import "MyEscenesAddViewController.h"

@interface MyEScenesViewController : UITableViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *deleteSceneIndex;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, retain) MyESceneList *sceneList;
@property (nonatomic, retain) MyESceneInstructionRecived *instructionRecived;

@property (nonatomic, strong) NSMutableArray *scenesArray;

@end
