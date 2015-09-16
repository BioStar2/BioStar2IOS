
/*
 * Copyright 2015 Suprema(biostar2@suprema.co.kr)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "BSNetwork.h"
#import "ErrorMessageCodeTable.h"

BOOL isForRelogin = NO;
NSString *requestURL = nil;
NSString *requestParam = nil;
Method requestMethod = UNDEFINED;
NSString *loginRequestURL = nil;
NSString *loginRequestParam = nil;
Method loginRequestMethod = UNDEFINED;

#define TIMEOUT_INTERVAL 60

@implementation BSNetwork

@synthesize delegate;


- (id)init
{
    if (self = [super init])
    {
        isForRelogin = NO;
    }
    
    return self;
}

- (void)setBSNetworkDelegate:(id)_delegate
{
    self.delegate = _delegate;
}

- (void)setServerURL:(NSString*)url
{
    [NetworkController sharedInstance].serverURL = url;
}


/**
 *  API 호출
 *
 *  @param URL    URL address
 *  @param param  모델객체의 json String
 *  @param isPost Post 와 get 구분
 */

- (void)requestURL:(NSString*)URL withParam:(NSString*)param method:(Method)method
{
    
    switch (method)
    {
        case GET:
        case PHOTO_GET:
            requestURL = URL;
            requestParam = param;
            requestMethod = method;
            [self requestGetMethod:URL withParam:param method:method];
            break;
            
        case LOGIN_POST:
            loginRequestURL = URL;
            loginRequestParam = param;
            loginRequestMethod = method;
            [self requestLogin:URL withParam:param method:method];
            break;
            
        case POST:
            requestURL = URL;
            requestParam = param;
            requestMethod = method;
            [self requestPostMethod:URL withParam:param method:method];
            break;
            
        case PUT:
            requestURL = URL;
            requestParam = param;
            requestMethod = method;
            [self requestPutMethod:URL withParam:param method:method];
            break;
            
        case DELETE:
            requestURL = URL;
            requestParam = param;
            requestMethod = method;
            [self requestDeleteMethod:URL withParam:param method:method];
            break;
        default:
            break;
    }
}

- (void)requestLogin:(NSString*)URL withParam:(NSString*)param method:(Method)method
{
    @autoreleasepool
    {
        NSURL *url = [NSURL URLWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
        [mutableRequest setTimeoutInterval:TIMEOUT_INTERVAL];
        [mutableRequest setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [mutableRequest setHTTPMethod:@"POST"];
        
        NSString *isoCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        [mutableRequest setValue:isoCode forHTTPHeaderField:@"Content-Language"];
       
        NSData *bodyData = [[NetworkController sharedInstance] convertToNSDate:param];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
        
        [mutableRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [mutableRequest setHTTPBody:bodyData];
        
        
        loginTask = [NetworkControllerInstance.URLsession dataTaskWithRequest:mutableRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] getCookiesForTask:loginTask completionHandler:^(NSArray *cookies) {
                
                NSString *serverDomain = [[NSUserDefaults standardUserDefaults] objectForKey:@"ServerAddress"];
                if ([serverDomain rangeOfString:@"https://"].location != NSNotFound)
                {
                    serverDomain = [serverDomain substringFromIndex:8];
                }
                else if([serverDomain rangeOfString:@"http://"].location != NSNotFound)
                {
                    serverDomain = [serverDomain substringFromIndex:7];
                }
                
                // 쿠키 저장하기
                //[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:[NSURL URLWithString:@"api.biostar2.com"]];
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:[NSURL URLWithString:serverDomain]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self parsePostRequestResult:data response:response error:error];
            }];
            
            
            
        }];
        [loginTask resume];
        
    }
}

- (void)requestGetMethod:(NSString*)URL withParam:(NSString*)param method:(Method)method
{
    @autoreleasepool
    {
        NSURL *url = [NSURL URLWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
        [mutableRequest setTimeoutInterval:TIMEOUT_INTERVAL];
        [mutableRequest setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
        [mutableRequest setValue:@"ISO-639" forHTTPHeaderField:@"Content-Language"];
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [mutableRequest setHTTPMethod:@"GET"];
        
        NSString *isoCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        [mutableRequest setValue:isoCode forHTTPHeaderField:@"Content-Language"];
        
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:
                                  [cookieJar cookies]];
        [mutableRequest setAllHTTPHeaderFields:headers];
        
        NSURLSessionDataTask* task = [NetworkControllerInstance.URLsession dataTaskWithRequest:mutableRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if (method == PHOTO_GET)
            {
                [self parsePhotoRequestResult:data response:response error:error];
            }
            else
            {
                [self parseRequestResult:data response:response error:error];
            }
            
        }];
        
        [task resume];
        
        
        
    }
}

- (void)requestPostMethod:(NSString*)URL withParam:(NSString*)param method:(Method)method
{
    @autoreleasepool
    {
        NSData *bodyData = [[NetworkController sharedInstance] convertToNSDate:param];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
        
        NSURL *url = [NSURL URLWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
        [mutableRequest setTimeoutInterval:TIMEOUT_INTERVAL];
        [mutableRequest setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [mutableRequest setHTTPMethod:@"POST"];
        
        NSString *isoCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        [mutableRequest setValue:isoCode forHTTPHeaderField:@"Content-Language"];
        if (bodyData.length > 0)
        {
            [mutableRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [mutableRequest setHTTPBody:bodyData];
        }
        
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:
                                  [cookieJar cookies]];
        [mutableRequest setAllHTTPHeaderFields:headers];
        
        NSURLSessionDataTask* task = [NetworkControllerInstance.URLsession dataTaskWithRequest:mutableRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            [self parsePostRequestResult:data response:response error:error];
            
        }];
        [task resume];
        
        
    }
}

- (void)requestDeleteMethod:(NSString*)URL withParam:(NSString*)param method:(Method)method
{
    @autoreleasepool
    {
        NSData *bodyData = [[NetworkController sharedInstance] convertToNSDate:param];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
    
        
        NSURL *url = [NSURL URLWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
        [mutableRequest setTimeoutInterval:TIMEOUT_INTERVAL];
        [mutableRequest setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [mutableRequest setHTTPMethod:@"DELETE"];
        
        NSString *isoCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        [mutableRequest setValue:isoCode forHTTPHeaderField:@"Content-Language"];
        
        [mutableRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [mutableRequest setHTTPBody:bodyData];
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:
                                  [cookieJar cookies]];
        [mutableRequest setAllHTTPHeaderFields:headers];
        
        NSURLSessionDataTask* task = [NetworkControllerInstance.URLsession dataTaskWithRequest:mutableRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            
            [self parseRequestResult:data response:response error:error];
            
        }];
        
        [task resume];
        
        
    }
}

- (void)requestPutMethod:(NSString*)URL withParam:(NSString*)param method:(Method)method
{
    @autoreleasepool
    {
        NSData *bodyData = [[NetworkController sharedInstance] convertToNSDate:param];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
        
        NSURL *url = [NSURL URLWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
        [mutableRequest setTimeoutInterval:TIMEOUT_INTERVAL];
        [mutableRequest setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
        [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [mutableRequest setHTTPMethod:@"PUT"];
        
        NSString *isoCode = [[NSLocale preferredLanguages] objectAtIndex:0];
        [mutableRequest setValue:isoCode forHTTPHeaderField:@"Content-Language"];
        
        [mutableRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [mutableRequest setHTTPBody:bodyData];
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:
                                  [cookieJar cookies]];
        [mutableRequest setAllHTTPHeaderFields:headers];
        
        NSURLSessionDataTask* task = [NetworkControllerInstance.URLsession dataTaskWithRequest:mutableRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            [self parseRequestResult:data response:response error:error];
            
        }];
        [task resume];
        
        
    }
}


- (void)parsePostRequestResult:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger responseCode = httpResponse.statusCode;
    NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *decData = [[NetworkController sharedInstance] convertToNSDate:responseStr];
    
    NSMutableDictionary *dic;
    if (nil == decData || decData.length == 0)
    {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        [tempDic setObject:NSLocalizedString(@"error_network2", nil) forKey:@"message"];
        
        [self.delegate didFailRequest:tempDic];
        return;
    }
    else
    {
        dic = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:decData options:NSJSONReadingAllowFragments error:nil]];
    }
    
    if (200 <= responseCode && responseCode <= 299)
    {
        if (isForRelogin)
        {
            isForRelogin = NO;
            [self requestURL:requestURL withParam:requestParam method:requestMethod];
            return;
        }
        [self.delegate didFinishRequest:dic];
    }
    else
    {
        if (responseCode != 401)
        {
            if (nil == [dic objectForKey:@"message"] || [[dic objectForKey:@"message"] isEqualToString:@""])
            {
                [dic setObject:NSLocalizedString(@"error_network2", nil) forKey:@"message"];
            }
        }
        
        [dic setObject:[NSNumber numberWithInteger:responseCode] forKey:@"responseCode"];
        [self.delegate didFailRequest:dic];
    }
    
}

- (void)parsePhotoRequestResult:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger responseCode = httpResponse.statusCode;
    NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (200 <= responseCode && responseCode <= 299)
    {
        [self.delegate didFinishPhotoRequest:responseStr fromURL:[response URL].absoluteString];
    }
}

- (void)parseRequestResult:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger responseCode = httpResponse.statusCode;
    NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *decData = [[NetworkController sharedInstance] convertToNSDate:responseStr];
    NSMutableDictionary *dic;
    if (nil == decData || decData.length == 0)
    {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        [tempDic setObject:NSLocalizedString(@"error_network2", nil) forKey:@"message"];
        
        [self.delegate didFailRequest:tempDic];
        return;
    }
    else
    {
        dic = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
    }
    
    
    if (200 <= responseCode && responseCode <= 299)
    {
        [self.delegate didFinishRequest:dic];
    }
    else
    {
        if (responseCode != 401)
        {
            if (nil == [dic objectForKey:@"message"] || [[dic objectForKey:@"message"] isEqualToString:@""])
            {
                [dic setObject:NSLocalizedString(@"error_network2", nil) forKey:@"message"];
            }
        }
        
        [dic setObject:[NSNumber numberWithInteger:responseCode] forKey:@"responseCode"];
        
        [self.delegate didFailRequest:dic];
    }

}


#pragma mark - NSURLConnectionDataDelegate


- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    [session invalidateAndCancel];
}


- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    
}


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
}

@end
