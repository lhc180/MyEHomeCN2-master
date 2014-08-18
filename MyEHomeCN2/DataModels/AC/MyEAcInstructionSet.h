//
//  MyEAcInstructionSet.h
//  MyEHome
//
//  Created by Ye Yuan on 10/9/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEAcInstruction;

@interface MyEAcInstructionSet : NSObject <NSCopying>
@property (nonatomic, retain) NSMutableArray *mainArray;

// JSON 接口
- (MyEAcInstructionSet *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcInstructionSet *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;

// utilities methods

// 给定一个指令细节，获取其在开指令列表里面的序号
- (NSInteger) indexOfInstructionInOnListWithRunMode:(NSInteger)runMode andSetpoint:(NSInteger)setpoint andWindLevel:(NSInteger)windLevel;
// 给定一个指令细节，获取其在开指令列表里面的序号
- (NSInteger) indexOfInstructionInOnListWithInstruction:(MyEAcInstruction *)instruction;
// 返回开指令列表里面的指令数目
- (NSInteger) countOfInstructionInOnList;
// 给定序号，返回开指令列表里面的该序号处的指令
- (MyEAcInstruction *)instructionInOnListAtIndex:(NSInteger)index;
@end
