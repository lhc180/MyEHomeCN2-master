//
//  MyEDeviceStatus.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEDeviceStatus.h"
#import "SBJson.h"

@implementation MyEDeviceStatus
@synthesize connection,powerSwitch, runMode, setpoint, temperature, humidity,
        windLevel, feedbackToneSwitch, currentPower, maxElectricCurrent,
        totalPower, tpStartDate,tempMornitorEnabled,acTmax,acTmin;

- (MyEDeviceStatus *)init {
    if (self = [super init]) {
        connection = 4;
        powerSwitch = 0;
        runMode = 1;
        setpoint = 25;
        temperature = 25;
        humidity = 50;
        windLevel = 0;
        feedbackToneSwitch = 0;
        currentPower = 0;
        maxElectricCurrent = 0;
        totalPower = 0;
        tpStartDate = @"";
        tempMornitorEnabled = 0;
        acTmax = 0;
        acTmin = 0;
        _protectionStatus = 0;
        _alertStatus = 0;
        return self;
    }
    return nil;
}
#pragma mark
#pragma mark JSON methods
- (MyEDeviceStatus *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.connection = [[dictionary objectForKey:@"connection"] intValue];
        self.powerSwitch = [[dictionary objectForKey:@"switch_"] intValue];
        self.runMode = [[dictionary objectForKey:@"runMode"] intValue];
        self.setpoint = [[dictionary objectForKey:@"setpoint"] intValue];
        self.temperature = [[dictionary objectForKey:@"temperature"] intValue];
        self.humidity = [[dictionary objectForKey:@"humidity"] intValue];
        self.windLevel = [[dictionary objectForKey:@"windLevel"] intValue];
        self.feedbackToneSwitch = [[dictionary objectForKey:@"feedbackToneSwitch"] intValue];
        self.currentPower = [[dictionary objectForKey:@"currentPower"] floatValue];
        self.maxElectricCurrent = [[dictionary objectForKey:@"maxElectricCurrent"] floatValue];
        self.totalPower = [[dictionary objectForKey:@"totalPower"] floatValue];
        self.tpStartDate = [dictionary objectForKey:@"tpStartDate"];
        tempMornitorEnabled = [dictionary[@"tempMornitorEnabled"] intValue];
        acTmax = [dictionary[@"acTmax"] intValue];
        acTmin = [dictionary[@"acTmin"] intValue];
        self.switchStatus = dictionary[@"switchStatus"];
        self.protectionStatus = [dictionary[@"protectionStatus"] intValue];
        self.alertStatus = [dictionary[@"alertStatus"] intValue];
        return self;
    }
    return nil;
}

- (MyEDeviceStatus *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEDeviceStatus *deviceStatus = [[MyEDeviceStatus alloc] initWithDictionary:dict];
    return deviceStatus;
}
- (NSDictionary *)JSONDictionary {
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.connection], @"connection",
                          [NSNumber numberWithInteger:self.powerSwitch], @"powerSwitch",
                          [NSNumber numberWithInteger:self.runMode], @"runMode",
                          [NSNumber numberWithInteger:self.setpoint], @"setpoint",
                          [NSNumber numberWithInteger:self.temperature], @"temperature",
                          [NSNumber numberWithInteger:self.humidity], @"humidity",
                          [NSNumber numberWithInteger:self.windLevel], @"windLevel",
                          [NSNumber numberWithInteger:self.feedbackToneSwitch], @"feedbackToneSwitch",
                          [NSNumber numberWithFloat:self.currentPower], @"currentPower",
                          [NSNumber numberWithFloat:self.maxElectricCurrent], @"maxElectricCurrent",
                          [NSNumber numberWithFloat:self.totalPower], @"totalPower",
                          [NSNumber numberWithInteger:self.tempMornitorEnabled], @"tempMornitorEnabled",
                          [NSNumber numberWithInteger:self.acTmax],@"acTmax",
                          [NSNumber numberWithInteger:self.acTmin],@"acTmin",
                          self.tpStartDate, @"tpStartDate",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEDeviceStatus alloc] initWithDictionary:[self JSONDictionary]];
}

@end
