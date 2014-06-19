//
//  MyEDeviceControl.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEDeviceControl.h"


@implementation MyEDeviceControl
@synthesize controlKey, deviceId, dcId;
#pragma mark
#pragma mark JSON methods
- (MyEDeviceControl *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        
        self.deviceId = [[dictionary objectForKey:@"id"] intValue];
        self.isAc = [[dictionary objectForKey:@"isAc"] intValue];
        //dcId 用一个微妙来区别
//        self.dcId = [[NSDate date] timeIntervalSince1970];
        self.controlKey = [[MyEControlKey alloc] initWithDictionary:[dictionary objectForKey:@"key"]];
        return self;
    }
    return nil;
}

- (MyEDeviceControl *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    NSLog(@"%@",dict);
    MyEDeviceControl *deviceControl = [[MyEDeviceControl alloc] initWithDictionary:dict];
    return deviceControl;
}
- (NSDictionary *)JSONDictionary {
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.deviceId], @"id",
                          [NSNumber numberWithInteger:self.isAc], @"isAc",
//                          self.dcId, @"dcId",
                          [self.controlKey JSONDictionary], @"controlKey",//这里不能把devices直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          nil ];
    
    return dict;
}

- (NSString *)JSONStringWithDictionary:(MyEDeviceControl *)deviceControl{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = [deviceControl JSONDictionary];
    NSString *string = [writer stringWithObject:dic];
    return string;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEDeviceControl alloc] initWithDictionary:[self JSONDictionary]];
}

@end
