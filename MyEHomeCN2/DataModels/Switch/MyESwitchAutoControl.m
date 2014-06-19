//
//  MyESwitchAutoControl.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchAutoControl.h"

@implementation MyESwitchAutoControl
-(MyESwitchAutoControl *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchAutoControl *control = [[MyESwitchAutoControl alloc] initWithDic:dic];
    return control;
}
-(MyESwitchAutoControl *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.enable = [dic[@"enable"] intValue];
        self.numChannel = [dic[@"numChannel"] intValue];
        NSMutableArray *schedules = [NSMutableArray array];
        NSArray *array = dic[@"SSList"];
        for (NSDictionary *dict in array) {
            [schedules addObject:[[MyESwitchSchedule alloc] initWithDic:dict]];
        }
        self.SSList = schedules;
        return self;
    }
    return nil;
}
@end

@implementation MyESwitchSchedule

-(MyESwitchSchedule *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchSchedule *schedule = [[MyESwitchSchedule alloc] initWithDic:dic];
    return schedule;
}
-(MyESwitchSchedule *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        if (dic[@"id"]) {
            self.scheduleId = [dic[@"id"] intValue];
        }else{
            self.scheduleId = [dic[@"scheduleId"] intValue];
            self.onTime = dic[@"onTime"];
            self.offTime = dic[@"offTime"];
            NSMutableArray *channelArray = [NSMutableArray array];
            
            NSMutableArray *weekArray = [NSMutableArray array];
            NSArray *array = dic[@"channels"];
            for (NSNumber *i in array) {
                [channelArray addObject:i];
            }
            self.channels = channelArray;
            NSArray *array0 = dic[@"weeks"];
            for (NSNumber *j in array0) {
                [weekArray addObject:j];
            }
            self.weeks = weekArray;
        }
        return self;
    }
    return nil;
}
-(id)copyWithZone:(NSZone *)zone{
    MyESwitchSchedule *copy = [[MyESwitchSchedule allocWithZone:zone] init];
    copy.scheduleId = self.scheduleId;
    copy.onTime = self.onTime;
    copy.offTime = self.offTime;
    copy.channels = self.channels;
    copy.weeks = self.weeks;
    return copy;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%i   %@  %@  %@  %@",self.scheduleId,self.onTime,self.offTime,[self.channels componentsJoinedByString:@","],[self.weeks componentsJoinedByString:@","]];
}
@end
