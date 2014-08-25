//
//  MyEAcAutoControlPeriod.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/18/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAutoControlPeriod.h"
#import "SBJson.h"
#import "MyEUtil.h"

@implementation MyEAutoControlPeriod
@synthesize pId = _pId, stid = _stid, etid = _etid,  runMode = _runMode, windLevel = _windLevel, setpoint = _setpoint, color = _color;

- (MyEAutoControlPeriod *)init {
    if (self = [super init]) {
        _pId = (NSInteger)[[NSDate date]timeIntervalSince1970];
        _stid = 0;
        _etid = 1;
        _runMode = 1;
        _windLevel = 0;
        _setpoint = 25;
        _color = @"";
        return self;
    }
    return nil;
}

#pragma mark
#pragma mark JSON methods
- (MyEAutoControlPeriod *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.pId = [[dictionary objectForKey:@"id"] intValue];
        self.stid = [[dictionary objectForKey:@"stid"] intValue];
        self.etid = [[dictionary objectForKey:@"etid"] intValue];
        self.runMode = [[dictionary objectForKey:@"runMode"] intValue];
        self.windLevel = [[dictionary objectForKey:@"windLevel"] intValue];
        self.setpoint = [[dictionary objectForKey:@"setpoint"] intValue];
        self.color = [dictionary objectForKey:@"color"];

        return self;
    }
    return nil;
}

- (MyEAutoControlPeriod *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEAutoControlPeriod *period = [[MyEAutoControlPeriod alloc] initWithDictionary:dict];
    return period;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.pId], @"id",
                          [NSNumber numberWithInteger:self.stid], @"stid",
                          [NSNumber numberWithInteger:self.etid], @"etid",
                          [NSNumber numberWithInteger:self.runMode], @"runMode",
                          [NSNumber numberWithInteger:self.windLevel], @"windLevel",
                          [NSNumber numberWithInteger:self.setpoint], @"setpoint",
                          self.color, @"color",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAutoControlPeriod alloc] initWithDictionary:[self JSONDictionary]];
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%i  %i",self.stid,self.etid];
}
#pragma mark
#pragma Utilites
// Utilities
-(NSString *)startTimeString
{
    return [MyEUtil timeStringForHhid:_stid];
}
-(NSString *)endTimeString
{
    return [MyEUtil timeStringForHhid:_etid];
}
@end
