//
//  MyEMainTabBarController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEAccountData.h"

//定义用于TabBar View上每个UITabBarItem的Tag标签序号
typedef enum {
    MYE_TAB_DEVICE_TYPE,
    MYE_TAB_ROOM,
    MYE_TAB_SCENE,
    MYE_TAB_SETTINGS
} MyETabBarItemType;

@interface MyEMainTabBarController : UITabBarController
@property (nonatomic) NSInteger selectedTabIndex;
@property (nonatomic, retain) MyEAccountData *accountData;

-(void)setTabbarButtonEnable:(BOOL)enable;

@end
