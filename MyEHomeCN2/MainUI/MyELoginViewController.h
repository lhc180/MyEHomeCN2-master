//
//  MyELoginViewController.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"
#import "WTReTextField.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@class MyEAccountData;

@interface MyELoginViewController : UIViewController <UITextFieldDelegate, MyEDataLoaderDelegate,CLLocationManagerDelegate,NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    CLLocationManager *_locationManager;
    CLLocation *_location;
    MBProgressHUD *HUD;
    BOOL _hadRunOneTime;
}

//特别注意此处中IBOutlet所形成的控件是weak属性，也就是说要对weak，strong，nonatomic等有明确的了解
@property (weak, nonatomic) IBOutlet WTReTextField *usernameInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
@property (strong, nonatomic) IBOutlet UIImageView *loginImage;
@property (weak, nonatomic) IBOutlet TableViewWithBlock *usersTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UIButton *showBtn;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;


@end
