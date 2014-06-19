//
//  MyEDeviceType.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/1/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEDeviceType.h"
#import "SBJson.h"
#import "MyEDevice.h"

@implementation MyEDeviceType
@synthesize dtId = _dtId, name = _name, devices = _devices;


#pragma mark
#pragma mark JSON methods
- (MyEDeviceType *)init {
    if (self = [super init]) {
        _dtId = 0;
        _name = @"";
        _devices = [NSMutableArray array];
        return self;
    }
    return nil;
}

- (MyEDeviceType *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.dtId = [[dictionary objectForKey:@"id"] intValue];
        self.name = [dictionary objectForKey:@"name"];
        
        NSArray *array = [dictionary objectForKey:@"devices"];
        NSMutableArray *devices = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSNumber *deviceId in array) {  //特别注意这里，如果元素为int类型时，要使用NSNumber
                [devices addObject:[deviceId copy]];
            }
        }
        self.devices = devices;
        return self;
    }
    return nil;
}

- (MyEDeviceType *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEDeviceType *deviceType = [[MyEDeviceType alloc] initWithDictionary:dict];
    return deviceType;
}
- (NSDictionary *)JSONDictionary {
    NSMutableArray *devices = [NSMutableArray array];
    for (MyEDevice *device in self.devices)
        [devices addObject:[device JSONDictionary]];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.dtId], @"id",
                          self.name, @"name",
                          devices, @"devices",//这里不能把devices直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          nil ];

    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEDeviceType alloc] initWithDictionary:[self JSONDictionary]];
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@  %i  %@",self.name,self.dtId,[self.devices componentsJoinedByString:@","]];
}
@end
