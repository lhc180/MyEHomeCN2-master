//
//  MyESceneList.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyESceneList.h"
#import "SBJson.h"
#import "MyEScene.h"

@implementation MyESceneList
@synthesize mainArray = _mainArray;

#pragma mark
#pragma mark JSON methods
- (MyESceneList *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        
        NSArray *array = [dictionary objectForKey:@"scene"];
        NSMutableArray *mainArray = [NSMutableArray array];
        
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *scene in array) {
                [mainArray addObject:[[MyEScene alloc] initWithDictionary:scene]];
            }
        }
        self.mainArray = mainArray;
        return self;
    }
    return nil;
}

- (MyESceneList *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
//    NSLog(@"%@",dict);
    MyESceneList *scenes = [[MyESceneList alloc] initWithDictionary:dict];
    return scenes;
}
- (NSDictionary *)JSONDictionary {
    NSMutableArray *mainArray = [NSMutableArray array];
    for (MyEScene *scene in self.mainArray)
        [mainArray addObject:[scene JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          mainArray, @"sceneList",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyESceneList alloc] initWithDictionary:[self JSONDictionary]];
}

@end
