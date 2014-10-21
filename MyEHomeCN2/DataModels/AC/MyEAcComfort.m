//
//  MyEAcComfort.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcComfort.h"

@implementation MyEAcComfort
@synthesize comfortFlag, comfortRiseTime, comfortSleepTime;
#pragma mark
#pragma mark JSON methods
- (MyEAcComfort *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.comfortFlag = [[dictionary objectForKey:@"comfortFlag"] intValue] == 1;
        self.comfortRiseTime = [dictionary objectForKey:@"comfortRiseTime"]==nil?@"08:00":[dictionary objectForKey:@"comfortRiseTime"];
        self.comfortSleepTime = [dictionary objectForKey:@"comfortSleepTime"]== nil?@"22:00":[dictionary objectForKey:@"comfortSleepTime"];
        self.provinceId = dictionary[@"ProvinceCode"];
        self.cityId = dictionary[@"code"];
        return self;
    }
    return nil;
}

- (MyEAcComfort *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEAcComfort *comfort = [[MyEAcComfort alloc] initWithDictionary:dict];
    return comfort;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.comfortFlag?1:0], @"comfortFlag",
                          self.comfortRiseTime, @"comfortRiseTime",
                          self.comfortSleepTime, @"comfortSleepTime",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAcComfort alloc] initWithDictionary:[self JSONDictionary]];
}

@end
