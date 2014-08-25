//
//  MYEAppDelegate.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-8-15.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MYEAppDelegate : UIResponder <UIApplicationDelegate,UITextFieldDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *deviceTokenStr,*alias;
@property (assign, nonatomic) NSInteger dataLength; //用于摄像头传输时的速度

@end
