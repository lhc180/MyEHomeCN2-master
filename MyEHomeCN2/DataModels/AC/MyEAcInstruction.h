//
//  MyEAcInstruction.h
//  MyEHome
//
//  Created by Ye Yuan on 10/8/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAcInstruction : NSObject <NSCopying>

@property (nonatomic, copy) NSString *tId;
@property (nonatomic) NSInteger instructionId;// 指令id
@property (nonatomic) NSInteger setId;//520种学习模式id
@property (nonatomic) NSInteger powerSwitch;
@property (nonatomic) NSInteger runMode;
@property (nonatomic) NSInteger windLevel;
@property (nonatomic) NSInteger setpoint;
@property (nonatomic) NSInteger brandId;
@property (nonatomic) NSInteger modelId;
@property (nonatomic) NSInteger status;// 当status>=1时，表明此指令已经学习

// JSON 接口
- (MyEAcInstruction *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcInstruction *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;



@end
