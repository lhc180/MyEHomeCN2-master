//
//  MYEACInitStepViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/9/29.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAcBrandsAndModels.h"

@interface MYEACInitStepViewController : UITableViewController<MyEDataLoaderDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) MyEAcBrandsAndModels *brandAndModels;
@property (nonatomic,weak) MyEAcBrand *currentBrand;
@property (nonatomic,weak) MyEAcModel *currentModel;
@property (nonatomic,strong) MyEDevice *device;

@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) NSInteger step;  //1:选择品牌 2:开始下载 3:开始控制
@end
