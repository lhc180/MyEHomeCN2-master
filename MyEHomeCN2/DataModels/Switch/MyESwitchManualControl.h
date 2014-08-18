//
//  MyESwitchManualControl.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyESwitchChannelStatus;
@interface MyESwitchManualControl : NSObject

@property(nonatomic, strong) NSMutableArray *SCList;
@property(nonatomic, strong) MyESwitchChannelStatus *channelStatus;

-(MyESwitchManualControl *)initWithString:(NSString *)string;
-(MyESwitchManualControl *)initWithDic:(NSDictionary *)dic;
@end

@interface MyESwitchChannelStatus : NSObject

@property(nonatomic) NSInteger channelId;
@property(nonatomic) NSInteger switchStatus;
@property(nonatomic) NSInteger delayStatus;
@property(nonatomic) NSInteger delayMinute;
@property(nonatomic) NSInteger remainMinute;
@property(nonatomic, strong) NSTimer *timer;    //这里创建了一个NSTimer，用以记录当前的倒计时状态，这个要特别注意
@property(nonatomic) NSInteger timerValue;   //这个表示的是timer的初始时间
@property(nonatomic, assign) BOOL disable;

-(MyESwitchChannelStatus *)initWithString:(NSString *)string;
-(MyESwitchChannelStatus *)initWithDic:(NSDictionary *)dic;
-(NSString *)jsonStringWithStatus:(MyESwitchChannelStatus *)status;
-(NSArray *)getArrayWithStatus:(MyESwitchChannelStatus *)status;
-(NSArray *)getJsonArrayWithControl:(MyESwitchManualControl *)control;
@end