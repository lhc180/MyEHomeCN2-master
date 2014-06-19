//
//  MyEAcStudyInstruction.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-23.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcStudyInstruction.h"

@implementation MyEAcStudyInstruction
@synthesize tId,instructionId,modelId,mode,windLevel,temperature,power,status,module;



- (MyEAcStudyInstruction *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        tId = dic[@"TId"];
        instructionId = [dic[@"id"] intValue];
        module = [dic[@"airConditionModuleId"] intValue];
        modelId = [dic[@"modelId"] intValue];
        mode = [dic[@"model"] intValue];
        windLevel = [dic[@"power"] intValue];
        power = [dic[@"switch_"] intValue];
        temperature = [dic[@"temperature"] intValue];
        status = [dic[@"status"] intValue];
        return self;
    }
    return nil;
}
- (MyEAcStudyInstruction *)initWithJSONString:(NSString *)jsonString{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:jsonString];
    MyEAcStudyInstruction *study = [[MyEAcStudyInstruction alloc] initWithDictionary:dic];
    return study;
}
- (NSDictionary *)JSONDictionary{
    NSDictionary *dic = [NSDictionary dictionary];
    return dic;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAcStudyInstruction alloc] initWithDictionary:[self JSONDictionary]];
}

@end
