//
//  MyEAcInstructionListViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-21.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAcInstructionListCell.h"
@class MyEAcStudyInstructionList;

@protocol MyEAcInstructionListViewControllerDelegate <NSObject>

-(void)refreshData:(BOOL)yes;

@end

@interface MyEAcInstructionListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *deleteInstructionIndex;
}

@property (nonatomic, weak) id <MyEAcInstructionListViewControllerDelegate> delegate;
@property (strong, nonatomic) MyEAccountData *accountData;
@property (strong, nonatomic) MyEDevice *device;
@property (retain, nonatomic) MyEAcStudyInstructionList *list;

@property (nonatomic) NSInteger moduleId; //下载指令的时候只需要这个值
@property (nonatomic) NSInteger brandId;
@property (nonatomic) BOOL jumpFromEditBtn;
@property (nonatomic,strong) NSString *labelText;
@property (strong, nonatomic) IBOutlet UILabel *brandAndModuleLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSMutableArray *tableviewArray;

- (IBAction)addNewInstruction:(UIBarButtonItem *)sender;

@end
