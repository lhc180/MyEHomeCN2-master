//
//  MyESceneInstructionRecived.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-6.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyESceneInstructionRecived.h"


@implementation MyESceneInstructionRecived

@synthesize allInstructions;

#pragma mark
#pragma mark JSON methods
- (MyESceneInstructionRecived *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        
        NSArray *array = [dictionary objectForKey:@"all_instructions"];
        NSMutableArray *mainArray = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *sceneDevice in array) {
                [mainArray addObject:[[MyESceneDevice alloc] initWithDictionary:sceneDevice]];
            }
        }
        self.allInstructions = mainArray;
        return self;
    }
    return nil;
}

- (MyESceneInstructionRecived *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyESceneInstructionRecived *sceneInstructions = [[MyESceneInstructionRecived alloc] initWithDictionary:dict];
    return sceneInstructions;
}
- (NSDictionary *)JSONDictionary {
    NSMutableArray *mainArray = [NSMutableArray array];
    for (MyESceneDevice *sceneDevice in self.allInstructions)
        [mainArray addObject:[sceneDevice JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          allInstructions, @"all_instructions",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyESceneList alloc] initWithDictionary:[self JSONDictionary]];
}


@end
