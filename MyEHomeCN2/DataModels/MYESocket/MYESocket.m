//
//  MYESocket.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/11.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYESocket.h"
#import "SBJson.h"

@implementation MYESocket
-(instancetype)init{
    if (self = [super init]) {
        self.mid = @"";
        self.tid = @"";
        self.name = @"";
        self.autoFlag = NO;
        self.controlType = 0;
        self.currentPower = 0;
        self.maxElect = 0;
        self.isPowerOn = NO;
        self.totalPower = 0;
        self.timeSet = 0;
        self.timeRemain = 0;
        self.process = [NSMutableArray array];
    }
    return self;
}
-(MYESocket *)initWithJSONString:(NSString *)jsonString{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:jsonString];
    if (dic) {
        return [[MYESocket alloc] initWithDictionary:dic];
    }
    return [[MYESocket alloc] init];
}
-(MYESocket *)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        NSDictionary *dic = dictionary[@"terminalSocket"];
        self.mid = dic[@"MId"];
        self.tid = dic[@"TId"];
        self.name = dic[@"aliasName"];
        self.autoFlag = [dic[@"autoFlag"] intValue] == 1;
        self.controlType = [dic[@"controlType"] intValue];
        self.currentPower = [dic[@"currentPower"] floatValue];
        self.maxElect = [dic[@"maxElectricCurrent"] intValue];
        self.totalPower = [dic[@"totalPower"] intValue];
        self.isPowerOn = [dic[@"switchStatus"] intValue] == 1;
        self.timeSet = [dic[@"setTmingMinute"] intValue];
        self.timeRemain = dictionary[@"surplusSeconds"]?[dictionary[@"surplusSeconds"] intValue]:-1;
        self.process = [NSMutableArray array];
    }
    return self;
}
@end
