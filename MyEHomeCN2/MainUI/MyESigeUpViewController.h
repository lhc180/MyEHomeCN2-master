//
//  MyESigeUpViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-25.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyESigeUpViewController : UIViewController<MyEQRScanViewControllerDelegate,MyEDataLoaderDelegate,UITextFieldDelegate>{
    MBProgressHUD *HUD;
    IBOutlet WTReTextField *userNameField;
    IBOutlet UITextField *passwoedField;
}

@property (strong, nonatomic) IBOutlet UIImageView *loginImage;
@property (strong, nonatomic) MyEAccountData *accountData;

- (IBAction)signUp:(id)sender;

@end
