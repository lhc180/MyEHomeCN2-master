//
//  MyETerminal.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyETerminal.h"
#import "SBJson.h"

@implementation MyETerminal
@synthesize tId = _tId, name = _name,irType,roomId,conSignal,powerSaveMode,enableDataCollect;
#pragma mark
#pragma mark JSON methods
-(id)init{
    if (self = [super init]) {
        _tId = @"";
        _name = @"";
        irType = 0;
        roomId = 0;
        return self;
    }
    return nil;
}
- (MyETerminal *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.tId = [dictionary objectForKey:@"tId"];
        self.name = [dictionary objectForKey:@"name"];
        self.irType = [[dictionary objectForKey:@"irType"] intValue];
        self.roomId =[[dictionary objectForKey:@"roomId"] intValue];
        self.conSignal = [[dictionary objectForKey:@"conSignal"] intValue];
        self.powerSaveMode = [[dictionary objectForKey:@"powerSaveMode"] intValue];
        self.enableDataCollect = [[dictionary objectForKey:@"enableDataCollect"]intValue];
        return self;
    }
    return nil;
}

- (MyETerminal *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyETerminal *terminal = [[MyETerminal alloc] initWithDictionary:dict];
    return terminal;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.tId, @"tId",
                          self.name, @"name",
                          [NSNumber numberWithInteger:self.irType],@"irType",
                          [NSNumber numberWithInteger:self.roomId],@"roomId",
                          [NSNumber numberWithInteger:self.conSignal],@"conSignal",
                          [NSNumber numberWithInteger:self.powerSaveMode],@"powerSaveMode",
                          [NSNumber numberWithInteger:self.enableDataCollect],@"enableDataConllect",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyETerminal alloc] initWithDictionary:[self JSONDictionary]];
}

@end
