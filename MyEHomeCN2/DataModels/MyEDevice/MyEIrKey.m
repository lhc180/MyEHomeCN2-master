//
//  MyEIrKey.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/29/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEIrKey.h"
#import "SBJson.h"

@implementation MyEIrKey
@synthesize type = _type,
keyName = _keyName,
status = _status,
keyId = _keyId;

- (MyEIrKey *)initWithId:(NSInteger)keyId keyName:(NSString *)keyName type:(NSInteger)type status:(NSInteger)status {
    if (self = [super init]) {
        _type = type;
        _keyName = [keyName copy];
        _status = status;
        _keyId = keyId;
        return self;
    }
    return nil;
}

#pragma mark
#pragma mark JSON methods
- (MyEIrKey *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.type = [[dictionary objectForKey:@"type"] intValue];
        self.status = [[dictionary objectForKey:@"status"] intValue];
        self.keyName = [dictionary objectForKey:@"keyName"];
        self.keyId = [[dictionary objectForKey:@"id"] intValue];
        
        return self;
    }
    return nil;
}

- (MyEIrKey *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyEIrKey *controlKey = [[MyEIrKey alloc] initWithDictionary:dict];
    return controlKey;
}
- (NSDictionary *)JSONDictionary {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.keyName, @"keyName",
                          [NSNumber numberWithInteger:self.type], @"type",
                          [NSNumber numberWithInteger:self.status], @"status",
                          [NSNumber numberWithInteger:self.keyId], @"id",
                          nil ];
    return dict;
}
-(id)copyWithZone:(NSZone *)zone {
    return [[MyEIrKey alloc] initWithDictionary:[self JSONDictionary]];
}

@end
