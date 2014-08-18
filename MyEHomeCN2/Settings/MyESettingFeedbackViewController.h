//
//  MyESettingFeedbackViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-23.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyESettingFeedbackViewController : UIViewController<MBProgressHUDDelegate,MyEDataLoaderDelegate,UITextViewDelegate>{
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *contentTextView;

@end
