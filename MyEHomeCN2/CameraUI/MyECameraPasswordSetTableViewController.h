//
//  MyECameraPasswordSetTableViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-6-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserPwdProtocol.h"
#import "MyECamera.h"
#import "PPPPChannelManagement.h"
@interface MyECameraPasswordSetTableViewController : UITableViewController<UserPwdProtocol>
@property (nonatomic, weak) MyECamera *camera;
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@property (weak, nonatomic) IBOutlet UITextField *Pwdold;
@property (weak, nonatomic) IBOutlet UITextField *Pwdnew;
@property (weak, nonatomic) IBOutlet UITextField *Pwdnew1;

@end
