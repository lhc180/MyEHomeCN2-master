//
//  MyESwitchAutoControl.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-3-3.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  MyESwitchSchedule;
@interface MyESwitchAutoControl : NSObject
@property(nonatomic) NSInteger enable;
@property(nonatomic) NSInteger numChannel;
@property(nonatomic, strong) NSMutableArray *SSList;
@property(nonatomic, strong) MyESwitchSchedule *schedule;

-(MyESwitchAutoControl *)initWithString:(NSString *)string;
-(MyESwitchAutoControl *)initWithDic:(NSDictionary *)dic;
@end


@interface MyESwitchSchedule : NSObject <NSCopying>

@property(nonatomic) NSInteger scheduleId;
@property(nonatomic, strong) NSString *onTime;
@property(nonatomic, strong) NSString *offTime;
@property(nonatomic, strong) NSMutableArray *channels;
@property(nonatomic, strong) NSMutableArray *weeks;
-(MyESwitchSchedule *)initWithString:(NSString *)string;
-(MyESwitchSchedule *)initWithDic:(NSDictionary *)dic;
@end