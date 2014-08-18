//
//  MyEAcBrandsAndModules.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcBrandsAndModels.h"

@implementation MyEAcBrandsAndModels

- (MyEAcBrandsAndModels *)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        NSArray *array = dictionary[@"sysAcBrands"];
        NSMutableArray *brands = [NSMutableArray array];
        if ([array isKindOfClass:[array class]]) {
            for (NSDictionary *irList in array) {
                [brands addObject:[[MyEAcBrand alloc] initWithDictionary:irList]];
            }
        }
        self.sysAcBrands = brands;
        
        array = dictionary[@"userAcBrands"];
        NSMutableArray *userBrands = [NSMutableArray array];
        if ([array isKindOfClass:[array class]]) {
            for (NSDictionary *irList in array) {
                [userBrands addObject:[[MyEAcBrand alloc] initWithDictionary:irList]];
            }
        }
        self.userAcBrands = userBrands;
        
        array = dictionary[@"sysAcModules"];
        NSMutableArray *models = [NSMutableArray array];
        if ([array isKindOfClass:[array class]]) {
            for (NSDictionary *model in array) {
                [models addObject:[[MyEAcModel alloc] initWithDictionary:model]];
            }
        }
        self.sysAcModels = models;
        
        array = dictionary[@"userAcModules"];
        NSMutableArray *userModels = [NSMutableArray array];
        if ([array isKindOfClass:[array class]]) {
            for (NSDictionary *model in array) {
                [userModels addObject:[[MyEAcModel alloc] initWithDictionary:model]];
            }
        }
        self.userAcModels = userModels;
        
        return self;
        
    }
    return nil;
}
- (MyEAcBrandsAndModels *)initWithJSONString:(NSString *)jsonString{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:jsonString];
    MyEAcBrandsAndModels *ac = [[MyEAcBrandsAndModels alloc] initWithDictionary:dic];
    return ac;
}
- (NSDictionary *)JSONDictionary{
    NSDictionary *dic = [NSDictionary dictionary];
    return dic;
}

-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAcBrandsAndModels alloc] initWithDictionary:[self JSONDictionary]];
}


@end
