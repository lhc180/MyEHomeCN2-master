//
//  MyEDeviceType.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/1/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{DT_AC=1, DT_TV, DT_CURTAIN, DT_AUDIO, DT_OTHER, DT_SOCKET} DEVICE_TYPE;


@interface MyEDeviceType : NSObject <NSCopying>
@property (nonatomic, retain) NSMutableArray *devices;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger dtId;


- (MyEDeviceType *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEDeviceType *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;

@end
