//
//  MyEProvinceAndCity.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-19.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyEProvinceAndCity.h"

@implementation MyEProvinceAndCity
-(id)init{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"province" ofType:@"txt"];
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    MyEProvinceAndCity *provinceAndCity = [[MyEProvinceAndCity alloc] initWithArray:array];
    return provinceAndCity;
}
- (MyEProvinceAndCity *)initWithFilePathString:(NSString *)pathString{
    NSString *contents = [NSString stringWithContentsOfFile:pathString encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    MyEProvinceAndCity *provinceAndCity = [[MyEProvinceAndCity alloc] initWithArray:array];
    return provinceAndCity;

}
- (MyEProvinceAndCity *)initWithArray:(NSArray *)array{
    if (self = [super init]) {
        NSMutableArray *mainArray = [NSMutableArray array];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *province in array) {
                [mainArray addObject:[[MyEProvince alloc]initWithDictionary:province]];
            }
        }
        self.provinceAndCity = mainArray;
        return self;
    }
    return nil;
}

@end

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


@implementation MyECity
- (MyECity *)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        self.cityId = [NSString stringWithFormat:@"%li",(long)[dictionary[@"value"] integerValue]];
        self.cityName = dictionary[@"label"];
        return self;
    }
    return nil;
}
@end

