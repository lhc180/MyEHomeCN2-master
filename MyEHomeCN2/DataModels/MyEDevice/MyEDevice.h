//
//  MyEDevice.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyEDeviceStatus.h"
#import "MyEAcInstructionSet.h"
#import "MyEIrKeySet.h"


//@class MyEDeviceStatus;
//@class MyEAcInstructionSet;
//@class MyEIrKeySet;

@interface MyEDevice : NSObject  <NSCopying> 
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *tId;
@property (nonatomic) NSInteger deviceId;

//主要针对空调
@property (nonatomic, copy) NSString *brand;
@property (nonatomic) NSInteger brandId;
@property (nonatomic, copy) NSString *model;
@property (nonatomic) NSInteger modelId;

@property (nonatomic) BOOL isSystemDefined;
@property (nonatomic) NSInteger instructionMode;//标识通风模式是否存在   型号不存在的话  这个也没有  1:存在 0:不存在

@property (nonatomic) NSInteger roomId;
@property (nonatomic) NSInteger type;

@property (nonatomic, retain) MyEDeviceStatus *status;


@property (nonatomic, retain) MyEAcInstructionSet *acInstructionSet;// 空调指令集，仅用于用户定义的空调
@property (nonatomic, retain) MyEIrKeySet *irKeySet;// 一般红外设备指令集


// JSON 接口
- (MyEDevice *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEDevice *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;

- (MyEDevice *)newDevice:(MyEDevice*)device;

- (BOOL)isInitialized;//当前设备是否完成了初始化（主要针对空调设备）
- (BOOL)isOrphan;     //当前设备是否绑定了智控星
- (BOOL)isConnected;  //当前设备是否连接

- (NSString *)connectionImage;

- (NSArray *)maxElecArray;    //插座设置中的最大电流

@end
