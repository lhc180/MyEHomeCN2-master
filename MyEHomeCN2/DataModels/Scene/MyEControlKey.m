//
//  MyEControlKey.m
//  MyEHomeCN2
//
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEControlKey.h"
#import "SBJson.h"

@implementation MyEControlKey
@synthesize powerSwitch,
        runMode,
        windLevel,
        setpoint,
        keyId;
#pragma mark
#pragma mark JSON methods
- (MyEControlKey *)initWithDictionary:(NSDictionary *)dictionary {
//#warning 此处可能数据模型有问题，会导致场景面板出现奔溃,以下为解析的数据，这个错误只对特定帐号才会出现
    /* 
     {
     byOrder = 0;
     custom = 1;
     deviceControls = (
     {
     id = 6666;
     isAc = 0;
     key = "<null>";  //有时候会出现这个问题
     }
     );
     */
    if (dictionary != (NSDictionary *)[NSNull null]) {  //这里采用这种方式来判断字典是否为空
        if (self = [super init]) {
            self.powerSwitch = [[dictionary objectForKey:@"powerSwitch"] intValue];
            self.runMode = [[dictionary objectForKey:@"runMode"] intValue];
            self.windLevel = [[dictionary objectForKey:@"windLevel"] intValue];
            self.setpoint = [[dictionary objectForKey:@"setpoint"] intValue];
            self.keyId = [[dictionary objectForKey:@"keyId"] intValue];
            self.channel = dictionary[@"channel"];
            return self;
        }
    }else{
        if (self = [super init]) {
            self.powerSwitch = 0;
            self.runMode = 0;
            self.windLevel = 0;
            self.setpoint = 0;
            self.keyId = -1;  //这里采用-1这个特征值表示设备的控制码未指定
            self.channel = @"000";  //这里这个有点问题，需要注意下
        }
        return self;
    }
    return nil;
}
- (MyEControlKey *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    MyEControlKey *controlKey = [[MyEControlKey alloc] initWithDictionary:dict];
    return controlKey;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.powerSwitch], @"powerSwitch",
                          [NSNumber numberWithInteger:self.runMode], @"runMode",
                          [NSNumber numberWithInteger:self.windLevel], @"windLevel",
                          [NSNumber numberWithInteger:self.setpoint], @"setpoint",
                          [NSNumber numberWithInteger:self.keyId], @"keyId",
                          self.channel,@"channel",
                          nil];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEControlKey alloc] initWithDictionary:[self JSONDictionary]];
}

@end
