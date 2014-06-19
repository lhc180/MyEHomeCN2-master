//
//  MyESettings.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-10-14.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"
#import "MyETerminal.h"

@interface MyESettings : NSObject <NSCopying>

@property(nonatomic, copy) NSString *mId;
@property(nonatomic, copy) NSString *provinceId;
@property(nonatomic, copy) NSString *cityId;

//基本的数据类型不可以加*（以下两个都是）
@property(nonatomic) NSInteger status;
@property(nonatomic) NSInteger enableNotification;

// 这里其实犯了一个错误，按照数据模型的功能，用于处理从服务器接收到的数据，那么这里应该声明一个可变数组的变量，不能声明MyETerminal的对象
//@property(nonatomic, retain) MyETerminal *terminals;
@property(nonatomic, retain) NSMutableArray *terminals;

// 终于知道错在哪儿了，方法一定要写在@end之前
- (MyESettings *)initWithDictionary:(NSDictionary *)dictionary;

- (MyESettings *)initWithJSONString:(NSString *)jsonString;

- (NSDictionary *)JSONDictionary;

@end



