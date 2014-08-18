//
//  MyEIrKey.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/29/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEIrKey : NSObject <NSCopying>
@property (nonatomic) NSInteger keyId;
@property (nonatomic, copy) NSString *keyName;
//type 整数  1:开机、0：关机、2：其它指令， 用户自定义指令。 200~300：电视类的模板定义的指令， 300~400：音响中的模板定义的指令
@property (nonatomic) NSInteger type;
//status 整数  status=1时，表明此指令已经学习，0-未学习。
@property (nonatomic) NSInteger status;

- (MyEIrKey *)initWithId:(NSInteger)keyId keyName:(NSString *)keyName type:(NSInteger)type status:(NSInteger)status;

- (MyEIrKey *)initWithDictionary:(NSDictionary *)dictionary;
- (MyEIrKey *)initWithJSONString:(NSString *)jsonString;
- (NSDictionary *)JSONDictionary;
-(id)copyWithZone:(NSZone *)zone;
@end
