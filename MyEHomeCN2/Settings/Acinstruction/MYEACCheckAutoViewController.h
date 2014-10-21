//
//  MYEACCheckAutoViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/9.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAcBrand.h"
#import "MyEDevice.h"

@interface MYEACCheckAutoViewController : UIViewController
@property (nonatomic,strong) MyEAcBrand *brand;
@property (nonatomic,strong) MyEDevice *device;
@property (nonatomic,assign) NSInteger index;   //表示当前匹配到的型号位置
@property (nonatomic,assign) BOOL cancelBtnClicked;
@end
