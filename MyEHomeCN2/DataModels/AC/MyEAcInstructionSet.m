//
//  MyEAcInstructionSet.m
//  MyEHome
//
//  Created by Ye Yuan on 10/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcInstructionSet.h"
#import "MyEAcInstruction.h"
#import "SBJson.h"

@implementation MyEAcInstructionSet
@synthesize mainArray = _mainArray;

#pragma mark
#pragma mark JSON methods
- (MyEAcInstructionSet *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        
        NSArray *array = [dictionary objectForKey:@"terminalStudyList"];
        NSMutableArray *instructionList = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *instruction in array) {
                [instructionList addObject:[[MyEAcInstruction alloc] initWithDictionary:instruction]];
            }
        }
        self.mainArray = instructionList;
        return self;
    }
    return nil;
}

- (MyEAcInstructionSet *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEAcInstructionSet *instructionSet = [[MyEAcInstructionSet alloc] initWithDictionary:dict];
    return instructionSet;
}
- (NSDictionary *)JSONDictionary {
    NSMutableArray *instructionSet = [NSMutableArray array];
    for (MyEAcInstruction *instruction in self.mainArray)
        [instructionSet addObject:[instruction JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          instructionSet, @"instructionList",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAcInstructionSet alloc] initWithDictionary:[self JSONDictionary]];
}

#pragma mark private method
- (NSArray *)onList
{
    NSMutableArray *array = [NSMutableArray array];
    NSInteger count = [self.mainArray count];
    for (NSInteger i = 0; i < count; i++) {
        MyEAcInstruction *inst = [self.mainArray objectAtIndex:i];
        if (inst.powerSwitch == 1) {
            [array addObject:inst];
        }
    }
    return array;
}

#pragma mark utilities methods
//给定一个指令，获取其在指令列表里面的序号
- (NSInteger) indexOfInstructionInOnListWithRunMode:(NSInteger)runMode andSetpoint:(NSInteger)setpoint andWindLevel:(NSInteger)windLevel{
    NSArray *array = [self onList];
    NSInteger count = [array count];
    for (NSInteger i = 0; i < count; i++) {
        MyEAcInstruction *inst = [array objectAtIndex:i];
        if (inst.runMode == runMode &&
            inst.setpoint == setpoint &&
            inst.windLevel == windLevel) {
            return i;
        }
    }
    return -1;
}

// 给定一个指令细节，获取其在开指令列表里面的序号
- (NSInteger) indexOfInstructionInOnListWithInstruction:(MyEAcInstruction *)instruction
{
    NSArray *array = [self onList];
    NSInteger count = [array count];
    for (NSInteger i = 0; i < count; i++) {
        MyEAcInstruction *inst = [self.mainArray objectAtIndex:i];
        if (inst.runMode == instruction.runMode &&
            inst.setpoint == instruction.setpoint &&
            inst.windLevel == instruction.windLevel) {
            return i;
        }
    }
    return -1;
};
// 返回开指令列表里面的指令数目
- (NSInteger) countOfInstructionInOnList
{
    NSArray *array = [self onList];
    return [array count];
}
// 给定序号，返回开指令列表里面的该序号处的指令
- (MyEAcInstruction *)instructionInOnListAtIndex:(NSInteger)index
{
    NSArray *array = [self onList];
    return [array objectAtIndex:index];
}
@end
