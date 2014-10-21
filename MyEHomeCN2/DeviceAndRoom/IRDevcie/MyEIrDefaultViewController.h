//
//  MyEIrDefaultViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/4/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEIrStudyEditKeyModalViewController.h"
#import "MyEIrUserKeyViewController.h"
@interface MyEIrDefaultViewController : UIViewController<MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MBProgressHUD *progressHUD;
    NSMutableArray *_keyMap;
//    BOOL isControlMode;
    NSInteger secondsFromNow;
    NSTimer *timer;
    int valueChange; //用于表示音量和节目一共改变的值
}
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic) BOOL isControlMode;

@end
