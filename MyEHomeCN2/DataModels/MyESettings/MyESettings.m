//
//  MyESettings.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-14.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESettings.h"

@implementation MyESettings

@synthesize mId;
@synthesize status;
@synthesize enableNotification;
@synthesize terminals;
@synthesize provinceId;
@synthesize cityId;

- (MyESettings *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        //这里的加==1和不加==1，有什么区别？
        self.status = [[dictionary objectForKey:@"status"] intValue];
        
        self.mId = [dictionary objectForKey:@"mId"];
        
        self.enableNotification = [[dictionary objectForKey:@"enableNotification"] intValue];
        
        self.provinceId = [dictionary objectForKey:@"provinceId"];
        
        self.cityId = [dictionary objectForKey:@"cityId"];
        
        //这里定义一个数组，用于接收服务器传过来的字典当中的irTerminals数组
        NSArray *array = [dictionary objectForKey:@"terminals"];
        
        NSMutableArray *irTerminals = [NSMutableArray array];
        //判断接收到的数据是不是一个数组
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *terminal in array) {
                //向irTerminals可变数组中添加对象，这些对象是解析过的
                [irTerminals addObject:[[MyETerminal alloc] initWithDictionary:terminal]];
            }
        }
        self.terminals = irTerminals;
        
        _subSwitchList = [NSMutableArray array];
        for (NSDictionary *d in dictionary[@"subSwitchList"]) {
            [_subSwitchList addObject:[[MyESettingSubSwitch alloc] initWithDictionary:d]];
        }
        return self;
    }
    return nil;
}

- (MyESettings *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyESettings *setting = [[MyESettings alloc] initWithDictionary:dict];
    
    return setting;
}

- (NSDictionary *)JSONDictionary {
    
    NSMutableArray *irTerminals = [NSMutableArray array];
    for (MyETerminal *terminal in self.terminals)
        [irTerminals addObject:[terminal JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.status], @"status",
                          [NSNumber numberWithInteger:self.enableNotification], @"enableNotification",
                          self.mId, @"mId",
                          self.provinceId, @"provinceId",
                          self.cityId, @"cityId",nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyESettings alloc] initWithDictionary:[self JSONDictionary]];
}
@end

@implementation MyESettingSubSwitch

-(MyESettingSubSwitch *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.gid = dic[@"gid"];
        self.tid = dic[@"TId"];
        self.mId = dic[@"Mid"];
        self.name = dic[@"aliasName"];
        self.mainTid = dic[@"mainTId"];
        self.signal = [dic[@"rfStatus"] intValue];
    }
    return self;
}
-(UIImage *)getImage{
    NSArray *array = @[@"signal0",@"signal1",@"signal2",@"signal3",@"signal4"];
    return [UIImage imageNamed:array[self.signal]];
}
@end