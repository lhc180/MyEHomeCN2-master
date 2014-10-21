//
//  MyEPickerViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-16.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEProvinceAndCity.h"
@protocol MyECitySettingViewControllerDelegate <NSObject>

-(void)passProvince:(NSString *)province andCity:(NSString *)city;
@end

@interface MyECitySettingViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,MyEDataLoaderDelegate>

@property(nonatomic,strong) MyEProvinceAndCity *pAndC;

@property (strong, nonatomic) IBOutlet UIPickerView *picker;

@property(nonatomic,strong) id <MyECitySettingViewControllerDelegate> delegate;

@end
