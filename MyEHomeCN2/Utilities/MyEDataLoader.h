//
//  MyEDataLoader.h
//  MyE
//
//  Created by Ye Yuan on 3/7/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyEDataLoaderDelegate;

@interface MyEDataLoader : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>
{
    id <MyEDataLoaderDelegate> _delegate;
    NSString *_name;
    NSDictionary *_userDataDictionary;//用于保存用户数据，因为有时候用户上传信息后，根据异步返回的结果进行下一步动作，这些动作需要用的参数，就构成词典放在这个变量里
    NSMutableData *_receivedData;
}
@property (nonatomic, retain) id <MyEDataLoaderDelegate> delegate;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSDictionary *userDataDictionary;

// 1.判断是否联网：// 需要加入 frameworks:/System/Library/Frameworks/SystemConfiguration.framework
+ (BOOL) isConnectedToInternet;

- (id)initLoadingWithURLString:(NSString *)urlString postData:(NSString *)postString delegate:(id <MyEDataLoaderDelegate>)delegate loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict;
+ (void)startLoadingWithURLString:(NSString *)urlString postData:(NSString *)postString delegate:(id <MyEDataLoaderDelegate>)delegate loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict;
@end

@protocol MyEDataLoaderDelegate <NSObject>
@optional
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name;
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict;
@end