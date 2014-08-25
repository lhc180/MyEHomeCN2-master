//
//  AccountData.h
//  MyE
//  这个类用于管理用户账户信息，当用户在界面上输入登录信息后，就把userName、
//  password、remember记录下来，然后ajax请求登录，登录成功后的信息返回后，
//  就把userId，houseList等信息都记录到这个类。
//  这个类还可以作为HouseData类的Controller，类似于
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEHouseData;
@class MyETerminal;
@class MyERoom;
@class MyEDevice;
@class MyEDeviceType;

@interface MyEAccountData : NSObject <NSCopying> 
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic) BOOL rememberMe;
@property (nonatomic) NSInteger loginSuccess;
@property (nonatomic, copy) NSString *mId;
@property (nonatomic) NSInteger mStatus;

// by YY
// 标志是不是要为场景下载最新的设备指令集合, 由于我们在指令学习之后, 空调修改品牌/下载控制码之后, 都需要设置次变量为YES, 表示需要重新下载.
//  原来只是在场景面板内部判断是否需要下载, 但现在吧这个变量移动到这里, 为的是方便传递值,在其他面板设置, 在场景面板访问.

// 注意要在每个指令学习之后, 空调修改品牌/下载控制码之后的地方设置下面变量为YES.  这里应该是新增内容
@property (nonatomic) BOOL needDownloadInstructionsForScene;

@property (nonatomic, strong) NSMutableArray *deviceTypes;
@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) NSMutableArray *rooms;
@property (nonatomic, strong) NSMutableArray *terminals;
@property (nonatomic, strong) NSMutableArray *allTerminals;

- (MyEAccountData *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAccountData *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;


- (NSInteger)findIndexOfFirstTerminalWithTid:(NSString *)tId;
- (MyETerminal *)findFirstTerminalWithTid:(NSString *)tId;
- (NSInteger)findIndexOfFirstRoomWithRoomId:(NSInteger)roomId;
- (MyERoom *)findFirstRoomWithRoomId:(NSInteger)roomId;
- (MyEDevice *)findDeviceWithDeviceId:(NSInteger)deviceId;
- (MyEDeviceType *)findDeviceTypeWithId:(NSInteger)deviceTypeId;
// 给定一个设备id, 找到所有还没有绑定空调的智控星, 如果给定的设备id小于等于0, 就表示为一个不存在的\准备新增的空调寻找有效的智控星列表, 否则返回的智控星列表, 要包含此设备本来就绑定的智控星
- (NSArray *)findValidTerminalsForACDeviceId:(NSInteger)deviceId;
@end
