//
//  MyEDeviceStatus.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEDeviceStatus : NSObject  <NSCopying> 
@property (nonatomic) NSInteger connection;//0表示断开，1~4表示四格信号

@property (nonatomic) NSInteger powerSwitch;//0表示关，1开

// for AC
@property (nonatomic) NSInteger runMode;//0表示关，1开
@property (nonatomic) NSInteger setpoint;
@property (nonatomic) NSInteger temperature;
@property (nonatomic) NSInteger humidity;
@property (nonatomic) NSInteger windLevel;
@property (nonatomic) NSInteger feedbackToneSwitch;
@property (nonatomic) NSInteger tempMornitorEnabled;
@property (nonatomic) NSInteger acTmax;
@property (nonatomic) NSInteger acTmin;
@property (nonatomic,strong) NSMutableString *switchStatus;

// for Smart Socket
@property (nonatomic) float currentPower;
@property (nonatomic) float maxElectricCurrent;
@property (nonatomic) float totalPower;
@property (nonatomic, copy) NSString *tpStartDate;// 开始日期


- (MyEDeviceStatus *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEDeviceStatus *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
