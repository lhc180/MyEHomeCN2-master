//
//  MyECamera.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import "MyECamera.h"

@implementation MyECamera
#pragma mark
#pragma mark JSON methods
- (id)init {
    if (self = [super init]) {
        _UID = @"";
        _name = @"IPCAM";
        _username = @"admin";
        _password = @"888888";
        _imagePath = @"";
        _isOnline = NO;
        _status = @"未知";
        _deviceId = 0;
        _statusValue = 0;
        return self;
    }
    return nil;
}

- (MyECamera *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [self init]) {
        self.deviceId = [dictionary[@"id"] intValue];
        self.userId = [dictionary[@"userId"] intValue];
        self.UID = [dictionary objectForKey:@"did"];
        self.name = [dictionary objectForKey:@"name"];
        self.username = [dictionary objectForKey:@"user"];
        self.password = [dictionary objectForKey:@"pwd"];
        self.imagePath = @"";
        self.isOnline = NO;
        self.status = @"未知";
        self.statusValue = 0;
        return self;
    }
    return nil;
}

- (MyECamera *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyECamera *camera = [[MyECamera alloc] initWithDictionary:dict];
    return camera;
}
- (NSDictionary *)JSONDictionary {
    return @{@"UID": self.UID,
             @"name": self.name,
             @"username": self.username,
             @"password": self.password,
             @"imagePath":self.imagePath==nil?@"":self.imagePath};
}
#pragma mark - NSCopying delegate methods
-(id)copyWithZone:(NSZone *)zone {
    return [[MyECamera alloc] initWithDictionary:[self JSONDictionary]];
}
#pragma mark - NSLog methods
-(NSString *)description{
    return [NSString stringWithFormat:@"name:%@  UID:%@  userName:%@  password:%@ status:%@",self.name,self.UID,self.username,self.password,self.status];
}
@end


@implementation MyEMainCamera

- (MyEMainCamera *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.cameras = [NSMutableArray array];
        for (NSDictionary *d in dic[@"cameras"]) {
            [self.cameras addObject:[[MyECamera alloc] initWithDictionary:d]];
        }
        return self;
    }
    return nil;
}
-(MyEMainCamera *)initWithArray:(NSArray *)array{
    if (self = [super init]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *d in array) {
            [array addObject:[[MyECamera alloc] initWithDictionary:d]];
        }
        self.cameras = array;
        return self;
    }
    return nil;
}
- (MyEMainCamera *)initWithJSONString:(NSString *)jsonString{
    NSArray *array = [jsonString JSONValue];
    MyEMainCamera *main = [[MyEMainCamera alloc] initWithArray:array];
    return main;
}
- (NSString *)JSONDictionary{
    NSMutableArray *cameras = [NSMutableArray array];
    for (MyECamera *c in self.cameras) {
        [cameras addObject:[c JSONDictionary]];
    }
    SBJsonWriter *write = [[SBJsonWriter alloc] init];
    NSString *string = [write stringWithObject:cameras];
    return string;
}

@end

@implementation MyECameraWifi

-(id)init{
    if (self = [super init]) {
        self.UID = @"";
        self.name = @"";
        self.security = 0;
        self.signal = 0;
    }
    return self;
}
-(UIImage *)changeSignalToImage{
    NSString *imageName = nil;
    if (self.signal < 20) {
        imageName = @"signal0";
    }else if (self.signal < 40){
        imageName = @"signal1";
    }else if (self.signal < 60){
        imageName = @"signal2";
    }else if (self.signal < 80){
        imageName = @"signal3";
    }else
        imageName = @"signal4";
    return [UIImage imageNamed:imageName];
}
@end

@implementation MyECameraAlarm

-(id)init{
    if (self = [super init]) {
        self.motion_armed = 0;
        self.motion_sensitivity = 0;
        self.input_armed = 0;
        self.ioin_level = 0;
        self.iolinkage = 0;
        self.ioout_level = 0;
        self.alarmpresetsit = 0;
        self.record = 0;
        self.mail = 0;
        self.snapshot = 0;
        self.upload_interval = 0;
        self.schedule_enable = 0;
    }
    return self;
}
-(NSInteger)getMotion_sensitivity{
    if (self.motion_sensitivity <4) {
        return 0;
    }else if (self.motion_sensitivity >=4 && self.motion_sensitivity <= 7){
        return 1;
    }else
        return 2;
}
-(NSArray *)motion_sensitivityArray{
    return @[@"高",@"中",@"低"];
}
-(NSArray *)ioin_levelArray{
    return @[@"断开",@"闭合"];
}
-(NSArray *)alarmpresetsitArray{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i < 17; i++) {
        [array addObject:[NSString stringWithFormat:@"%i",i]];
    }
    [array insertObject:@"NO" atIndex:0];
    return array;
}
-(NSArray *)ioout_levelArray{
    return @[@"低电平",@"高电平"];
}
@end

@implementation MyECameraParam

-(id)init{
    if (self = [super init]) {
        self.resolution = 0;
        self.bright = 0;
        self.contrast = 0;
        self.hue = 0;
        self.saturation = 0;
        self.osdenable = 0;
        self.mode = 0;
        self.flip = 0;
        self.enc_framerate = 0;
        self.sub_enc_framerate = 0;
    }
    return self;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"resolution: %i  bright: %i  contrast: %i  mode: %i flip: %i",self.resolution,self.bright,self.contrast,self.mode,self.flip];
}
@end

@implementation MyECameraPTZ

-(id)init{
    if (self = [super init]) {
        self.led_mode = 0;
        self.center_onstart = 0;
        self.run_times = 0;
        self.patrol_rate = 0;
        self.patrol_up_rate = 0;
        self.patrol_down_rate = 1;
        self.patrol_left_rate = 1;
        self.patrol_right_rate = 1;
        self.disable_preset = 0;
        self.preset = 0;
    }
    return self;
}

//-(NSArray *)led_modeArray{
//    return @[@"关闭",@"打开"];
//}
//-(NSArray *)center_onstartArray{
//    return @[@"不居中",@"居中"];
//}
-(NSArray *)run_timesArray{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i < 11; i++) {
        [array addObject:[NSString stringWithFormat:@"%i",i]];
    }
    [array insertObject:@"无限制(一小时后自动停止)" atIndex:0];
    return array;
}
-(NSArray *)rateArray{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i < 11; i++) {
        [array addObject:[NSString stringWithFormat:@"%i",i]];
    }
    return array;
}
-(NSArray *)presetArray{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i < 17; i++) {
        [array addObject:[NSString stringWithFormat:@"预置位 %i",i]];
    }
    [array insertObject:@"不对准预置位" atIndex:0];
    return array;}
@end

@implementation MyECameraDate

-(id)init{
    if (self = [super init]) {
        self.now = 0;
        self.timeZone = 0;
        self.ntp_enable = 1;
        self.ntp_svr = @"";
        self.timeServerIndex = 0;
        self.timeZoneIndex = 0;
    }
    return self;
}

-(NSArray *)timeZoneArray{
    return @[@"(GMT -11:00) 中途岛, 萨摩亚群岛",
             @"(GMT -10:00) 夏威夷",
             @"(GMT -09:00) 阿拉斯加",
             @"(GMT -08:00) 太平洋时间(美国和加拿大)",
             @"(GMT -07:00) 山地时间(美国和加拿大)",
             @"(GMT -06:00) 中部时间(美国和加拿大), 墨西哥城",
             @"(GMT -05:00) 东部时间(美国和加拿大), 利马, 波哥大",
             @"(GMT -04:00) 大西洋时间(加拿大), 圣地亚哥, 拉巴斯",
             @"(GMT -03:30) 纽芬兰",
             @"(GMT -03:00) 巴西利亚, 布宜诺斯艾丽斯, 乔治敦",
             @"(GMT -02:00) 中大西洋",
             @"(GMT -01:00) 佛得角群岛",
             @"(GMT 0) 格林威治平时; 伦敦, 里斯本, 卡萨布兰卡",
             @"(GMT +01:00) 布鲁赛尔, 巴黎, 柏林, 罗马, 马德里, 斯多哥尔摩, 贝尔格莱德, 布拉格",
             @"(GMT +02:00) 雅典, 耶路撒冷, 开罗, 赫尔辛基",
             @"(GMT +03:00) 内罗毕, 利雅得, 莫斯科",
             @"(GMT +03:30) 德黑兰",
             @"(GMT +04:00) 巴库, 第比利斯, 阿布扎比, 马斯科特",
             @"(GMT +04:30) 科布尔",
             @"(GMT +05:00) 伊斯兰堡, 卡拉奇, 塔森干",
             @"(GMT +05:30) 加尔各答, 孟买, 马德拉斯, 新德里",
             @"(GMT +06:00) 阿拉木图, 新西伯利亚, 阿斯塔南, 达尔",
             @"(GMT +07:00) 曼谷, 河内, 雅加达",
             @"(GMT +08:00) 北京, 新加坡, 台北",
             @"(GMT +09:00) 首尔, 雅库茨克, 东京",
             @"(GMT +09:30) 达尔文",
             @"(GMT +10:00) 关岛, , 墨尔本, 悉尼, 莫尔兹比港, 符拉迪沃斯托克",
             @"(GMT +11:00) 马加丹, 所罗门群岛, 新喀里多尼亚",
             @"(GMT +12:00) 奥克兰, 惠灵顿, 斐济"];
}
-(NSArray *)timeZoneIdArray{
    return @[@(39600),@(36000),@(32400),@(28800),@(25200),@(21600),@(18000),@(14400),@(12600),@(10800),@(7200),@(3600),@(0),@(-3600),@(-7200),@(-10800),@(-12600),@(-14400),@(-16200),@(-18000),@(-19800),@(-21600),@(-25200),@(-28800),@(-32400),@(-34200),@(-36000),@(-39600),@(-43200)];
}
-(NSArray *)timeServerArray{
    return @[@"time.nist.gov",
             @"time.kriss.re.kr",
             @"time.windows.com",
             @"time.nuri.net"];
}
-(NSString *)description{
    return [NSString stringWithFormat:@"now: %i  timezone: %i  timeEnable: %@  timeserver: %@",self.now,self.timeZone,self.ntp_enable == 1?@"YES":@"NO",self.ntp_svr];
}
@end

@implementation MyECameraRecord

-(id)init{
    if (self = [super init]) {
        self.name = @"";
        self.fileSize = 0;
        self.bEnd = YES;
    }
    return self;
}
-(NSString *)getDate{
    return [NSString stringWithFormat:@"%@-%@-%@",[_name substringWithRange:NSMakeRange(0, 4)],[_name substringWithRange:NSMakeRange(4, 2)],[_name substringWithRange:NSMakeRange(6, 2)]];
}
-(NSString *)getTime{
    return [NSString stringWithFormat:@"%@:%@:%@",[_name substringWithRange:NSMakeRange(8, 2)],[_name substringWithRange:NSMakeRange(10, 2)],[_name substringWithRange:NSMakeRange(12, 2)]];
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@",_name];
}
@end

@implementation MyECameraSDSchedule

-(id)init{
    if (self = [super init]) {
        self.total = 0;
        self.remain = 0;
        self.status = 0;
        self.cover = 0;
        self.timeLength = 0;
        self.fixedTimeRecord = 0;
        self.recordSize = 0;
        self.sun_0 = self.sun_1 = self.sun_2 = 0;
        self.mon_0 = self.mon_1 = self.mon_2 = 0;
        self.tue_0 = self.tue_1 = self.tue_2 = 0;
        self.wed_0 = self.wed_1 = self.wed_2 = 0;
        self.thu_0 = self.thu_1 = self.thu_2 = 0;
        self.fri_0 = self.fri_1 = self.fri_2 = 0;
        self.sat_0 = self.sat_1 = self.sat_2 = 0;
    }
    return self;
}
-(NSArray *)weekArray{
    return @[@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
}
-(NSString *)stringFromInt:(NSInteger)value{
    NSMutableString *string = [NSMutableString string];
    NSInteger i,l;
    for ( i=31; i>=0; i--) {
        l = 0x80000000>>i;
        [string appendString:(l & value)?@"1":@"0"];
    }
    return string;
}
-(NSInteger)intFromString:(NSString *)string{
    NSInteger sum = 0,l;
    for (int i=0; i<32; i++) {
        if([string characterAtIndex:i] == '1'){
            l = 1<<i;
            sum += l;
        }
    }
    return sum;
}
@end