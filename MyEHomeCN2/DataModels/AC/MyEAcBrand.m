//
//  MyEAcBrand.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcBrand.h"

@implementation MyEAcBrand


- (MyEAcBrand *)initWithDictionary:(NSDictionary *)dictionary{
    if (self =[super init]) {
        self.brandId = [dictionary[@"id"] intValue];
        self.brandName = dictionary[@"name"];
        
        NSArray *array = dictionary[@"modules"];
        NSMutableArray *models = [NSMutableArray array];
        if ([array isKindOfClass:[array class]]) {
            for (NSNumber *module in array) {
                [models addObject:[module copy]];
            }
        }
        self.models = models;
        
        return  self;
    }
    return nil;

}
- (MyEAcBrand *)initWithJSONString:(NSString *)jsonString{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:jsonString];
    MyEAcBrand *brand = [[MyEAcBrand alloc] initWithDictionary:dic];
    return brand;
}
- (NSDictionary *)JSONDictionary{
    NSMutableArray *models = [NSMutableArray array];
    for (MyEAcBrand *brand in self.models)
        [models addObject:[brand JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:self.brandId], @"id",
                          self.brandName, @"name",
                          models, @"modules",
                          nil ];
    
    return dict;

}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAcBrand alloc] initWithDictionary:[self JSONDictionary]];
}
@end
