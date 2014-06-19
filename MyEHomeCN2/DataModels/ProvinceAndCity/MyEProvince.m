//
//  MyEProvince.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-19.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEProvince.h"

@implementation MyEProvince
- (MyEProvince *)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        self.provinceId = [NSString stringWithFormat:@"%li",(long)[dictionary[@"id"] integerValue]];
        self.provinceName = dictionary[@"name"];
        NSArray *array = dictionary[@"city"];
        NSMutableArray *cityArray = [NSMutableArray array];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *city in array) {
                [cityArray addObject:[[MyECity alloc] initWithDictionary:city]];
            }
        }
        self.cities = cityArray;
        return self;
    }
    return nil;
}

@end
