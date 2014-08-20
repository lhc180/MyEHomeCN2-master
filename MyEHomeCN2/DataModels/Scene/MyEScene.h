//
//  MyEScene.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEScene : NSObject  <NSCopying> 
@property (nonatomic, retain) NSMutableArray *deviceControls;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger sceneId;
@property (nonatomic) NSInteger byOrder;// 是否有序，0：否， 1:是

- (MyEScene *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEScene *)initWithJSONString:(NSString *)jsonString;

- (NSDictionary *)JSONDictionary;

- (NSString *)JSONStringWithDictionary:(MyEScene *)scene;
@end
