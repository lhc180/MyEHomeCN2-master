//
//  MyESubSwitchListViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-7-14.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyESubSwitchListViewController : UITableViewController<MyEDataLoaderDelegate>

@property(nonatomic, weak) MyESettings *settings;
@end