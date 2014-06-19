//
//  MyEAcAutoControlProgress.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/18/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAutoControlProcess : NSObject <NSCopying>
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger pId;// 进程id
@property (nonatomic, retain) NSMutableArray *periods;
@property (nonatomic, retain) NSMutableArray *days;// 1-Mon, 2-Tue, ..., 7-Sun

// JSON 接口
- (MyEAutoControlProcess *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAutoControlProcess *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;


// Utilities
-(BOOL) isValid;
// 给定一个现存时段的id，如果要给它分配新的开始结束时刻，此函数判定这个时段它是不是和其它时段有重叠, periodId是要判定的时段的id，如果该时段是一个新时段，它取-1
-(BOOL) validatePeriodWithId:(NSInteger)periodId newStid:(NSInteger)stid newEtid:(NSInteger)etid;
-(BOOL) isHhidUsed:(NSInteger)tid;
//获取可用的一个时段的开始时刻id，可能的取值范围是0~47，如果所有时刻都被占用了，没有可用的空时刻，就返回-1
-(NSInteger)firstAvailablePeriodStid;
// 根据时间前后排序时段， 调用下面函数的时候，必须保证各时段没有重叠。
- (void) sortPeriods;
@end
