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
        self.needDownloadInstructionsForScene = YES;
        self.provinceId = @"";
        self.cityId = @"";
        if (dictionary[@"mediatorList"]) {
            self.mediators = [NSMutableArray array];
            for (NSDictionary *d in dictionary[@"mediatorList"]) {
                [self.mediators addObject:[[MyEMediator alloc] initWithDictionary:d]];
            }
        }else{
            self.mId = [dictionary objectForKey:@"mId"];
            self.mStatus = [[dictionary objectForKey:@"mStatus"] intValue];
        }
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
        
        self.allTerminals = [NSMutableArray array];

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
    for (MyETerminal *t in self.terminals) {
        if ([t.tId isEqualToString:tId]) {
            return t;
        }
    }
    return nil;
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
    for (MyERoom *r in self.rooms) {
        if (r.roomId == roomId) {
            return r;
        }
    }
    return nil;
}
- (MyEDevice *)findDeviceWithDeviceId:(NSInteger)deviceId{
    for (MyEDevice *d in self.devices) {
        if (d.deviceId == deviceId) {
            return d;
        }
    }
    return nil;
}
- (MyEDeviceType *)findDeviceTypeWithId:(NSInteger)deviceTypeId{
    for (MyEDeviceType *dt in self.deviceTypes) {
        if (dt.dtId == deviceTypeId) {
            return dt;
        }
    }
    return nil;
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
- (void)addOrDeleteRoom:(MyERoom *)room isAdd:(BOOL)isAdd{
    if (isAdd) {
        [self.rooms addObject:room];
    }else{
        if ([self.rooms containsObject:room]) {
            [self.rooms removeObject:room];
        }
    }
}

- (void)editRoom:(MyERoom *)oldRoom withNewRoom:(MyERoom *)newRoom{
    if ([self.rooms containsObject:oldRoom]) {
        NSInteger i = [self.rooms indexOfObject:oldRoom];
        [self.rooms removeObject:oldRoom];
        [self.rooms insertObject:newRoom atIndex:i];
    }
}

-(void)addOrDeleteDevice:(MyEDevice *)device isAdd:(BOOL)isAdd{
    if (device) {
//#warning 这里有个问题
//        for (MyETerminal *t in self.terminals) {
//            if ([t.tId isEqualToString:device.tId]) {
//                device.status.connection = t.conSignal;
//                break;
//            }
//        }
//        for (MyETerminal *t in self.terminals) {
//            if ([t.tId isEqualToString:device.tId]) {
//                device.status.connection = t.conSignal;
//                break;
//            }
//        }
        for (MyERoom *r in self.rooms) {
            if (r.roomId == device.roomId) {
                if (isAdd) {
                    if (![r.devices containsObject:@(device.deviceId)]) {
                        [r.devices addObject:@(device.deviceId)];
                    }
                }else{
                    if ([r.devices containsObject:@(device.deviceId)]) {
                        [r.devices removeObject:@(device.deviceId)];
                    }
                }
                break;
            }
        }
        
        for (MyEDeviceType *dt in self.deviceTypes) {
            if (dt.dtId == device.type) {
                if (isAdd) {
                    if (![dt.devices containsObject:@(device.deviceId)]) {
                        [dt.devices addObject:@(device.deviceId)];
                    }
                }else{
                    if ([dt.devices containsObject:@(device.deviceId)]) {
                        [dt.devices removeObject:@(device.deviceId)];
                    }
                }
                break;
            }
        }
        
        if (isAdd) {
            if (![self.devices containsObject:device]) {
                [self.devices addObject:device];
            }
        }else{
            if ([self.devices containsObject:device]) {
                [self.devices removeObject:device];
            }
        }
    }
}
- (void)editDevice:(MyEDevice *)oldDevice withNewDevice:(MyEDevice *)newDevice{
    
    if (![oldDevice.tId isEqualToString:newDevice.tId]) {
        newDevice.brand = @"";
        newDevice.brandId = 0;
        newDevice.model = @"";
        newDevice.modelId = 0;
    }
    
    if ([self.devices containsObject:oldDevice]) {
        NSInteger i = [self.devices indexOfObject:oldDevice];
        [self.devices removeObject:oldDevice];
        [self.devices insertObject:newDevice atIndex:i];
    }
//    for (MyERoom *r in self.rooms) {
//        if (r.roomId == oldDevice.roomId) {
//            if ([r.devices containsObject:@(oldDevice.deviceId)]) {
//                [r.devices removeObject:@(oldDevice.deviceId)];
//            }
//            break;
//        }
//    }
//    
//    for (MyERoom *r in self.rooms) {
//        if (r.roomId == newDevice.roomId) {
//            if (![r.devices containsObject:@(newDevice.deviceId)]) {
//                [r.devices addObject:@(newDevice.deviceId)];
//            }
//            break;
//        }
//    }
    
    for (MyERoom *r in self.rooms) {
        if (r.roomId == newDevice.roomId) {
            if (![r.devices containsObject:@(newDevice.deviceId)]) {
                [r.devices addObject:@(newDevice.deviceId)];
            }
        }
        if (r.roomId == oldDevice.roomId) {
            if ([r.devices containsObject:@(oldDevice.deviceId)]) {
                [r.devices removeObject:@(oldDevice.deviceId)];
            }
        }
    }
    
}

- (MyETerminal *)findDeviceTerminalWithDevice:(MyEDevice *)device{
    if (device.type > 11) {
        MyETerminal *t = [[MyETerminal alloc] init];
        t.tId = device.tId;
        return t;
    }
    for (MyETerminal *t in self.terminals) {
        if ([t.tId isEqualToString:device.tId]) {
            return t;
        }
    }
    
    return nil;
}
- (MyERoom *)findDeviceRoomWithDevice:(MyEDevice *)device{
    for (MyERoom *r in self.rooms) {
        if (r.roomId == device.roomId) {
            return r;
        }
    }
    return nil;
}

- (MyEDeviceType *)findDeviceDeviceTypeWithDevice:(MyEDevice *)device{
    for (MyEDeviceType *dt in self.deviceTypes) {
        if (dt.dtId == device.type) {
            return dt;
        }
    }
    return nil;
}

- (NSArray *)validTerminalsForAC{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.terminals];
    for (MyEDevice *d in self.devices) {
        if (d.type == 1) {
            MyETerminal *t = [self findDeviceTerminalWithDevice:d];
            if ([array containsObject:t]) {
                [array removeObject:t];
            }
        }
    }
    return array;
}
-(NSArray *)validDeviceTypeToAddWithAC:(BOOL)hasAc{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.deviceTypes];
    for (MyEDeviceType *dt in self.deviceTypes) {
        if (dt.dtId == 1 && !hasAc) {
            if ([array containsObject:dt]) {
                [array removeObject:dt];
            }
        }
        if (dt.dtId == 6 || dt.dtId == 7) {
            if ([array containsObject:dt]) {
                [array removeObject:dt];
            }
        }
    }
    return array;
}

-(NSMutableArray *)allDeviceInRoom:(MyERoom *)room{
    if (room == nil) {  //这个表示返回所有设备
        return self.devices;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (NSNumber *i in room.devices) {
        for (MyEDevice *d in self.devices) {
            if (d.deviceId == i.intValue) {
                [array addObject:d];
                break;
            }
        }
    }
    return array;
}
-(MyEAccountData *)newAccoutData:(MyEAccountData *)AccountData{
    MyEAccountData *accout = [[MyEAccountData alloc] init];
    accout.userId = [AccountData.userId copy];
    accout.userName = [AccountData.userName copy];
    accout.loginSuccess = AccountData.loginSuccess;
    accout.mId = [AccountData.mId copy];
    accout.mStatus = AccountData.mStatus;
    accout.needDownloadInstructionsForScene = YES;
    accout.deviceTypes = [AccountData.deviceTypes mutableCopy];
    accout.devices = [AccountData.devices mutableCopy];
    accout.rooms = [AccountData.rooms mutableCopy];
    accout.terminals = [AccountData.terminals mutableCopy];
    accout.allTerminals = [self.allTerminals mutableCopy];
    return accout;
}
-(BOOL)alertHappen{
    if ([[self.mId substringToIndex:5] isEqualToString:@"05-00"]) {
        return NO;
    }
    for (MyEDevice *d in self.devices) {
        if (d.type > 7) {
            if (d.status.alertStatus == 1) {
                return YES;
            }
        }
    }
   return NO;
}

-(BOOL)hasNoMediator{
    if (self.mediators != nil) {
        if (self.mediators.count == 0) {
            return YES;
        }
    }else{
        if ([self.mId isEqualToString:@""] || self.mId == nil) {
            return YES;
        }
    }
    return NO;
}
-(BOOL)allMediatorOffLine{
    if (self.mediators != nil) {
        BOOL allOffLine = YES;
        for (MyEMediator *m in self.mediators) {
            if (m.isOn) {
                allOffLine = NO;
                break;
            }
        }
        return allOffLine;
    }else{
        if (self.mStatus == 0) {
            return YES;
        }
    }
    return NO;
}
-(NSMutableArray *)validMeditors{
    NSMutableArray *array = [NSMutableArray array];
    for (MyEMediator *m in self.mediators) {
        if (m.isOn) {
            [array addObject:m];
        }
    }
    return array;
}
@end


@implementation MyEMediator
-(instancetype)init{
    if (self = [super init]) {
        self.mid = @"";
        self.pin = @"";
        self.isOn = YES;
        self.terminals = [NSMutableArray array];
        self.subSwitchList = [NSMutableArray array];
    }
    return self;
}
-(MyEMediator *)initWithJSONString:(NSString *)str{
    NSDictionary *dic = [str JSONValue];
    return [[MyEMediator alloc] initWithDictionary:dic];
}
-(MyEMediator *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.mid = dic[@"MId"];
        self.isOn = [dic[@"status"] intValue] == 1;
        if (dic[@"pin"]) {
            self.pin = dic[@"pin"];
        }
        if (dic[@"terminals"]) {
            self.terminals = [NSMutableArray array];
            for (NSDictionary *terminal in [dic objectForKey:@"terminals"]) {
                //向irTerminals可变数组中添加对象，这些对象是解析过的
                [self.terminals addObject:[[MyETerminal alloc] initWithDictionary:terminal]];
            }
        }
        if (dic[@"subSwitchList"]) {
            _subSwitchList = [NSMutableArray array];
            for (NSDictionary *d in dic[@"subSwitchList"]) {
                [_subSwitchList addObject:[[MyESettingSubSwitch alloc] initWithDictionary:d]];
            }
        }
        return self;
    }
    return nil;
}

@end
