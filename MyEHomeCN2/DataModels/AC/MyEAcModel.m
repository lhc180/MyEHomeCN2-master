//
//  MyEAcModule.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-20.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcModel.h"

@implementation MyEAcModel

-(instancetype)init{
    if (self = [super init]) {
        self.modelId = 0;
        self.modelName = @"";
        self.study = 0;
        return self;
    }
    return nil;
}
- (MyEAcModel *)initWithDictionary:(NSDictionary *)dictionary{
    if (self = [super init]) {
        self.modelId = [dictionary[@"id"] intValue];
        self.modelName = dictionary[@"name"];
        self.study = 1;
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
-(NSString *)description{
    return [NSString stringWithFormat:@"id: %i  name :%@  study:%i",self.modelId,self.modelName,self.study];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.modelId = [aDecoder decodeIntegerForKey:@"modelId"];
        self.modelName = [aDecoder decodeObjectForKey:@"modelName"];
        self.study = [aDecoder decodeIntegerForKey:@"study"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:self.modelId forKey:@"modelId"];
    [aCoder encodeInteger:self.study forKey:@"study"];
    [aCoder encodeObject:self.modelName forKey:@"modelName"];
}
@end
