//
//  MyESwitchElec.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-4.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchElec.h"

@implementation MyESwitchElec

-(MyESwitchElec *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchElec *elec = [[MyESwitchElec alloc] initWithDic:dic];
    return elec;
}
-(MyESwitchElec *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.totalPower = [dic[@"totalPower"] floatValue];
        self.currentPower = [dic[@"currentPower"] floatValue];
        NSMutableArray *powerList = [NSMutableArray array];
        NSArray *array = dic[@"powerRecordList"];
        for (NSDictionary *dict in array) {
            [powerList addObject:[[MyESwitchElecStatus alloc] initWithDic:dict]];
        }
        self.powerRecordList = powerList;
        return self;
    }
    return nil;
}
@end


@implementation MyESwitchElecStatus

-(MyESwitchElecStatus *)initWithString:(NSString *)string{
    return self;//这里是没怎么写，直接返回self
}
-(MyESwitchElecStatus *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.totalPower = [dic[@"totalPower"] floatValue];
        if (dic[@"date"]) {
            self.date = dic[@"date"];
        }
        if (dic[@"weekly"]) {
            self.week = dic[@"weekly"];
        }
        if (dic[@"month"]) {
            self.month = dic[@"month"];
        }
        return self;
    }
    return nil;
}

@end