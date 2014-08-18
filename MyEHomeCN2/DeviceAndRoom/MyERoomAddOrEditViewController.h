//
//  MyERoomEditViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/13/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyERoomAddOrEditViewController : UIViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}
@property (nonatomic, weak) MyEAccountData *accountData;
@property (nonatomic, strong) MyERoom *room;
@property (nonatomic) NSInteger actionType;

@property (weak, nonatomic) IBOutlet UITextField *roomNameField;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic, strong) NSIndexPath *index;

- (IBAction)confirmAction:(id)sender;

@end
