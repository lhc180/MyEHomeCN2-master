//
//  MyERoom.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/2/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyERoom : NSObject  <NSCopying> 
@property (nonatomic, retain) NSMutableArray *devices;
@property (nonatomic) NSInteger roomId;
@property (nonatomic, copy) NSString *name;

- (MyERoom *)initWithDictionary:(NSDictionary *)dictionary;
- (MyERoom *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
