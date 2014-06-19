//
//  MyEDevice.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEDeviceStatus;
@class MyEAcInstructionSet;
@class MyEIrKeySet;

@interface MyEDevice : NSObject  <NSCopying> 
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *tId;
@property (nonatomic) NSInteger deviceId;
@property (nonatomic) NSInteger brandId;
@property (nonatomic) NSInteger modelId;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *model;
@property (nonatomic) NSInteger roomId;
@property (nonatomic) NSInteger type;
@property (nonatomic, retain) MyEDeviceStatus *status;
@property (nonatomic) BOOL isSystemDefined;
@property (nonatomic) NSInteger instructionMode;//标识通风模式是否存在   型号不存在的话  这个也没有  1:存在 0:不存在


@property (nonatomic, retain) MyEAcInstructionSet *acInstructionSet;// 空调指令集，仅用于用户定义的空调
@property (nonatomic, retain) MyEIrKeySet *irKeySet;// 一般红外设备指令集


// JSON 接口
- (MyEDevice *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEDevice *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;

- (BOOL)isInitialized;
- (BOOL)isOrphan;
- (BOOL)isConnected;
@end
