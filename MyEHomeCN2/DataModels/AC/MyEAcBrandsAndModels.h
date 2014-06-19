//
//  MyEAcBrandsAndModels.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAcBrandsAndModels : NSObject<NSCopying>

@property(nonatomic,copy) NSArray *irList;
@property(nonatomic,copy) NSArray *sysAcBrands;
@property(nonatomic,copy) NSArray *sysAcModels;
@property(nonatomic,copy) NSArray *userAcBrands;
@property(nonatomic,copy) NSArray *userAcModels;


- (MyEAcBrandsAndModels *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcBrandsAndModels *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;

@end
