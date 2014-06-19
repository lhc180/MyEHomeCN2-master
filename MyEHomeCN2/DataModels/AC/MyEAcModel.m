//
//  MyEAcModule.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcModel.h"

@implementation MyEAcModel

- (MyEAcModel *)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        self.modelId = [dictionary[@"id"] intValue];
        self.modelName = dictionary[@"name"];
        if (dictionary[@"hasDefault2InstructionsStudied"]) {
            self.study = [dictionary[@"hasDefault2InstructionsStudied"] intValue];
        }
        return self;
    }
    return nil;
}
- (MyEAcModel *)initWithJSONString:(NSString *)jsonString{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dic = [parser objectWithString:jsonString];
    MyEAcModel *model = [[MyEAcModel alloc] initWithDictionary:dic];
    return model;
}
- (NSDictionary *)JSONDictionary{
    NSDictionary *dic = [NSDictionary dictionary];
    return dic;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEAcModel alloc] initWithDictionary:[self JSONDictionary]];
}

@end
