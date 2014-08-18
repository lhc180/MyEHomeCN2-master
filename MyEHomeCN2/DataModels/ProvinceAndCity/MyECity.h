//
//  MyECity.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-19.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyECity : NSObject

@property(nonatomic, strong) NSString *cityId;
@property(nonatomic, strong) NSString *cityName;

- (MyECity *)initWithDictionary:(NSDictionary *)dictionary;

@end
