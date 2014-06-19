//
//  MyEScene.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEScene.h"
#import "SBJson.h"
#import "MyEDeviceControl.h"

@implementation MyEScene
@synthesize deviceControls = _deviceControls, name, sceneId, byOrder;

#pragma mark
#pragma mark JSON methods
- (MyEScene *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        
        self.sceneId = [[dictionary objectForKey:@"id"] intValue];
        self.name = [dictionary objectForKey:@"name"];
        self.byOrder = [dictionary[@"byOrder"] intValue];
        
        NSArray *array = [dictionary objectForKey:@"deviceControls"];
        
        NSMutableArray *deviceControls = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *deviceControl in array) {
                [deviceControls addObject:[[MyEDeviceControl alloc] initWithDictionary: deviceControl]];
            }
        }
        self.deviceControls = deviceControls;
        
        
        return self;
    }
    return nil;
}

- (MyEScene *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEScene *scene = [[MyEScene alloc] initWithDictionary:dict];
    return scene;
}
- (NSDictionary *)JSONDictionary {
    NSMutableArray *deviceControlsArray = [NSMutableArray array];
    for (MyEDeviceControl *deviceControl in self.deviceControls)
        [deviceControlsArray addObject:[deviceControl JSONDictionary]];
    //这句是我加的，加了之后可以正确转化为dic
//    self.deviceControls = deviceControlsArray;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.sceneId], @"id",
                          [NSNumber numberWithInteger:self.byOrder], @"byOrder",
                          self.name, @"name",
                          deviceControlsArray, @"deviceControls",
//                          self.deviceControls, @"deviceControls",//这里不能把devices直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          nil ];
    
    return dict;
}
- (NSString *)JSONStringWithDictionary:(MyEScene *)scene{
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dic = [scene JSONDictionary];
    NSString *string = [writer stringWithObject:dic[@"deviceControls"]];
    return string;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEScene alloc] initWithDictionary:[self JSONDictionary]];
}

@end
