//
//  MyEAcBrandsAndModels.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyEAcBrand.h"
#import "MyEAcModel.h"
#import "SBJson.h"
@interface MyEAcBrandsAndModels : NSObject<NSCopying,NSCoding>

@property(nonatomic,strong) NSMutableArray *sysAcBrands;
@property(nonatomic,strong) NSMutableArray *userAcBrands;

@property(nonatomic,assign) NSInteger selectedIndex;  // 0:系统默认指令库  1: 自学习指令库

- (MyEAcBrandsAndModels *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcBrandsAndModels *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;

- (MyEAcBrand *)findBrandByBrandId:(NSInteger)brandId;
- (MyEAcModel *)findModelByModelId:(NSInteger)modelId inBrand:(MyEAcBrand *)brand;
- (NSArray *)usefullUserAcBrands;

@end
