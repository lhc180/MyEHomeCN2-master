//
//  MyEAcAutoControlPeriod.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/18/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAutoControlPeriod : NSObject <NSCopying>
@property (nonatomic) NSInteger pId; // period id, in local scope
@property (nonatomic) NSInteger stid;
@property (nonatomic) NSInteger etid;
@property (nonatomic) NSInteger runMode;
@property (nonatomic) NSInteger windLevel;
@property (nonatomic) NSInteger setpoint;
@property (nonatomic,strong) NSString *startTimeString;
@property (nonatomic,strong) NSString *endTimeString;
@property (nonatomic, copy) NSString *color;

// JSON 接口
- (MyEAutoControlPeriod *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAutoControlPeriod *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;


@end
