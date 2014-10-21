//
//  MYESocket.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/11.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MYESocket : NSObject

//{"surplusSeconds":14337,"terminalSocket":{"MId":"05-00-00-00-00-00-00-D7","TId":"02-01-00-00-00-00-01-43","aliasName":"饮水机","autoFlag":0,"controlType":2,"currentPower":0.22,"gid":"15b6a30e-1207-f646-d155-62effb3609a3","maxElectricCurrent":10,"powerStartTime":"2014-08-21","regTime":"2014-08-21","rfStatus":3,"roomId":0,"setTimingTime":"2014-10-11","setTmingMinute":240,"switchStatus":1,"terminalTypeId":2,"totalPower":0,"updateTime":"2014-10-11"},"result":0}

//基本信息
@property (nonatomic,strong) NSString *mid;
@property (nonatomic,strong) NSString *tid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) BOOL autoFlag;
@property (nonatomic,assign) NSInteger controlType;
@property (nonatomic,assign) BOOL isPowerOn;

//功率电流信息
@property (nonatomic,assign) float currentPower;
@property (nonatomic,assign) NSInteger maxElect;
@property (nonatomic,assign) NSInteger totalPower;

//定时或者延时信息
@property (nonatomic,assign) NSInteger timeSet;   //定时时间,单位是分钟
@property (nonatomic,assign) NSInteger timeRemain;  //剩余定时时间，单位是秒

//自动控制信息
@property (nonatomic,strong) NSMutableArray *process;  //进程数组



- (MYESocket *)initWithDictionary:(NSDictionary *)dictionary;
- (MYESocket *)initWithJSONString:(NSString *)jsonString;
@end
