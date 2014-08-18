//
//  MyEAcAutoControlProgress.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/18/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAutoControlProcess.h"
#import "SBJson.h"
#import "MyEAutoControlPeriod.h"

@implementation MyEAutoControlProcess
@synthesize name = _name, pId = _pId, periods = _periods, days = _days;

- (MyEAutoControlProcess *)init {
    if (self = [super init]) {
        _pId = 0;
        _name = @"";
        _periods = [[NSMutableArray alloc] init];
//        MyEAutoControlPeriod * period = [[MyEAutoControlPeriod alloc] init];
//        [_periods addObject:period];
        _days = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}

#pragma mark
#pragma mark JSON methods
- (MyEAutoControlProcess *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.pId = [[dictionary objectForKey:@"id"] intValue];
        self.name = [dictionary objectForKey:@"name"];
        
        NSArray *array = [dictionary objectForKey:@"periods"];
        NSMutableArray *periods = [NSMutableArray array];
        
        NSInteger count = 0;
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *periodDict in array) {
                MyEAutoControlPeriod *period = [[MyEAutoControlPeriod alloc] initWithDictionary:periodDict];
                if (period.pId <= 0) { // 初次从服务器获取到进程列表，其中的period的id都是0，这里给每个peirod设置一个惟一的id，此后，如果用copy方法进行克隆是，peirod就有id，就不用再次分配新id了
                    period.pId = (NSInteger)[[NSDate date]timeIntervalSince1970] + count; // Custom period id in Perocess
                }
                
                [periods addObject:period];
                count ++;
            }
        }
        self.periods = periods;
        
        array = [dictionary objectForKey:@"weekNames"];
        NSMutableArray *days = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSNumber *dayName in array) {
                [days addObject:[dayName copy]];
            }
        }
        self.days = days;
        
        
        return self;
    }
    return nil;
}

- (MyEAutoControlProcess *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEAutoControlProcess *deviceType = [[MyEAutoControlProcess alloc] initWithDictionary:dict];
    return deviceType;
}
- (NSDictionary *)JSONDictionary {
    NSMutableArray *periods = [NSMutableArray array];
    for (MyEAutoControlPeriod *period in self.periods)
        [periods addObject:[period JSONDictionary]];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.pId], @"id",
                          self.name, @"name",
                          periods, @"periods",//这里不能把devices直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          self.days, @"weekNames",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAutoControlProcess alloc] initWithDictionary:[self JSONDictionary]];
}

#pragma mark utilities methods
// 判定是否进程有效，有效性测试包括：每个时段是否由重叠，如果重叠，就无效
-(BOOL) isValid{
    // 如果只有一个时段，那次进程肯定有效，不会有重叠发生
    for (NSInteger i = 0; i < [self.periods count] - 1; i++) {
        for (NSInteger j = i + 1; j < [self.periods count]; j++) {
            MyEAutoControlPeriod *pi = [self.periods objectAtIndex:i];
            MyEAutoControlPeriod *pj = [self.periods objectAtIndex:j];
            // 保证和前一个时段有半小时间隔
            if((pi.stid < pj.stid && pi.etid <= pj.stid) ||
               (pj.stid < pi.stid && pj.etid <= pi.stid)){
                continue;
            }
            else {
                return NO;
            }
        }
    }
    return YES;
}

// 给定一个现存时段的id，如果要给它分配新的开始结束时刻，此函数判定这个时段它是不是和其它时段有重叠, periodId是要判定的时段的id，如果该时段是一个新时段，它取-1
-(BOOL) validatePeriodWithId:(NSInteger)periodId newStid:(NSInteger)stid newEtid:(NSInteger)etid{
    for (NSInteger j = 0; j < [self.periods count]; j++) {
        MyEAutoControlPeriod *period = [self.periods objectAtIndex:j];
        if(periodId == period.pId)
            continue;  // 如果时段相同，就跳过，不比较
        if((stid < period.stid && etid <= period.stid) ||
           (period.stid < stid && period.etid <= stid)){
            continue;
        }
        else {
            return NO;
        }
    }
    return YES;
}
// 给定一个半点id，判定这个半点是不是已经在已经添加的时段里面，也就是说它是否被占用
-(BOOL) isHhidUsed:(NSInteger)tid{
    for (NSInteger i = 0; i < [self.periods count]; i++) {
        MyEAutoControlPeriod *period = [self.periods objectAtIndex:i];
        if(period.stid <= tid && period.etid > tid){
            return YES;
        }
    }
    return NO;
}

//获取可用的一个时段的开始时刻id，可能的取值范围是0~47，如果所有时刻都被占用了，没有可用的空时刻，就返回-1
-(NSInteger)firstAvailablePeriodStid
{
    for (NSInteger i = 0; i < 47; i++) {
        if(![self isHhidUsed:i] && ![self isHhidUsed:i+1]){
            return i; // 保证和前一个时段有半小时间隔
        }
    }
    return -1;
}
// 根据时间前后排序时段， 调用下面函数的时候，必须保证各时段没有重叠。
- (void) sortPeriods
{
    id mySort = ^(MyEAutoControlPeriod * obj_a, MyEAutoControlPeriod * obj_b){
        NSInteger stid_a = obj_a.stid;
//        NSInteger etid_a = obj_a.etid;
        NSInteger stid_b = obj_b.stid;
//        NSInteger etid_b = obj_b.etid;
        return (stid_a > stid_b);
    };
    self.periods = [NSMutableArray arrayWithArray:[self.periods sortedArrayUsingComparator:mySort]];
    
    // 重设每个period的id为其在数组中的序号
    for (NSInteger i = 0; i < [self.periods count]; i++) {
        MyEAutoControlPeriod *p = [self.periods objectAtIndex:i];
        p.pId = i;
    }
}
@end
