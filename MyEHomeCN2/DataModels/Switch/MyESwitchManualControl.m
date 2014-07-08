//
//  MyESwitchManualControl.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchManualControl.h"

@implementation MyESwitchManualControl
-(MyESwitchManualControl *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchManualControl *control = [[MyESwitchManualControl alloc] initWithDic:dic];
    return control;
}
-(MyESwitchManualControl *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        NSMutableArray *channels = [NSMutableArray array];
        NSArray *array = dic[@"SCList"];
        for (NSDictionary *dict in array) {
//            [array addObject:[[MyESwitchChannelStatus alloc] initWithDic:dict]];  注意这里的内容跟下面内容的区别和联系，这里也算是做了突破
            [channels addObject:[[MyESwitchChannelStatus alloc] initWithDic:dict]];
        }
        self.SCList = channels;
        return self;
    }
    return nil;
}
@end

@implementation MyESwitchChannelStatus

-(MyESwitchChannelStatus *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchChannelStatus *status = [[MyESwitchChannelStatus alloc] initWithDic:dic];
    return status;
}
-(MyESwitchChannelStatus *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.channelId = [dic[@"channelId"] intValue];
        self.switchStatus = [dic[@"switchStatus"] intValue];
        self.delayStatus = [dic[@"delayStatus"]intValue];
        self.delayMinute = [dic[@"delayMinute"] intValue];
        self.remainMinute = [dic[@"surplusMinute"] intValue];
        self.disable = [dic[@"disabledStatus"] boolValue];
        self.timer = [[NSTimer alloc] init];
        self.timerValue = 0;
        return self;
    }
    return nil;
}
-(NSString *)jsonStringWithStatus:(MyESwitchChannelStatus *)status{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *str = [writer stringWithObject:[[MyESwitchChannelStatus alloc] getArrayWithStatus:status]];
    return str;
}
-(NSArray *)getArrayWithStatus:(MyESwitchChannelStatus *)status{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *array = [NSMutableArray array];
    [dic setValue:[NSNumber numberWithInteger:status.channelId] forKey:@"channelId"];
    [dic setValue:[NSNumber numberWithInteger:status.delayStatus] forKey:@"delayStatus"];
    [dic setValue:[NSNumber numberWithInteger:status.delayMinute] forKey:@"delayMinute"];
    [array addObject:dic];
    return array;
}
-(NSArray *)getJsonArrayWithControl:(MyESwitchManualControl *)control{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *array = [NSMutableArray array];
    for (MyESwitchChannelStatus *status in control.SCList) {
        [dic setValue:[NSNumber numberWithInteger:status.channelId] forKey:@"channelId"];
        [dic setValue:[NSNumber numberWithInteger:status.delayStatus] forKey:@"delayStatus"];
        [dic setValue:[NSNumber numberWithInteger:status.delayMinute] forKey:@"delayMinute"];
        [array addObject:dic];
    }
    return array;
}
@end