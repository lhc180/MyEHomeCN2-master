//
//  MyEProvince.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-19.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyECity.h"
@interface MyEProvince : NSObject
@property(nonatomic, strong) NSString *provinceId;
@property(nonatomic, strong) NSString *provinceName;
@property(nonatomic, strong) NSArray *cities;

- (MyEProvince *)initWithDictionary:(NSDictionary *)dictionary;
@end
