//
//  MyEAllDeviceInstruction.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-6.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyESceneDeviceInstruction : NSObject<NSCopying>

@property (nonatomic, copy) NSString *tId;
@property (nonatomic) NSInteger instructionId;// 指令id
@property (nonatomic,strong) NSString *keyName;

@property (nonatomic) NSInteger acModuleId;//空调型号
@property (nonatomic) NSInteger powerSwitch;

@property (nonatomic) NSInteger runMode;
@property (nonatomic) NSInteger windLevel;
@property (nonatomic) NSInteger setpoint;
@property (nonatomic) NSInteger type;

@property (nonatomic) NSInteger modelId;//指令类型
@property (nonatomic) NSInteger status;// 当status>=1时，表明此指令已经学习

// JSON 接口
- (MyESceneDeviceInstruction *)initWithDictionary:(NSDictionary *)dictionary;
- (MyESceneDeviceInstruction *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;


@end
