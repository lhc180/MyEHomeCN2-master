//
//  MyEDataLoader.m
//  MyE
//
//  Created by Ye Yuan on 3/7/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEDataLoader.h"
#import <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>


@implementation MyEDataLoader
@synthesize delegate = _delegate;
@synthesize name = _name, userDataDictionary = _userDataDictionary;

// 1.判断是否联网：// 需要加入 frameworks:/System/Library/Frameworks/SystemConfiguration.framework
+ (BOOL) isConnectedToInternet {
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态 
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress)); 
    zeroAddress.sin_len = sizeof(zeroAddress); 
    zeroAddress.sin_family = AF_INET; 
    // Recover reachability flags 
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress); 
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志 
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags); 
    CFRelease(defaultRouteReachability);
    
    //如果不能获取连接标志，则不能连接网络，直接返回 
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
    
}

- (id)initLoadingWithURLString:(NSString *)urlString postData:(NSString *)postString delegate:(id <MyEDataLoaderDelegate>)delegate loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict;
{
    self = [super init];
    if(self)
    {
        _delegate = delegate;
        _name = name;
        
        //用户词典仅用于保存用户数据的，将来异步加载完成后，会把这个数据返回给用户，
        //用可以可以根据此数据里面的值知道此加载器进行了刚才是用来干什么的，从而可以进行下一步动作
        _userDataDictionary = dict;
        // 下面代码是用于进行异步HTTP URL请求的
        NSData *postData = nil;   
        NSString *postLength = nil;
        if (postString) {
            postData = [postString dataUsingEncoding:NSUTF8StringEncoding  allowLossyConversion:YES];   
            postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        }else {
            postData = nil;
            postLength = 0;
        }
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];   
        [request setURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:
                                              NSUTF8StringEncoding]]];
        NSLog(@"%@",[urlString stringByAddingPercentEscapesUsingEncoding:
                     NSUTF8StringEncoding]);
        [request setHTTPMethod:@"POST"];
        [request setTimeoutInterval: 30];//setting timeout
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];   
        [request setValue:@"application/x-www-form-urlencoded"  forHTTPHeaderField:@"Content-Type"];   
        [request setHTTPBody:postData];
        
        // create the connection with the request and start loading the data
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request  delegate:self];  
        
        
        
        
        if (theConnection) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            _receivedData = [NSMutableData data];
        } else {
            // Inform the user that the connection failed.
        }
        return  self;
    }
    return  nil;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse
                                                                     *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is an instance variable declared elsewhere.
    [_receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    if ([self.delegate respondsToSelector:@selector(connection:didFailWithError:loaderName:)]) {
        [self.delegate connection:connection didFailWithError:error loaderName:self.name];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[_receivedData length]);
    if ([_receivedData length] == 0) {
        NSLog(@"数据请求为0");
        return;
    }
    NSString *responseStringJSONPart = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    // trim first and last extra string imported by JSONP interface
    // https://stackoverflow.com/questions/17129476/how-do-i-remove-callback-parameters-from-jsonp-in-objective-c-to-make-it-usable
    // Decode the web response data into a string, then:
    NSRange begin = [responseStringJSONPart rangeOfString:@"(" options:NSLiteralSearch];
    NSRange end = [responseStringJSONPart rangeOfString:@")" options:NSBackwardsSearch|NSLiteralSearch];
    BOOL parseFail = (begin.location == NSNotFound || end.location == NSNotFound || end.location - begin.location < 2);
    if (!parseFail)
    {
        responseStringJSONPart = [responseStringJSONPart substringWithRange:NSMakeRange(begin.location + 1, (end.location - begin.location) - 1)];
    }
    
    // 如果uploader里面带了用户数据，就调用下面函数把用户数据词典传回去
    if ([self.delegate respondsToSelector:@selector(didReceiveString:loaderName:userDataDictionary:)]) {
        [self.delegate didReceiveString:responseStringJSONPart loaderName:self.name userDataDictionary:self.userDataDictionary];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
}
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential = [NSURLCredential credentialWithUser:@"myenergydomain"
                                                   password:@"MyE090401"
                                                persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential
               forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        // inform the user that the user name and password
        // in the preferences are incorrect
        NSLog(@"user name and password is not correct to pass the authentification on www.myenergydomain.com.cn");
    }
}

@end

