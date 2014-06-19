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
        name = @"";
        brandId = 0;
        modelId = 0;
        brand = @"";
        model = @"";
        roomId = 0;
        type = 1;
        status = [[MyEDeviceStatus alloc] init];
        isSystemDefined = 0;
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

#pragma mark 属性方法
- (BOOL)isInitialized{
    return self.modelId > 0;
}
- (BOOL)isOrphan{
    return [self.tId length] == 0;
}
- (BOOL)isConnected{
    return self.status.connection > 0;
}
@end
