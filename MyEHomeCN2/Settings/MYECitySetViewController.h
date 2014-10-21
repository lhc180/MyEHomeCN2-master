//
//  MYECitySetViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/9/25.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAcComfort.h"
#import "MyESettings.h"
#import "MyEProvinceAndCity.h"
#import "MYEHotel.h"


@interface MYECitySetViewController : UITableViewController

@property (nonatomic, weak) MyESettings *settings;   //
@property (nonatomic, weak) MyEAcComfort *comfort;  //
@property (nonatomic, strong) MyEProvinceAndCity *allCities;
@property (nonatomic, weak) MyEProvince *province;
@property (nonatomic, weak) MYEHotelDetail *hotelDetail;

@property (nonatomic, assign) BOOL isProvince;  //表示现在是选择省份

@end
