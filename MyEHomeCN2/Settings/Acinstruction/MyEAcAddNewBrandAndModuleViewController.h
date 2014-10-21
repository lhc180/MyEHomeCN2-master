//
//  MyEAcAddNewBrandAndModuleViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-21.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZFormSheetController.h"
#import "MyEAcCustomInstructionViewController.h"
#import "MyEAcInstructionListViewController.h"
#import "MyEAcBrandsAndModels.h"

@interface MyEAcAddNewBrandAndModuleViewController : UIViewController<MBProgressHUDDelegate,MyEDataLoaderDelegate,UITextFieldDelegate>{
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) MyEAcBrandsAndModels *brandsAndModules;
@property (weak, nonatomic) MyEDevice *device;

@property (strong, nonatomic) MyEAcBrand *brandNew;
@property (strong, nonatomic) MyEAcModel *modelNew;


//@property (strong, nonatomic) NSArray *modelNameArray;
//@property (strong, nonatomic) NSArray *brandNameArray;
//@property (assign, nonatomic) NSInteger jumpFromAddBtn;
//
//@property (assign, nonatomic) NSInteger brandId;
//@property (assign, nonatomic) NSInteger moduleId;
//
//@property (assign, nonatomic) NSInteger newBrandId;
//@property (assign, nonatomic) NSInteger newModuleId;

@property (nonatomic) BOOL cancelBtnPressed;
@property (strong, nonatomic) IBOutlet UITextField *brandName;
@property (strong, nonatomic) IBOutlet UITextField *moduleName;

@property (strong, nonatomic) IBOutlet UIButton *saveBtn;

@end
