//
//  MyECameraAddNewViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-4-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyECamera.h"
@interface MyECameraAddNewViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtUID;
@property (nonatomic) BOOL cancelBtnClicked;
@property (weak, nonatomic) NSMutableArray *cameraList;
@property (weak, nonatomic) MyECamera *camera;
@property (nonatomic) NSInteger jumpFromWhere;  //1.WIFI搜索，2.二维码扫描，3.手动添加
@end
