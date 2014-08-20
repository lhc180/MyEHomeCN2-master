//
//  MyESignupViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-31.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyESignupViewController : UIViewController<MBProgressHUDDelegate,MyEDataLoaderDelegate,ZBarReaderDelegate>{
    MBProgressHUD *HUD;
}
@property (retain, nonatomic) MyEAccountData *accountData;

@property (strong, nonatomic) IBOutlet WTReTextField *userName;

@property (strong, nonatomic) IBOutlet UITextField *passWord;
- (IBAction)scan:(UIButton *)sender;
- (IBAction)cancle:(UIBarButtonItem *)sender;

- (IBAction)registerToServer:(UIButton *)sender;

@end
