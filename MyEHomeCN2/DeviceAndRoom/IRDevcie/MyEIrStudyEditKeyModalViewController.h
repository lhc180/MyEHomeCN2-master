//
//  MyEIrStudyEditKeyModalViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/3/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEIrDefaultViewController.h"


@interface MyEIrStudyEditKeyModalViewController : UIViewController<UITextFieldDelegate,MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    NSInteger studyQueryTimes;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, weak) MyEIrKey *key;
@property (weak, nonatomic) IBOutlet UITextField *keyNameTextfield;

@property (weak, nonatomic) IBOutlet UIButton *learnBtn;
@property (weak, nonatomic) IBOutlet UIButton *validateKeyBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteKeyBtn;

@end
