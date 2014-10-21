//
//  MyEAcBrand.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcBrand.h"
#import "MyEAcModel.h"

@implementation MyEAcBrand

-(instancetype)init{
    if (self = [super init]) {
        self.brandId = 0;
        self.brandName = @"";
        self.models = [NSMutableArray array];
        return self;
    }
    return nil;
}

- (MyEAcBrand *)initWithDictionary:(NSDictionary *)dictionary{
    if (self =[super init]) {
        self.brandId = [dictionary[@"id"] intValue];
        self.brandName = dictionary[@"name"];
        self.models = [NSMutableArray array];
//        NSArray *array = dictionary[@"modules"];
//        NSMutableArray *models = [NSMutableArray array];
//        if ([array isKindOfClass:[array class]]) {
//            for (NSNumber *module in array) {
//                [models addObject:[module copy]];
//            }
//        }
//        self.models = models;
        
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

-(NSString *)description{
    return [NSString stringWithFormat:@"id: %i  name: %@  modules: %@",self.brandId,self.brandName,self.models];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.brandId = [aDecoder decodeIntegerForKey:@"brandId"];
        self.brandName = [aDecoder decodeObjectForKey:@"brandName"];
        self.models = [aDecoder decodeObjectForKey:@"models"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.brandName forKey:@"brandName"];
    [aCoder encodeObject:self.models forKey:@"models"];
    [aCoder encodeInteger:self.brandId forKey:@"brandId"];
}
-(BOOL)hasOneModelStudy{
    for (MyEAcModel *m in self.models) {
        if (m.study > 0) {
            return YES;
        }
    }
    return NO;
}
-(id)firstUsefulModel{
    for (MyEAcModel *m in self.models) {
        if (m.study > 0) {
            return m;
        }
    }
    return nil;
}
@end
