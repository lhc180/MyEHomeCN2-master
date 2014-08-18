//
//  MyESceneInstructionRecived.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-6.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyESceneInstructionRecived : NSObject<NSCopying>

@property(nonatomic,retain) NSMutableArray *allInstructions;

- (MyESceneInstructionRecived *)initWithDictionary:(NSDictionary *)dictionary;
- (MyESceneInstructionRecived *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
