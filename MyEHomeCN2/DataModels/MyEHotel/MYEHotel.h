//
//  MYEHotel.h
//  MyEHomeCN2
//
//  Created by zhaiqiang on 14/10/15.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MYEHotelDetail;
@interface MYEHotel : NSObject

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *pin;
@property (nonatomic, strong) NSString *gid;  //酒店的GID
@property (nonatomic, strong) NSMutableArray *hotels;
@property (nonatomic, strong) NSMutableArray *terminals;

-(MYEHotel *)initWithJsonString:(NSString *)string;
-(MYEHotel *)initWithDictionary:(NSDictionary *)dic;
-(MYEHotelDetail *)findHotelByGid:(NSString *)gid;
@end


@interface MYEHotelRoom : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, assign) NSInteger sortId;

-(NSMutableArray *)JsonString:(NSString *)string;
-(MYEHotelRoom *)initWithDictionary:(NSDictionary *)dic;
@end

@interface MYEHotelDetail : NSObject

@property (nonatomic, strong) NSString *gid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cityId;
@property (nonatomic, assign) NSInteger sortId;
@property (nonatomic, strong) NSMutableArray *rooms;

-(MYEHotelDetail *)initWithDictionary:(NSDictionary *)dic;
@end

@interface MYEHotelTerminal : NSObject

@property (nonatomic, strong) NSString *tid;
@property (nonatomic, strong) NSString *roomName;

-(MYEHotelTerminal *)initWithDictionary:(NSDictionary *)dic;
@end