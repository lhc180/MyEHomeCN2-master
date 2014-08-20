//
//  MyEAcModule.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAcModel : NSObject<NSCopying>

@property(nonatomic, assign) NSInteger modelId;
@property(nonatomic, copy) NSString *modelName;
@property(nonatomic, assign) NSInteger study;



- (MyEAcModel *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcModel *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
