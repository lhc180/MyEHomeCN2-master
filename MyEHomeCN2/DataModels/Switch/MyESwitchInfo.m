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
//-(NSString *) trimright0:(CLLocationDegrees )param
//{
//    NSString *str = [NSString stringWithFormat:@"%f",param];
-(NSString *) trimright0:(NSString *)str
{
    int len = str.length;
    for (int i = 0; i < len; i++)
    {
        if (![str  hasSuffix:@"0"])
            break;
        else
            str = [str substringToIndex:[str length]-1];
    }
    if ([str hasSuffix:@"."])//避免像2.0000这样的被解析成2.
    {
        return [str substringToIndex:[str length]-1];//s.substring(0, len - i - 1);
    }
    else
    {
        return str;
    }
}
-(MyESwitchInfo *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"name"];
        self.roomId = [dic[@"roomId"] intValue];
        self.powerType = [dic[@"powerType"] intValue];
        self.reportTime = [dic[@"reporteTime"] intValue];
        self.type = [dic[@"loadType"] intValue];
        self.powerFactor = [self trimright0:[NSString stringWithFormat:@"%f",[dic[@"powerFactor"] floatValue]]];
        return self;
    }
    return nil;
}
- (NSArray *)powerFactorArray{ //开关设置中的功率因数
    return @[@"0.5",@"0.55",@"0.6",@"0.65",@"0.7",@"0.75",@"0.8",@"0.85",@"0.9",@"0.95",@"1"];
}

-(NSArray *)typeArray{
    return @[@"日光灯/节能灯",@"白炽灯"];
}
-(NSString *)changeTypeToString{
    return [self typeArray][self.type];
}
@end
