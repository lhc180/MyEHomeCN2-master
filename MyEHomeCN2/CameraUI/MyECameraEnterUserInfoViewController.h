//
//  MyECameraEnterUserInfoViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-4-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyECamera.h"
@interface MyECameraEnterUserInfoViewController : UIViewController<MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) NSMutableArray *cameraList;
@property (weak, nonatomic) MyECamera *camera;
@end
