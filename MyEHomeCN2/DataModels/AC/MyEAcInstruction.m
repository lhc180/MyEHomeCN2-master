//
//  MyEAcInstruction.m
//  MyEHome
//
//  Created by Ye Yuan on 10/8/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcInstruction.h"
#import "SBJson.h"

@implementation MyEAcInstruction
@synthesize tId, instructionId, setId, powerSwitch, runMode, windLevel, setpoint, brandId, modelId, status;

#pragma mark
#pragma mark JSON methods
- (MyEAcInstruction *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.tId = [dictionary objectForKey:@"Tid"];
        self.setId = [[dictionary objectForKey:@"setId"] intValue];
        self.instructionId = [[dictionary objectForKey:@"id"] intValue];
        self.powerSwitch = [[dictionary objectForKey:@"switch_"] intValue];
        self.runMode = [[dictionary objectForKey:@"model"] intValue];
        self.windLevel = [[dictionary objectForKey:@"power"] intValue];
        self.setpoint = [[dictionary objectForKey:@"temperature"] intValue];
        self.status = [[dictionary objectForKey:@"status"] intValue];
        self.modelId = [[dictionary objectForKey:@"airConditionModuleId"] intValue];
        self.brandId = 0;
        
        return self;
    }
    return nil;
}

- (MyEAcInstruction *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEAcInstruction *acInstruction = [[MyEAcInstruction alloc] initWithDictionary:dict];
    return acInstruction;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.tId, @"tId",
                          [NSNumber numberWithInteger:self.setId], @"setId",
                          [NSNumber numberWithInteger:self.instructionId], @"instructionId",
                          [NSNumber numberWithInteger:self.powerSwitch], @"powerSwitch",
                          [NSNumber numberWithInteger:self.runMode], @"runMode",
                          [NSNumber numberWithInteger:self.windLevel], @"windLevel",
                          [NSNumber numberWithInteger:self.setpoint], @"setpoint",
                          [NSNumber numberWithInteger:self.brandId], @"brandId",
                          [NSNumber numberWithInteger:self.modelId], @"modelId",
                          [NSNumber numberWithInteger:self.status], @"status",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAcInstruction alloc] initWithDictionary:[self JSONDictionary]];
}


@end
