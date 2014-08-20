//
//  MyETerminal.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/5/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyETerminal : NSObject  <NSCopying> 
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *tId;

@property (nonatomic) NSInteger irType;
@property (nonatomic) NSInteger roomId;
@property (nonatomic) NSInteger conSignal;
@property (nonatomic) NSInteger powerSaveMode;
@property (nonatomic) NSInteger enableDataCollect;


- (MyETerminal *)initWithDictionary:(NSDictionary *)dictionary;
- (MyETerminal *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
