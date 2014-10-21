//
//  MYEHotelSetDetailViewController.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/15.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYEHotel.h"

@interface MYEHotelSetDetailViewController : UITableViewController

@property (nonatomic, weak) MYEHotel *hotel;
@property (nonatomic, weak) MYEHotelDetail *detail;
@property (nonatomic, assign) NSInteger type;  // 0表示选择酒店  1表示选择房间  2表示选择终端
@property (nonatomic, assign) NSInteger index;
@end
