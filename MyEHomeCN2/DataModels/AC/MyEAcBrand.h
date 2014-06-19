//
//  MyEAcBrand.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAcBrand : NSObject<NSCopying>

@property (nonatomic,assign) NSInteger brandId;
@property (nonatomic,copy) NSString *brandName;
@property (nonatomic,copy) NSArray *models;


- (MyEAcBrand *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcBrand *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;


@end
