//
//  MyEAllDeviceInstruction.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-6.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESceneDeviceInstruction.h"

@implementation MyESceneDeviceInstruction

@synthesize tId,acModuleId,instructionId,keyName,runMode,modelId,windLevel,status,powerSwitch,setpoint,type;

#pragma mark
#pragma mark JSON methods
- (MyESceneDeviceInstruction *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.tId = [dictionary objectForKey:@"TId"];
        self.acModuleId = [[dictionary objectForKey:@"acModuleId"] intValue];
        self.instructionId = [[dictionary objectForKey:@"id"] intValue];
        self.keyName = [dictionary objectForKey:@"keyName"];
        self.powerSwitch = [[dictionary objectForKey:@"switch_"] intValue];
        self.runMode = [[dictionary objectForKey:@"model"] intValue];
        self.windLevel = [[dictionary objectForKey:@"power"] intValue];
        self.setpoint = [[dictionary objectForKey:@"temperature"] intValue];
        self.status = [[dictionary objectForKey:@"status"] intValue];
        self.modelId = [[dictionary objectForKey:@"modelId"] intValue];
        self.type = [[dictionary objectForKey:@"type"] intValue];
        
        return self;
    }
    return nil;
}

- (MyESceneDeviceInstruction *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyESceneDeviceInstruction *allDeviceInstruction = [[MyESceneDeviceInstruction alloc] initWithDictionary:dict];
    return allDeviceInstruction;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.tId, @"TId",
                          self.keyName,@"keyName",
                          [NSNumber numberWithInteger:self.acModuleId], @"acModuleId",
                          [NSNumber numberWithInteger:self.instructionId], @"id",
                          [NSNumber numberWithInteger:self.powerSwitch], @"switch_",
                          [NSNumber numberWithInteger:self.runMode], @"model",
                          [NSNumber numberWithInteger:self.windLevel], @"power",
                          [NSNumber numberWithInteger:self.setpoint], @"temperature",
                          [NSNumber numberWithInteger:self.modelId], @"modelId",
                          [NSNumber numberWithInteger:self.status], @"status",
                          [NSNumber numberWithInteger:self.type],@"type",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyESceneDeviceInstruction alloc] initWithDictionary:[self JSONDictionary]];
}
@end
