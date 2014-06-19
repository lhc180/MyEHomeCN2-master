//
//  MyESceneList.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyESceneList : NSObject  <NSCopying>

@property (nonatomic, retain) NSMutableArray *mainArray;

- (MyESceneList *)initWithDictionary:(NSDictionary *)dictionary;
- (MyESceneList *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
