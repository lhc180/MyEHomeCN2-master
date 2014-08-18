//
//  MyEAcTempMontor.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/24/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcTempMonitor.h"

@implementation MyEAcTempMonitor
@synthesize monitorFlag, autoRunFlag, minTemp, maxTemp;

#pragma mark
#pragma mark JSON methods
- (MyEAcTempMonitor *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.monitorFlag = [[dictionary objectForKey:@"temperatureRangeFlag"] intValue] == 1;
        self.autoRunFlag = [[dictionary objectForKey:@"autoRunAcFlag"] intValue] == 1;
        self.minTemp = [dictionary objectForKey:@"tmin"]?[[dictionary objectForKey:@"tmin"] integerValue]:18;
        self.maxTemp = [dictionary objectForKey:@"tmax"]?[[dictionary objectForKey:@"tmax"] integerValue]:22;
        
        return self;
    }
    return nil;
}

- (MyEAcTempMonitor *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEAcTempMonitor *acTempMonitor = [[MyEAcTempMonitor alloc] initWithDictionary:dict];
    return acTempMonitor;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.monitorFlag?1:0], @"temperatureRangeFlag",
                          [NSNumber numberWithInteger:self.autoRunFlag?1:0], @"autoRunAcFlag",
                          [NSNumber numberWithInteger:self.minTemp], @"tmin",
                          [NSNumber numberWithInteger:self.maxTemp], @"tmax",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAcTempMonitor alloc] initWithDictionary:[self JSONDictionary]];
}


@end
