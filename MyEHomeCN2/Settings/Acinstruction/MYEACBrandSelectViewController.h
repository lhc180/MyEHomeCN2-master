//
//  MYEACBrandSelectViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/9/22.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAcBrandsAndModels.h"
#import "MyEDevice.h"

@interface MYEACBrandSelectViewController : UITableViewController

@property (nonatomic, weak) MyEAcBrandsAndModels *brandAndModels;
@property (nonatomic, weak) MyEAcBrand *brand;
@property (nonatomic, weak) MyEAcModel *model;
@property (nonatomic, weak) MyEDevice *device;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) BOOL isBrand;
@property (nonatomic, assign) BOOL isACInit;

@end
