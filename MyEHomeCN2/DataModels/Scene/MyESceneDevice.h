//
//  MyESceneDevice.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-6.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyESceneDeviceInstruction.h"

@interface MyESceneDevice : NSObject <NSCopying>

@property(nonatomic) NSInteger deviceId;
@property(nonatomic,retain) NSMutableArray *instructions;

- (MyESceneDevice *)initWithDictionary:(NSDictionary *)dictionary;
- (MyESceneDevice *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
