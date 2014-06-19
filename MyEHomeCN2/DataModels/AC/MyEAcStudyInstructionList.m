//
//  MyEAcStudyInstructionList.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-23.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcStudyInstructionList.h"

@implementation MyEAcStudyInstructionList
@synthesize instructionList;

- (MyEAcStudyInstructionList *)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        NSMutableArray *instructions = [NSMutableArray array];
        NSMutableArray *array = dictionary[@"terminalStudyList"];
        if ([array isKindOfClass:[array class]]) {
            for (NSDictionary *dic in array) {
                [instructions addObject:[[MyEAcStudyInstruction alloc]initWithDictionary:dic]];
            }
            instructionList = instructions;
        }
        return self;
    }
    return nil;
}
- (MyEAcStudyInstructionList *)initWithJSONString:(NSString *)jsonString{
    SBJsonParser *parser = [[SBJsonParser alloc]init];
    NSDictionary *dic = [parser objectWithString:jsonString];
    MyEAcStudyInstructionList *list = [[MyEAcStudyInstructionList alloc] initWithDictionary:dic];
    return list;
}
- (NSDictionary *)JSONDictionary{
    NSDictionary *dic = [NSDictionary dictionary];
    return dic;
}

-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAcStudyInstructionList alloc] initWithDictionary:[self JSONDictionary]];
}

@end
