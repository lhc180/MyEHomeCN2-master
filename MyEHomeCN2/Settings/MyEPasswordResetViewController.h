//
//  MyEPasswordResetViewController.h
//  MyE
//
//  Created by Ye Yuan on 3/29/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEPasswordResetViewController : UITableViewController <UITextFieldDelegate, MyEDataLoaderDelegate> {
    MBProgressHUD *HUD;
}
@property(weak, nonatomic) MyEAccountData *accountData;

@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *npaswdTextField0;
@property (weak, nonatomic) IBOutlet UITextField *npaswdTextField1;

@end
