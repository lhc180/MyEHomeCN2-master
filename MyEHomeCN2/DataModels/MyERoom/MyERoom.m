//
//  MyERoom.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyERoom.h"
#import "SBJson.h"
#import "MyEDevice.h"

@implementation MyERoom
@synthesize roomId = _roomId, name = _name, devices = _devices;

- (MyERoom *)init {
    if (self = [super init]) {
        _roomId = 0;
        _name = @"";
        _devices = [NSMutableArray array];
        return self;
    }
    return nil;
}
#pragma mark
#pragma mark JSON methods
- (MyERoom *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.roomId = [[dictionary objectForKey:@"id"] intValue];
        self.name = [dictionary objectForKey:@"name"];
        
        NSArray *array = [dictionary objectForKey:@"devices"];
        NSMutableArray *devices = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSNumber *deviceId in array) {
                [devices addObject:[deviceId copy]];
            }
        }
        self.devices = devices;
        return self;
    }
    return nil;
}

- (MyERoom *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyERoom *room = [[MyERoom alloc] initWithDictionary:dict];
    return room;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.roomId], @"id",
                          self.name, @"name",
                          self.devices, @"devices",//这里不能把devices直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyERoom alloc] initWithDictionary:[self JSONDictionary]];
}

@end
