//
//  MYESettingsMediatorViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-19.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEQRScanViewController.h"

@interface MYESettingsMediatorViewController : UITableViewController<MyEDataLoaderDelegate,MyEQRScanViewControllerDelegate>

@property (weak, nonatomic) MyEAccountData *accountData;

//@property (nonatomic) NSInteger changeValue;// 1.表示用户已经删除了网关，需要重新绑定

@property (strong, nonatomic) IBOutlet UILabel *midLabel;
@property (strong, nonatomic) IBOutlet UILabel *changeLabel;

@property (strong, nonatomic) IBOutlet WTReTextField *midTextField;
@property (strong, nonatomic) IBOutlet UITextField *pinTextField;

@property (strong, nonatomic) IBOutlet UILabel *onlineLabel;

@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic) BOOL jumpFromSettings; //表示是从设置面板跳转过来的

@end
