//
//  MyEDeviceControl.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyEControlKey.h"

@interface MyEDeviceControl : NSObject <NSCopying>

@property (nonatomic, copy) MyEControlKey *controlKey;
@property (nonatomic) NSInteger isAc;  //0:非空调非开关    1:空调    2:开关
@property (nonatomic) NSInteger deviceId;// 设备id
@property (nonatomic) NSInteger dcId;// 惟一标识此Device Control的一个id，因为原来我们的场景一个设备只能出现一次，当时就可以用设备的id获取此为惟一的Device Control，现在有我们允许一个设备出现多次，所以我们必须添加这个dcid，以便从场景里面获取惟一的某个controlKey。我们可以用此Device Control在此场景中的序号做此惟一标识。

- (MyEDeviceControl *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEDeviceControl *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
- (NSString *)JSONStringWithDictionary:(MyEDeviceControl *)deviceControl;
@end
