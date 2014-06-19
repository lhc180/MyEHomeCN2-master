//
//  AccountData.m
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEAccountData.h"
#import "SBJson.h"
#import "MyEDeviceType.h"
#import "MyEDevice.h"
#import "MyERoom.h"
#import "MyETerminal.h"

@interface MyEAccountData ()
//- (void)initializeDefaultHouseList;
@end

@implementation MyEAccountData
@synthesize userId = _userId, userName = _userName, 
            rememberMe = _rememberMe, 
            loginSuccess = _loginSuccess,
            mId = _mId, mStatus = _mStatus,
            deviceTypes = _deviceTypes, devices = _devices,
            rooms = _rooms, terminals = _terminals,
            needDownloadInstructionsForScene = _needDownloadInstructionsForScene;



#pragma mark
#pragma mark JSON methods
- (MyEAccountData *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.userId = [dictionary objectForKey:@"gid"];
        self.userName = [dictionary objectForKey:@"userName"];
        self.loginSuccess = [[dictionary objectForKey:@"success"] intValue];
        self.mId = [dictionary objectForKey:@"mId"];
        self.mStatus = [[dictionary objectForKey:@"mStatus"] intValue];
        self.needDownloadInstructionsForScene = YES;

        NSArray *array = [dictionary objectForKey:@"irTypes"];
        NSMutableArray *deviceTypes = [NSMutableArray array];
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *deviceType in array) {
                [deviceTypes addObject:[[MyEDeviceType alloc] initWithDictionary:deviceType]];
            }
        }
        self.deviceTypes = deviceTypes;
        
        array = [dictionary objectForKey:@"devicesList"];
        NSMutableArray *devices = [NSMutableArray array];
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *device in array) {
                [devices addObject:[[MyEDevice alloc] initWithDictionary:device]];
            }
        }
        self.devices = devices;
        
        array = [dictionary objectForKey:@"rooms"];
        NSMutableArray *rooms = [NSMutableArray array];
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *room in array) {
                [rooms addObject:[[MyERoom alloc] initWithDictionary:room]];
            }
        }
        self.rooms = rooms;
        
        array = [dictionary objectForKey:@"irList"];
        NSMutableArray *terminals = [NSMutableArray array];
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *terminal in array) {
                [terminals addObject:[[MyETerminal alloc] initWithDictionary:terminal]];
            }
        }
        self.terminals = terminals;

        return self;
    }
    return nil;
}

- (MyEAccountData *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEAccountData *account = [[MyEAccountData alloc] initWithDictionary:dict];
    return account;
}
- (NSDictionary *)JSONDictionary {
    // 这里把devices里面的每个device对象进行json序列化后放入数组devices。这样才能把数组devices进行正确的JSON序列化
    NSMutableArray *devices = [NSMutableArray array];
    for (MyEDevice *device in self.devices)
        [devices addObject:[device JSONDictionary]];
    
    NSMutableArray *rooms = [NSMutableArray array];
    for (MyERoom *room in self.rooms)
        [rooms addObject:[room JSONDictionary]];
    
    NSMutableArray *deviceTypes = [NSMutableArray array];
    for (MyEDeviceType *deviceType in self.deviceTypes)
        [deviceTypes addObject:[deviceType JSONDictionary]];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.userId, @"gid",
                          self.userName, @"userName",
                          self.mId, @"mId",
                          [NSNumber numberWithInteger:self.mStatus], @"mStatus",
                          deviceTypes, @"deviceTypes",//这里不能把devices直接放在值的位置，因为其中数组的每个元素没有正确地进行JSON字符串序列化
                          devices, @"devices",
                          rooms, @"rooms",
                          [NSNumber numberWithBool:self.needDownloadInstructionsForScene ], @"needDownloadInstructionsForScene",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAccountData alloc] initWithDictionary:[self JSONDictionary]];
}


- (NSInteger)findIndexOfFirstTerminalWithTid:(NSString *)tId
{
    for(int i = 0; i < [self.terminals count]; i++){
        MyETerminal *t = [self.terminals objectAtIndex:i];
        if ([t.tId isEqualToString:tId])
            return i;
    }
    return 0;
}
- (MyETerminal *)findFirstTerminalWithTid:(NSString *)tId
{
    for(int i = 0; i < [self.terminals count]; i++){
        MyETerminal *t = [self.terminals objectAtIndex:i];
        if ([t.tId isEqualToString:tId])
            return t;
    }
    return Nil;
}

- (NSInteger)findIndexOfFirstRoomWithRoomId:(NSInteger)roomId
{
    for(int i = 0; i < [self.rooms count]; i++){
        MyERoom *room = [self.rooms objectAtIndex:i];
        if (room.roomId == roomId)
            return i;
    }
    return 0;
}
- (MyERoom *)findFirstRoomWithRoomId:(NSInteger)roomId
{
    for(int i = 0; i < [self.rooms count]; i++){
        MyERoom *room = [self.rooms objectAtIndex:i];
        if (room.roomId == roomId)
            return room;
    }
    return Nil;
}
- (MyEDevice *)findDeviceWithDeviceId:(NSInteger)deviceId{
    for(int i = 0; i < [self.devices count]; i++){
        MyEDevice *device = [self.devices objectAtIndex:i];
        if (device.deviceId == deviceId)
            return device;
    }
    return Nil;
}
- (MyEDeviceType *)findDeviceTypeWithId:(NSInteger)deviceTypeId{
    for(int i = 0; i < [self.deviceTypes count]; i++){
        MyEDeviceType *deviceType = [self.deviceTypes objectAtIndex:i];
        if (deviceType.dtId == deviceTypeId)
            return deviceType;
    }
    return Nil;
}
// 给定一个设备id, 找到所有还没有绑定空调的智控星, 如果给定的设备id小于等于0, 就表示为一个不存在的\准备新增的空调寻找有效的智控星列表, 否则返回的智控星列表, 要包含此设备本来就绑定的智控星
- (NSArray *)findValidTerminalsForACDeviceId:(NSInteger)deviceId
{
    NSMutableArray *terminals = [NSMutableArray array];
    for (MyETerminal *t in self.terminals) {
        if ([[t.tId substringToIndex:2] intValue] != 1) {// 次T不是智控性
            continue;
        }
        // 添加代码判定是否该转发器已经带有空调了
        BOOL hasAc = NO;
        for (MyEDevice *device in self.devices ) {//这里逻辑不对
            if ([device.tId isEqualToString:t.tId]) { //如果有设备的tid和这个智控星的tid相同
                if (device.type == 1) {   //且这个设备的类型是空调，那么就说这个智控星不可用
                    hasAc = YES;
                }
            }
            if (device.deviceId == deviceId) {
                if ([device.tId isEqualToString:t.tId]) {
                    [terminals addObject:t];
                }
            }
        }
        if(!hasAc){
            [terminals addObject:t];
        }
    }
    if ([terminals count] == 0) {
        MyETerminal *t = [[MyETerminal alloc] init];
        t.name = @"- - - - - -";
        t.tId = @"00-00-00-00-00-00-00-00";
        [terminals addObject:t];
    }
    return terminals;
}
@end
