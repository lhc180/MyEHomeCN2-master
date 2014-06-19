//
//  MyEAcComfort.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAcComfort : NSObject <NSCopying>
@property (nonatomic) BOOL comfortFlag;
@property (nonatomic, strong) NSString *comfortRiseTime;
@property (nonatomic, strong) NSString *comfortSleepTime;
@property (nonatomic, strong) NSString *provinceId;
@property (nonatomic, strong) NSString *cityId;

// JSON 接口
- (MyEAcComfort *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcComfort *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;

@end
