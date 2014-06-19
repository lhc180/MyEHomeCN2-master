//
//  MyEAcStudyInstructionList.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-23.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAcStudyInstructionList : NSObject<NSCopying>

@property (strong, nonatomic) NSMutableArray *instructionList;

- (MyEAcStudyInstructionList *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEAcStudyInstructionList *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end
