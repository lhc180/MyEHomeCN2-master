//
//  MyEACUtils.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/11/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcUtil.h"

@implementation MyEAcUtil

+ (NSString *)getStringForPowerSwitch:(NSInteger)powerSwitch
{
    if (powerSwitch == 1) {
        return @"开";
    }else return @"关";
}
+ (NSString *)getStringForRunMode:(NSInteger)runMode
{
    switch (runMode) {
        case 1:
            return @"自动";
            break;
        case 2:
            return @"制热";
            break;
        case 3:
            return @"制冷";
            break;
        case 4:
            return @"除湿";
            break;
        case 5:
            return @"通风";
            break;
        default:
            return @"自动";
            break;
    }
}
+ (NSString *)getStringForSetpoint:(NSInteger)setpoint
{
    return [NSString stringWithFormat:@"%ld℃",(long)setpoint];
}
+ (NSString *)getStringForWindLevel:(NSInteger)windLevel
{
    switch (windLevel) {
        case 0:
            return @"自动";
            break;
        case 1:
            return @"一级";
            break;
        case 2:
            return @"二级";
            break;
        case 3:
            return @"三级";
            break;
        default:
            return @"自动";
            break;
    }
}


+ (NSString *)getFilenameForRunMode:(NSInteger)runMode
{
    switch (runMode) {
        case 1:
            return @"run1";
            break;
        case 2:
            return @"run2";
            break;
        case 3:
            return @"run3";
            break;
        case 4:
            return @"run4";
            break;
        case 5:
            return @"run5";
            break;
        default:
            return @"run1";
            break;
    }
}
+(UIImage *)getImageForDeviceType:(NSInteger)deviceType
{
    switch (deviceType) {
        case DT_AC:
            return [UIImage imageNamed:@"ac-off"];
            break;
        case DT_TV:
            return [UIImage imageNamed:@"tv-off"];
            break;
        case DT_CURTAIN:
            return [UIImage imageNamed:@"curtain-off"];
            break;
        case DT_AUDIO:
            return [UIImage imageNamed:@"audio-off"];
            break;
        case DT_SOCKET:
            return [UIImage imageNamed:@"socket-off"];
            break;
        case DT_OTHER:
            return [UIImage imageNamed:@"other-off"];
            break;
        case 7:
            return [UIImage imageNamed:@"switch-off"];
            break;
        case 8:
            return [UIImage imageNamed:@"ir-off"];
            break;
        case 9:
            return [UIImage imageNamed:@"smoke-off"];
            break;
        case 10:
            return [UIImage imageNamed:@"door-off"];
            break;
        default:
            return [UIImage imageNamed:@"slalarm-off"];
            break;
    }
    return [UIImage imageNamed:@"other-off"];
}
@end
