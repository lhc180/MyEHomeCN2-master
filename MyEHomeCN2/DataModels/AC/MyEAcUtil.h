//
//  MyEAcUtils.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/11/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAcUtil : NSObject

// 下面几个是转换函数，给定数值，返回字符串表示。
+ (NSString *)getStringForPowerSwitch:(NSInteger)powerSwitch;
+ (NSString *)getStringForRunMode:(NSInteger)runMode;
+ (NSString *)getStringForSetpoint:(NSInteger)setpoint;
+ (NSString *)getStringForWindLevel:(NSInteger)windLevel;

+ (NSString *)getFilenameForRunMode:(NSInteger)runMode;
+(UIImage *)getImageForDeviceType:(NSInteger)deviceType;
@end
