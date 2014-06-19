//
//  MyECity.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-19.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECity.h"

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
