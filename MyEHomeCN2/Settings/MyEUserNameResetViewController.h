//
//  MyEUserNameResetViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-29.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEUserNameResetViewController : UIViewController<MyEDataLoaderDelegate>

@property (strong, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) MyEAccountData *accountData;

@end
