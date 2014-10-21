//
//  MyEDevice.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEDevice.h"
#import "SBJson.h"
#import "MyEDeviceStatus.h"

@implementation MyEDevice
@synthesize deviceId, tId, name, brandId, modelId, brand,
model, roomId, type, status, isSystemDefined,
instructionMode, acInstructionSet, irKeySet;

- (MyEDevice *)init {
    if (self = [super init]) {
        deviceId = 0;
        name = @"新设备";
        tId = @"未绑定智控星";
        brandId = 0;
        modelId = 0;
        brand = @"";
        model = @"";
        roomId = 0;   //0为未指定房间,这个对于新增设备时尤为有用
        type = 1;
        status = [[MyEDeviceStatus alloc] init];
        isSystemDefined = YES;
        acInstructionSet = Nil;
        irKeySet = Nil;
        instructionMode = 1;
        return self;
    }
    return nil;
}

#pragma mark
#pragma mark JSON methods
- (MyEDevice *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.deviceId = [[dictionary objectForKey:@"id"] intValue];
        self.tId = [dictionary objectForKey:@"tId"];
        self.name = [dictionary objectForKey:@"name"];
        self.brandId = [[dictionary objectForKey:@"brandId"] intValue];
        self.modelId = [[dictionary objectForKey:@"modelId"] intValue];
        self.brand = [dictionary objectForKey:@"brand"];
        self.model = [dictionary objectForKey:@"model"];
        self.roomId = [[dictionary objectForKey:@"roomId"] intValue];
        self.type = [[dictionary objectForKey:@"type"] intValue];
        self.status = [[MyEDeviceStatus alloc] initWithDictionary:[dictionary objectForKey:@"staus"]];// should be "status", but backend has a typo to staus
        self.isSystemDefined = [[dictionary objectForKey:@"isSystemDefined"] intValue] == 1;
        self.instructionMode = [[dictionary objectForKey:@"instructionMode"] intValue];
        return self;
    }
    return nil;
}

- (MyEDevice *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEDevice *deviceType = [[MyEDevice alloc] initWithDictionary:dict];
    return deviceType;
}
- (NSDictionary *)JSONDictionary {
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.deviceId], @"deviceId",
                          self.tId, @"tId",
                          self.name, @"name",
                          [NSNumber numberWithInteger:self.brandId], @"brandId",
                          [NSNumber numberWithInteger:self.modelId], @"modelId",
                          self.brand, @"brand",
                          self.model, @"model",
                          [NSNumber numberWithInteger:self.roomId], @"roomId",
                          [NSNumber numberWithInteger:self.type], @"type",
                          [self.status JSONDictionary], @"status",
                          [NSNumber numberWithInteger:self.isSystemDefined?1:0], @"isSystemDefined",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEDevice alloc] initWithDictionary:[self JSONDictionary]];
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@ 房间: %i 类型: %i TID: %@",self.name,self.roomId,self.type,self.tId];
}
-(MyEDevice *)newDevice:(MyEDevice *)device{
    MyEDevice *d = [[MyEDevice alloc] init];
    d.name = [device.name copy];
    d.tId = [device.tId copy];
    d.deviceId = device.deviceId;
    d.brand = [device.brand copy];
    d.brandId = device.brandId;
    d.model = [device.model copy];
    d.modelId = device.modelId;
    d.isSystemDefined = device.isSystemDefined;
    d.instructionMode = device.instructionMode;
    d.roomId = device.roomId;
    d.type = device.type;
    d.status = device.status;
    d.acInstructionSet = device.acInstructionSet;
    d.irKeySet = device.irKeySet;
    return d;
}
#pragma mark 属性方法
- (BOOL)isInitialized{
    return ![self.brand isEqualToString:@""] && ![self.model isEqualToString:@""];
//    return self.modelId > 0;
}
- (BOOL)isOrphan{
    if (self.type >= 8) {
        return NO;
    }else
        return [self.tId length] == 0;
}
- (BOOL)isConnected{
    if (self.type >= 8) {
        return YES;
    }else
        return self.status.connection > 0;
}
-(NSString *)connectionImage{
    NSString *imageFilename;
    if (self.type == 8 || self.type == 9 || self.type == 10 || self.type == 11) {
        if (self.status.alertStatus == 1) {
            imageFilename = @"safeAlert";
        }else
            imageFilename = @"";
    }else if (self.type == 12 || self.type == 13){
        imageFilename = @"";
    }else if (self.isOrphan) {
        imageFilename= @"noconnection";
    }else
        imageFilename= [NSString stringWithFormat:@"signal%ld", (long)self.status.connection];
    return imageFilename;
}
- (NSArray *)maxElecArray{    //插座设置中的最大电流
    NSMutableArray *_maxElecArray = [NSMutableArray array];
    for (int i = 1; i < 13; i++) {
        [_maxElecArray addObject:[NSString stringWithFormat:@"%i A",i]];
    }
    return _maxElecArray;
}
@end
