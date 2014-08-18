//
//  MyEAcTempMontor.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/24/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAcTempMonitor : NSObject<NSCopying>
@property (nonatomic) BOOL monitorFlag;
@property (nonatomic) BOOL autoRunFlag;
@property (nonatomic) NSInteger minTemp;
@property (nonatomic) NSInteger maxTemp;

// JSON 接口
- (MyEAcTempMonitor *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcTempMonitor *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;
@end
