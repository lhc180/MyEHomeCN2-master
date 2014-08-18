//
//  MyEAcStudyInstruction.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-23.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAcStudyInstruction : NSObject

@property (nonatomic, strong) NSString *tId;
@property (nonatomic) NSInteger module;
@property (nonatomic) NSInteger instructionId;
@property (nonatomic) NSInteger mode;
@property (nonatomic) NSInteger modelId;
@property (nonatomic) NSInteger windLevel;
@property (nonatomic) NSInteger power;
@property (nonatomic) NSInteger temperature;
@property (nonatomic) NSInteger status;


- (MyEAcStudyInstruction *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcStudyInstruction *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;


@end
