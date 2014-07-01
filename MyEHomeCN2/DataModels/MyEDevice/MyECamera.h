//
//  MyECamera.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPPPChannelManagement.h"

@interface MyECamera : NSObject <NSCopying>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *UID;
@property (nonatomic) CPPPPChannelManagement *m_PPPPChannelMgt;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSData *imageData;
@property (nonatomic) BOOL isOnline;

- (MyECamera *)initWithDictionary:(NSDictionary *)dictionary;
- (MyECamera *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
@end

@interface MyEMainCamera : NSObject

@property (nonatomic, copy) NSMutableArray *cameras;

- (MyEMainCamera *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEMainCamera *)initWithJSONString:(NSString *)jsonString;
- (NSString *)JSONDictionary;

@end

@interface MyECameraWifi : NSObject
@property (nonatomic, strong) NSString *UID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger security;
@property (nonatomic, assign) NSInteger signal;
-(UIImage *)changeSignalToImage;
@end