//
//  MyEsettingsMediatorViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-31.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEQRScanViewController.h"

@interface MyEsettingsMediatorViewController : UIViewController<MBProgressHUDDelegate,MyEDataLoaderDelegate,MyEQRScanViewControllerDelegate>{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) MyEAccountData *accountData;

@property (nonatomic) NSInteger changeValue;// 1.表示用户已经删除了网关，需要重新绑定
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UILabel *midLabel;
@property (strong, nonatomic) IBOutlet WTReTextField *midTextField;
@property (strong, nonatomic) IBOutlet UILabel *changeLabel;
@property (strong, nonatomic) IBOutlet UITextField *pinTextField;
@property (strong, nonatomic) IBOutlet UILabel *onlineLabel;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;
@property (strong, nonatomic) IBOutlet UIButton *scanBtn;

@property (nonatomic) BOOL jumpFromSettings; //表示是从设置面板跳转过来的


- (IBAction)deleteOrBind:(UIButton *)sender;
@end
