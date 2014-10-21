//
//  MYEHotel.m
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/15.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEHotel.h"

@implementation MYEHotel

//{"terminalList":[{"roomName":"","TId":"01-00-00-00-00-00-01-4B"},{"roomName":"","TId":"01-00-00-00-00-00-00-CA"}],"entMemberGid":"","roomList":[],"roomName":"","entMemberList":[{"gid":"66822b56-9560-ff55-bdec-a8891054efd9","entTrueName":"苹果酒店","cityCode":"101240501","sortId":3},{"gid":"db7e05fa-a790-12ea-1bb2-e1bad673cf5e","entTrueName":"景福主题酒店","cityCode":"101240501","sortId":6}],"pin":"123456","m_id":"05-00-00-00-00-00-07-F9","status":1,"message":"The request success"}
-(MYEHotel *)initWithJsonString:(NSString *)string{
    return [[MYEHotel alloc] initWithDictionary:[string JSONValue]];
}
-(MYEHotel *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.status = [dic[@"status"] intValue];
        self.message  = dic[@"message"];
        self.pin = dic[@"pin"];
        self.gid = dic[@"entMemberGid"];
        self.hotels = [NSMutableArray array];
        for (NSDictionary *d in dic[@"entMemberList"]) {
            [self.hotels addObject:[[MYEHotelDetail alloc] initWithDictionary:d]];
        }
        
        self.terminals = [NSMutableArray array];
        for (NSDictionary *d in dic[@"terminalList"]) {
            [self.terminals addObject:[[MYEHotelTerminal alloc] initWithDictionary:d]];
        }
        MYEHotelDetail *detail = self.hotels[0];
        for (NSDictionary *d in dic[@"roomList"]) {
            [detail.rooms addObject:[[MYEHotelRoom alloc] initWithDictionary:d]];
        }
        return self;
    }
    return nil;
}
-(MYEHotelDetail *)findHotelByGid:(NSString *)gid{
    for (MYEHotelDetail *d in self.hotels) {
        if ([d.gid isEqualToString:gid]) {
            return d;
        }
    }
    return self.hotels[0];
}
@end

@implementation MYEHotelDetail

-(MYEHotelDetail *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.gid = dic[@"gid"];
        self.name = dic[@"entTrueName"];
        self.cityId = dic[@"cityCode"];
        self.rooms = [NSMutableArray array];
        return self;
    }
    return nil;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@",self.rooms];
}
@end

@implementation MYEHotelTerminal

-(MYEHotelTerminal *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.tid = dic[@"TId"];
        self.roomName = dic[@"roomName"];
        return self;
    }
    return nil;
}

@end

@implementation MYEHotelRoom

-(NSMutableArray *)JsonString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    NSMutableArray *rooms = [NSMutableArray array];
    for (NSDictionary *d in dic[@"roomList"]) {
        [rooms addObject:[[MYEHotelRoom alloc] initWithDictionary:d]];
    }
    return rooms;
}

-(MYEHotelRoom *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.name = dic[@"name"];
        self.roomId = [dic[@"id"] intValue];
        self.sortId = [dic[@"sortId"] intValue];
        return self;
    }
    return nil;
}

@end

