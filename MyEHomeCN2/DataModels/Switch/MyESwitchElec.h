//
//  MyESwitchElec.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-4.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyESwitchElecStatus;
@interface MyESwitchElec : NSObject

@property(nonatomic, strong) NSMutableArray *powerRecordList;
@property(nonatomic) float currentPower;
@property(nonatomic) float totalPower;
@property(nonatomic, strong) MyESwitchElecStatus *elecStatus;

-(MyESwitchElec *)initWithString:(NSString *)string;
-(MyESwitchElec *)initWithDic:(NSDictionary *)dic;
@end


@interface MyESwitchElecStatus : NSObject

@property(nonatomic, strong) NSString *date;
@property(nonatomic, strong) NSString *week;
@property(nonatomic, strong) NSString *month;
@property(nonatomic) float totalPower;

-(MyESwitchElecStatus *)initWithString:(NSString *)string;
-(MyESwitchElecStatus *)initWithDic:(NSDictionary *)dic;
@end
