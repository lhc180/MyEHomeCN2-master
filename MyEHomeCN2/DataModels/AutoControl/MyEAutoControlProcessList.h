//
//  MyEAcAutoControlProcessList.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyEAutoControlProcess;

@interface MyEAutoControlProcessList : NSObject  <NSCopying>
@property (nonatomic, retain) NSMutableArray *mainArray;
@property (nonatomic) BOOL enable;

- (MyEAutoControlProcessList *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAutoControlProcessList *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;

// Utilities
- (NSArray *)getUnavailableDaysForProcessWithId:(NSInteger)pId;
- (NSInteger)getFirstAvailableDay;// 获取第一个可以用的(还没被占用的)天编号, // 1-Mon, 2-Tue, ..., 7-Sun
// 对进程列表的每个列表重新排序并根据行号进行命名
- (void)renameProcessInList;
- (void)updateProcessWith:(MyEAutoControlProcess *)process;

@end
