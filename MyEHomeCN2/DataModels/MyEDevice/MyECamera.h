//
//  MyECamera.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPPPChannelManagement.h"

@interface MyECamera : NSObject <NSCopying>
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@property (nonatomic, assign) NSInteger deviceId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *UID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *imagePath;  //本地存储图片
@property (nonatomic) BOOL isOnline;

- (MyECamera *)initWithDictionary:(NSDictionary *)dictionary;
- (MyECamera *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end

@interface MyEMainCamera : NSObject

@property (nonatomic, copy) NSMutableArray *cameras;

- (MyEMainCamera *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEMainCamera *)initWithJSONString:(NSString *)jsonString;
- (NSString *)JSONDictionary;

@end

@interface MyECameraWifi : NSObject
@property (nonatomic, strong) NSString *UID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger security;
@property (nonatomic, assign) NSInteger signal;
-(UIImage *)changeSignalToImage;
@end

@interface MyECameraAlarm : NSObject
@property (nonatomic, assign) NSInteger motion_armed;  //移动侦测开关 0: 关闭 1: 打开
@property (nonatomic, assign) NSInteger motion_sensitivity; //移动侦测灵敏度 取值 1~10 (取值越小越灵敏)
@property (nonatomic, assign) NSInteger input_armed;  //输入报警开关 0: 关闭 1: 打开
@property (nonatomic, assign) NSInteger ioin_level; //输入报警触发电平 0: 低电平 1: 高电平
@property (nonatomic, assign) NSInteger iolinkage; //报警 IO 输出联动开关 0: 关闭 1: 打开
@property (nonatomic, assign) NSInteger ioout_level;  //报警输出电平 0: 低电平 1: 高电平
@property (nonatomic, assign) NSInteger alarmpresetsit; //报警调用预置位 取值 0~16 0 表示不调用预置位
@property (nonatomic, assign) NSInteger record;  //报警录像 0: 关闭 1: 打开
//以下不常用
@property (nonatomic, assign) NSInteger mail;  //报警发送邮件 0: 关闭 1: 打开
@property (nonatomic, assign) NSInteger snapshot;  //报警抓图 0: 关闭 1: 打开 (目前不支持)
@property (nonatomic, assign) NSInteger upload_interval;  //报警 ftp 上传时间间隔(单位秒) 0 表示不上传
@property (nonatomic, assign) NSInteger schedule_enable;  //报警布防开关 0: 关闭 1: 打开 (注意:关闭布防,将不会触发任何报警)
-(NSInteger)getMotion_sensitivity;
-(NSArray *)motion_sensitivityArray;
-(NSArray *)ioin_levelArray;
-(NSArray *)alarmpresetsitArray;
-(NSArray *)ioout_levelArray;
@end

@interface MyECameraParam : NSObject

@property (nonatomic, assign) NSInteger resolution;  //分辨路  0:640*480   1:320*240
@property (nonatomic, assign) NSInteger bright;   //亮度  1-255
@property (nonatomic, assign) NSInteger contrast;   //对比度  1-255
@property (nonatomic, assign) NSInteger hue;   //色度
@property (nonatomic, assign) NSInteger saturation;  //饱和度
@property (nonatomic, assign) NSInteger osdenable;
@property (nonatomic, assign) NSInteger mode;
@property (nonatomic, assign) NSInteger flip;
@property (nonatomic, assign) NSInteger enc_framerate;
@property (nonatomic, assign) NSInteger sub_enc_framerate;

@end

@interface MyECameraPTZ : NSObject

@property (nonatomic, assign) NSInteger led_mode;  //led指示灯状态 0:关闭 1:打开
@property (nonatomic, assign) NSInteger center_onstart;  //启动时云台自动居中  0:不居中 1:居中
@property (nonatomic, assign) NSInteger run_times; //云台在上下巡航,左右巡航时的巡航圈数 0:表示无限制(但是系统会限制最长时间为 1 小时)
@property (nonatomic, assign) NSInteger patrol_rate;  //云台上下巡航,左右巡航的速度,取值 1~10
@property (nonatomic, assign) NSInteger patrol_up_rate; //云台向上转动速度,取值 1~10
@property (nonatomic, assign) NSInteger patrol_down_rate;  //向下转动速度
@property (nonatomic, assign) NSInteger patrol_left_rate;  //向左转动速度
@property (nonatomic, assign) NSInteger patrol_right_rate;  //向右转动速度
@property (nonatomic, assign) NSInteger disable_preset;  // 禁用预置位  0:不禁用  1:禁用
@property (nonatomic, assign) NSInteger preset;  //启动时,对准预置位 取值 0~16,0 表示不对准预置位 1~16 分别对应预置位 1 至预置位 16


-(NSArray *)run_timesArray;
-(NSArray *)rateArray;
-(NSArray *)presetArray;

@end

@interface MyECameraDate : NSObject
@property (nonatomic, assign) NSInteger now;
@property (nonatomic, assign) NSInteger timeZone;
@property (nonatomic, assign) NSInteger ntp_enable;
@property (nonatomic, strong) NSString *ntp_svr;
@property (nonatomic, assign) NSInteger timeZoneIndex;  //下面的两个值主要用来表示在数组中的位置
@property (nonatomic, assign) NSInteger timeServerIndex;

-(NSArray *)timeZoneArray;
-(NSArray *)timeZoneIdArray;
-(NSArray *)timeServerArray;
@end

@interface MyECameraRecord : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, assign) BOOL bEnd;
-(NSString *)getTime;
-(NSString *)getDate;
@end

@interface MyECameraSDSchedule : NSObject
@property (nonatomic, assign) NSInteger total; //sd卡总容量
@property (nonatomic, assign) NSInteger remain;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger cover;
@property (nonatomic, assign) NSInteger timeLength;
@property (nonatomic, assign) NSInteger fixedTimeRecord;
@property (nonatomic, assign) NSInteger recordSize;
@property (nonatomic, assign) NSInteger sun_0,sun_1,sun_2;
@property (nonatomic, assign) NSInteger mon_0,mon_1,mon_2;
@property (nonatomic, assign) NSInteger tue_0,tue_1,tue_2;
@property (nonatomic, assign) NSInteger wed_0,wed_1,wed_2;
@property (nonatomic, assign) NSInteger thu_0,thu_1,thu_2;
@property (nonatomic, assign) NSInteger fri_0,fri_1,fri_2;
@property (nonatomic, assign) NSInteger sat_0,sat_1,sat_2;
-(NSArray *)weekArray;
-(NSString *)stringFromInt:(NSInteger)i;
-(NSInteger)intFromString:(NSString *)string;
@end