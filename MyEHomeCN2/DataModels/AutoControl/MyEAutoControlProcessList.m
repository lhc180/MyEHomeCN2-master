//
//  MyEAcAutoControlProcessList.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/19/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAutoControlProcessList.h"
#import "SBJson.h"
#import "MyEAutoControlProcess.h"

@implementation MyEAutoControlProcessList
@synthesize mainArray = _mainArray, enable = _enable;

#pragma mark
#pragma mark JSON methods
- (MyEAutoControlProcessList *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        
        NSArray *array = [dictionary objectForKey:@"processList"];
        NSMutableArray *mainArray = [NSMutableArray array];
        
        NSInteger count = 1;
        if ([array isKindOfClass:[NSArray class]]){
            for (NSDictionary *processDict in array) {

                MyEAutoControlProcess *process = [[MyEAutoControlProcess alloc] initWithDictionary:processDict];
                process.name = [NSString stringWithFormat:@"进程 %ld", (long)count] ;
                [mainArray addObject:process];
                count ++;
            }
        }
        self.mainArray = mainArray;
        self.enable = [[dictionary objectForKey:@"enable"] boolValue];
        return self;
    }
    return nil;
}

- (MyEAutoControlProcessList *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEAutoControlProcessList *processes = [[MyEAutoControlProcessList alloc] initWithDictionary:dict];
    return processes;
}
- (NSDictionary *)JSONDictionary {
    NSMutableArray *mainArray = [NSMutableArray array];
    for (MyEAutoControlProcess *process in self.mainArray)
        [mainArray addObject:[process JSONDictionary]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          mainArray, @"processList",
                          [NSNumber numberWithBool:self.enable], @"enable",
                          nil ];
    
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAutoControlProcessList alloc] initWithDictionary:[self JSONDictionary]];
}


#pragma mark utilities
- (NSArray *)getUnavailableDaysForProcessWithId:(NSInteger)pId{
    NSMutableArray *array = [NSMutableArray array];
    for (MyEAutoControlProcess *process in self.mainArray) {
        if (process.pId == pId) {
            continue;
        }
        for (NSNumber *day in process.days) {
            [array addObject:[day copy]];
        }
    }
    return array;
}
- (NSInteger)getFirstAvailableDay// 获取第一个可以用的(还没被占用的)天编号, // 1-Mon, 2-Tue, ..., 7-Sun
{
    NSInteger day = 0;
    NSMutableArray *array = [NSMutableArray array];
    for (MyEAutoControlProcess *process in self.mainArray) {
        for (NSNumber *day in process.days) {
            [array addObject:[day copy]];
        }
    }
    for (NSInteger i=1; i <= 7; i++) {
        if([array indexOfObject:[NSNumber numberWithInteger:i]] == NSNotFound) {
            day = i;
            break;
        }
    }
    return day;
}
// 对进程列表的每个列表重新排序并根据行号进行命名
- (void)renameProcessInList{
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"pId"
                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[self.mainArray sortedArrayUsingDescriptors:sortDescriptors]];
    self.mainArray = sortedArray;
//    NSArray *sortedArray;
//    sortedArray = [self.mainArray  sortedArrayUsingComparator:^(NSDictionary *first, NSDictionary *second) {
//        
//        return [firstDistance compare:secondDistance];
//    }];
    
    for (int i = 0; i < [self.mainArray count]; i++) {
        MyEAutoControlProcess *process = [self.mainArray objectAtIndex:i];
        process.name = [NSString stringWithFormat:@"进程 %d", i+1];
    }
}
#pragma mark Utilities methods
- (void)updateProcessWith:(MyEAutoControlProcess *)process
{
    for (int i = 0; i < [self.mainArray count]; i++) {
        MyEAutoControlProcess *p = [self.mainArray objectAtIndex:i];
        if(process.pId == p.pId){
            [self.mainArray replaceObjectAtIndex:i withObject:process];
            return;
        }
    }
}
@end
