//
//  MyEProvinceAndCity.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-19.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEProvince;
@class MyECity;

@interface MyEProvinceAndCity : NSObject

@property (copy, nonatomic) NSArray *provinceAndCity;

//- (MyEProvinceAndCity *)init;
- (MyEProvinceAndCity *)initWithFilePathString:(NSString *)pathString;
- (MyEProvinceAndCity *)initWithArray:(NSArray *)array;

@end


@interface MyEProvince : NSObject
@property(nonatomic, strong) NSString *provinceId;
@property(nonatomic, strong) NSString *provinceName;
@property(nonatomic, strong) NSArray *cities;

- (MyEProvince *)initWithDictionary:(NSDictionary *)dictionary;
@end


@interface MyECity : NSObject

@property(nonatomic, strong) NSString *cityId;
@property(nonatomic, strong) NSString *cityName;
- (MyECity *)initWithDictionary:(NSDictionary *)dictionary;
@end
