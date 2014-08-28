//
//  MyESwitchManualControlViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-24.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDelayTimeSetViewController.h"
#import "MyESwitchAutoViewController.h"
#import "MYESwitchCell.h"
@interface MyESwitchManualControlViewController : UICollectionViewController<MyEDataLoaderDelegate>{
    MBProgressHUD *HUD;
    NSIndexPath *_selectedIndex;
    NSTimer *_timer;
//    NSMutableArray *_UIArray;  //里面存放的是每一组UI的具体内容，按照其tag升序放置
}
@property (strong, nonatomic) MyESwitchManualControl *control;
@property (strong, nonatomic) MyEDevice *device;
@property (nonatomic) BOOL needRefresh;
@end
