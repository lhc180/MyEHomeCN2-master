//
//  MyEEditCameraViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/25/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyECamera.h"
#import "MyECameraWIFISetViewController.h"
#import "MyECameraPasswordSetTableViewController.h"
#import "MyECameraSDSetViewController.h"
@interface MyEEditCameraViewController : UITableViewController<UITextFieldDelegate,UIAlertViewDelegate,MyEDataLoaderDelegate>
@property (nonatomic, retain) MyECamera *camera;
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@property (weak, nonatomic) IBOutlet UILabel *UIDlbl;
@property (weak, nonatomic) IBOutlet UITextField *nameTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;

@end
