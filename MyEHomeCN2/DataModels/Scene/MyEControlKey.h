//
//  MyEControlKey.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEControlKey : NSObject <NSCopying>

@property (nonatomic) NSInteger keyId;
@property (nonatomic) NSInteger powerSwitch;
@property (nonatomic) NSInteger runMode;
@property (nonatomic) NSInteger windLevel;
@property (nonatomic) NSInteger setpoint;
@property (nonatomic, strong) NSString *channel;

- (MyEControlKey *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEControlKey *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;
@end
