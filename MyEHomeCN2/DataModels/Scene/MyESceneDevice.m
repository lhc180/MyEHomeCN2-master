//
//  MyESceneDevice.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-6.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESceneDevice.h"

@implementation MyESceneDevice

@synthesize deviceId,instructions;

#pragma mark
#pragma mark JSON methods
- (MyESceneDevice *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.deviceId = [[dictionary objectForKey:@"id"] intValue];
        
        NSArray *array = [dictionary objectForKey:@"instructions"];
        NSMutableArray *instructionArray = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *instruction in array) {
                MyESceneDeviceInstruction *inst = [[MyESceneDeviceInstruction alloc] initWithDictionary: instruction];
                [instructionArray addObject:inst];
            }
        }
        self.instructions = instructionArray;
        return self;
    }
    return nil;
}

- (MyESceneDevice *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyESceneDevice *sceneDevice = [[MyESceneDevice alloc] initWithDictionary:dict];
    return sceneDevice;
}
- (NSDictionary *)JSONDictionary {
    NSMutableArray *deviceInstructions = [NSMutableArray array];
    for (MyESceneDeviceInstruction *deviceInstruction in self.instructions)
        [deviceInstructions addObject:[deviceInstruction JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.deviceId], @"id",
                          self.instructions, @"instructions",//这里不能把instructions直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyESceneDevice alloc] initWithDictionary:[self JSONDictionary]];
}
@end
