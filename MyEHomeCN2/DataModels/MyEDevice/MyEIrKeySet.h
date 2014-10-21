//
//  MyEIrKeySet.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/29/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyEIrKey.h"

@interface MyEIrKeySet : NSObject <NSCopying>
@property (nonatomic, retain) NSMutableArray *mainArray;

// JSON 接口
- (MyEIrKeySet *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEIrKeySet *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;

// utilities methods
-(MyEIrKey *)getDefaultKeyByType:(NSInteger)type;
// 获取一个用户自学习的指令列表数组
-(NSArray *)userStudiedKeyList;
-(void)removeKeyById:(NSInteger)keyId;
@end
