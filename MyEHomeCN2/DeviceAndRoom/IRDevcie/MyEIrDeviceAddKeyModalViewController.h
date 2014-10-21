//
//  MyEIrDeviceAddKeyModalViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZFormSheetController.h"

@protocol MyEIrDeviceAddKeyModalViewControllerDelegate;

@interface MyEIrDeviceAddKeyModalViewController : UIViewController
<UITextFieldDelegate,MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) id <MyEIrDeviceAddKeyModalViewControllerDelegate> delegate;
@property (nonatomic, weak) MyEDevice *device;
@property (weak, nonatomic) IBOutlet UITextField *keyNameTextfield;

- (IBAction)confirmNewKey:(id)sender;

@end

@protocol MyEIrDeviceAddKeyModalViewControllerDelegate <NSObject>

@optional


@end