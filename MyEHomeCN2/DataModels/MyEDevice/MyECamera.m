//
//  MyECamera.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import "MyECamera.h"

@implementation MyECamera
#pragma mark
#pragma mark JSON methods
- (id)init {
    if (self = [super init]) {
        _UID = @"";
        _name = @"";
        _username = @"";
        _password = @"";
        _imageData = [@"" dataUsingEncoding:NSASCIIStringEncoding];
        _isOnline = NO;
        _status = @"";
        return self;
    }
    return nil;
}

- (MyECamera *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [self init]) {
        self.UID = [dictionary objectForKey:@"UID"];
        self.name = [dictionary objectForKey:@"name"];
        self.username = [dictionary objectForKey:@"username"];
        self.password = [dictionary objectForKey:@"password"];
        self.imageData = [dictionary[@"image"] dataUsingEncoding:NSASCIIStringEncoding];
        self.isOnline = dictionary[@"isOnline"]?[dictionary[@"isOnline"] boolValue]:NO;
        self.status = dictionary[@"status"]?dictionary[@"status"]:@"";
        return self;
    }
    return nil;
}

- (MyECamera *)initWithJSONString:(NSString *)jsonString {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    // 把JSON转为字典
    NSDictionary *dict = [parser objectWithString:jsonString];
    
    MyECamera *camera = [[MyECamera alloc] initWithDictionary:dict];
    return camera;
}
- (NSDictionary *)JSONDictionary {
//    NSLog(@"%@%@%@%@",self.UID,self.name,self.password,self.username);
//    NSLog(@"%@",self.imageData);
    NSString *string = [[NSString alloc] initWithData:self.imageData encoding:NSASCIIStringEncoding];
//    NSLog(@"%@",string);
    return @{@"UID": self.UID,
             @"name": self.name,
             @"username": self.username,
             @"password": self.password,
             @"image":string?string:@""};
}
#pragma mark - NSCopying delegate methods
-(id)copyWithZone:(NSZone *)zone {
    return [[MyECamera alloc] initWithDictionary:[self JSONDictionary]];
}
#pragma mark - NSLog methods
-(NSString *)description{
    return [NSString stringWithFormat:@"%@  %@  %@  %@",self.name,self.UID,self.username,self.password];
}
//#pragma mark - NSCoding delegate methods
//-(id)initWithCoder:(NSCoder *)aDecoder{
//    if (self = [super init]) {
//        self.UID = [aDecoder decodeObjectForKey:@"UID"];
//        self.name = [aDecoder decodeObjectForKey:@"name"];
//        self.username = [aDecoder decodeObjectForKey:@"username"];
//        self.password = [aDecoder decodeObjectForKey:@"password"];
//        self.image = [aDecoder decodeObjectForKey:@"image"];
//        self.isOnline = [aDecoder decodeBoolForKey:@"isOnline"];
//        self.status = [aDecoder decodeObjectForKey:@"status"];
//        return self;
//    }
//    return nil;
//}
//-(void)encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeObject:self.UID forKey:@"UID"];
//    [aCoder encodeObject:self.name forKey:@"name"];
//    [aCoder encodeObject:self.username forKey:@"username"];
//    [aCoder encodeObject:self.password forKey:@"password"];
//    [aCoder encodeObject:self.image forKey:@"image"];
//    [aCoder encodeObject:self.status forKey:@"status"];
//    [aCoder encodeBool:self.isOnline forKey:@"isOnline"];
//}
@end


@implementation MyEMainCamera

- (MyEMainCamera *)initWithDictionary:(NSDictionary *)dic{
    if (self = [super init]) {
        self.cameras = [NSMutableArray array];
        for (NSDictionary *d in dic[@"cameras"]) {
            [self.cameras addObject:[[MyECamera alloc] initWithDictionary:d]];
        }
        return self;
    }
    return nil;
}
-(MyEMainCamera *)initWithArray:(NSArray *)array{
    if (self = [super init]) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *d in array) {
            [array addObject:[[MyECamera alloc] initWithDictionary:d]];
        }
        self.cameras = array;
        return self;
    }
    return nil;
}
- (MyEMainCamera *)initWithJSONString:(NSString *)jsonString{
    NSArray *array = [jsonString JSONValue];
    MyEMainCamera *main = [[MyEMainCamera alloc] initWithArray:array];
    return main;
}
- (NSString *)JSONDictionary{
    NSMutableArray *cameras = [NSMutableArray array];
    for (MyECamera *c in self.cameras) {
        [cameras addObject:[c JSONDictionary]];
    }
    SBJsonWriter *write = [[SBJsonWriter alloc] init];
    NSString *string = [write stringWithObject:cameras];
    return string;
}

@end