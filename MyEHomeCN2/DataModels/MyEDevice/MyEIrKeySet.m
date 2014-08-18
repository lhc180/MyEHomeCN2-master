//
//  MyEIrKeySet.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/29/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEIrKeySet.h"
#import "MyEIrKey.h"
#import "SBJson.h"

@implementation MyEIrKeySet
@synthesize mainArray = _mainArray;
#pragma mark
#pragma mark JSON methods
- (MyEIrKeySet *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        
        NSArray *array = [dictionary objectForKey:@"InstructionSet"];
        NSMutableArray *keySet = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *instruction in array) {
                [keySet addObject:[[MyEIrKey alloc] initWithDictionary:instruction]];
            }
        }
        self.mainArray = keySet;
        return self;
    }
    return nil;
}

- (MyEIrKeySet *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEIrKeySet *instructionSet = [[MyEIrKeySet alloc] initWithDictionary:dict];
    return instructionSet;
}
- (NSDictionary *)JSONDictionary {
    NSMutableArray *keySet = [NSMutableArray array];
    for (MyEIrKey *key in self.mainArray)
        [keySet addObject:[key JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          keySet, @"InstructionSet",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEIrKeySet alloc] initWithDictionary:[self JSONDictionary]];
}

#pragma mark utilities methods
-(MyEIrKey *)getDefaultKeyByType:(NSInteger)type
{
    for (MyEIrKey *key in self.mainArray) {
        if(key.type == type)
            return key;
    }
    return Nil;
}
// 获取一个用户自学习的指令列表数组
-(NSArray *)userStudiedKeyList
{
    NSMutableArray *array = [NSMutableArray array];
    for (MyEIrKey *key in self.mainArray) {
        if(key.type < 100)//type 整数  1:开机、0：关机、2：其它指令， 用户自定义指令。200~300：电视类的模板定义的指令， 300~400：音响中的模板定义的指令
            [array addObject:key];
    }
    return array;
}

-(void)removeKeyById:(NSInteger)keyId{
    for (MyEIrKey *key in self.mainArray) {
        if (keyId == key.keyId) {
            [self.mainArray removeObject:key];
            return;
        }
    }
}
@end
