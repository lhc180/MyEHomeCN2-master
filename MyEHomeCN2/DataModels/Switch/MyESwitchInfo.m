//
//  MyESwitchInfo.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyESwitchInfo.h"

@implementation MyESwitchInfo
-(MyESwitchInfo *)initWithString:(NSString *)string{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:string];
    MyESwitchInfo *info = [[MyESwitchInfo alloc] initWithDic:dic];
    return info;
}
-(MyESwitchInfo *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"name"];
        self.roomId = [dic[@"roomId"] intValue];
        self.powerType = [dic[@"powerType"] intValue];
        self.reportTime = [dic[@"reporteTime"] intValue];
        self.type = [dic[@"loadType"] intValue];
        return self;
    }
    return nil;
}
-(NSArray *)typeArray{
    return @[@"日光灯/节能灯",@"白炽灯"];
}
-(NSString *)changeTypeToString{
    return [self typeArray][self.type];
}
@end
