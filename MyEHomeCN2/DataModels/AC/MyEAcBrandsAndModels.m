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
        
        NSMutableArray *sysModels = [NSMutableArray array];
        for (NSDictionary *model in dictionary[@"sysAcModules"]) {
            [sysModels addObject:[[MyEAcModel alloc] initWithDictionary:model]];
        }
        
        NSMutableArray *userModels = [NSMutableArray array];
        for (NSDictionary *model in dictionary[@"userAcModules"]) {
            [userModels addObject:[[MyEAcModel alloc] initWithDictionary:model]];
        }
        
        self.sysAcBrands = [NSMutableArray array];
        for (NSDictionary *d in dictionary[@"sysAcBrands"]) {
            MyEAcBrand *brand = [[MyEAcBrand alloc] initWithDictionary:d];
            for (NSNumber *i in d[@"modules"]) {
                for (MyEAcModel *m in sysModels) {
                    if (m.modelId == i.intValue) {
                        [brand.models addObject:m];
                        break;
                    }
                }
            }
            [self.sysAcBrands addObject:brand];
        }

        self.userAcBrands = [NSMutableArray array];
        for (NSDictionary *d in dictionary[@"userAcBrands"]) {
            MyEAcBrand *brand = [[MyEAcBrand alloc] initWithDictionary:d];
            for (NSNumber *i in d[@"modules"]) {
                for (MyEAcModel *m in userModels) {
                    if (m.modelId == i.intValue) {
                        [brand.models addObject:m];
                        break;
                    }
                }
            }
            [self.userAcBrands addObject:brand];
        }

        self.selectedIndex = 0;  //这里对该值进行初始化，表示默认选中的是［系统库］
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


- (MyEAcBrand *)findBrandByBrandId:(NSInteger)brandId{
    NSMutableArray *array = self.selectedIndex == 0?self.sysAcBrands:self.userAcBrands;
    for (MyEAcBrand *b in array) {
        if (b.brandId == brandId) {
            return b;
        }
    }
    return array[0];
}
- (MyEAcModel *)findModelByModelId:(NSInteger)modelId  inBrand:(MyEAcBrand *)brand{
    for (MyEAcModel *m in brand.models) {
        if (m.modelId == modelId) {
            return m;
        }
    }
    return brand.models[0];
}

// 当将一个自定义对象保存到文件的时候就会调用该方法
// 在该方法中说明如何存储自定义对象的属性
// 也就说在该方法中说清楚存储自定义对象的哪些属性
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.sysAcBrands forKey:@"sysAcBrands"];
    [aCoder encodeObject:self.userAcBrands forKey:@"userAcBrands"];
}
// 当从文件中读取一个对象的时候就会调用该方法
// 在该方法中说明如何读取保存在文件中的对象
// 也就是说在该方法中说清楚怎么读取文件中的对象
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.sysAcBrands = [aDecoder decodeObjectForKey:@"sysAcBrands"];
        self.userAcBrands = [aDecoder decodeObjectForKey:@"userAcBrands"];
    }
    return self;
}
@end
