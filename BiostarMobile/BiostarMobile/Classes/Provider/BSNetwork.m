
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


#define TIMEOUT_INTERVAL 60

@implementation BSNetwork


- (id)init
{
    if (self = [super init])
    {

    }
    return self;
}

- (NSData*)convertToNSDate:(NSString*)body
{
    NSData *bodyData = nil;
    if (nil != body)
    {
        bodyData = [[NSData alloc] initWithData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return bodyData;
}


- (void)request:(NSString *)URL withParam:(NSString*)param method:(Method)method completionHandler:(NetworkCompleteBolck)handler
{
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSURL *url = [NSURL URLWithString:[URL stringByAddingPercentEncodingWithAllowedCharacters:set]];
    
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    [mutableRequest setTimeoutInterval:TIMEOUT_INTERVAL];
    [mutableRequest setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    
    
    switch (method)
    {
        case GET:
        case PHOTO_GET:
            [mutableRequest setHTTPMethod:@"GET"];
            [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        case POST:
        case LOGIN_POST:
            [mutableRequest setHTTPMethod:@"POST"];
            [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        case PUT:
            [mutableRequest setHTTPMethod:@"PUT"];
            [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        case DELETE:
            [mutableRequest setHTTPMethod:@"DELETE"];
            [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        case PHOTO_PUT:
            [mutableRequest setHTTPMethod:@"PUT"];
            [mutableRequest setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
            break;
    }
    
    //NSString *isoCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString* code = [NSLocale currentLocale].languageCode;
    
    [mutableRequest setValue:code forHTTPHeaderField:@"content-language"];
    
    if (method != GET && method != PHOTO_GET)
    {
        NSData *bodyData = [self convertToNSDate:param];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[bodyData length]];
        [mutableRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [mutableRequest setHTTPBody:bodyData];
    }
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:
                              [cookieJar cookies]];
    [mutableRequest setAllHTTPHeaderFields:headers];
    
    
    
    task = [NetworkControllerInstance.URLsession dataTaskWithRequest:mutableRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (nil == error)
        {
            if (method == LOGIN_POST)
            {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] getCookiesForTask:task completionHandler:^(NSArray *cookies) {
                    // 쿠키 저장하기
                    [LocalDataManager storeLocalCookies:cookies URL:url];
                    
                }];
            }
            else if (method == PHOTO_GET)
            {
                NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSRange range = [responseStr rangeOfString:@","];
                
                NSString *imageString;
                
                if (range.location != NSNotFound) {
                    imageString = [responseStr substringFromIndex:range.location + 1];
                }
                else
                {
                    imageString = responseStr;
                }
                
                
                NSDictionary *dic = @{@"user_image" : imageString};
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(dic, error);
                });
                
                return ;

            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self parseRequestResult:data response:response returnBlock:^(NSDictionary *resultDic, NSError *error, BOOL loginExpired) {
                    if (loginExpired)
                    {
                        [BaseViewController sessionExpired];
                        return;
                    }
                    else
                    {
                        handler(resultDic, error);
                    }
                }];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableDictionary *errorDic = [[NSMutableDictionary alloc] init];
                
                NSString *errorMessage = [NSString stringWithFormat:@"errorCode : %ld \n dec : %@ \n domain : %@",error.code ,[error localizedDescription], error.domain];
                [errorDic setObject:errorMessage forKey:@"message"];
                
                handler(errorDic, error);
            });
        }
        
        
    }];
    
    [task resume];
}

- (void)parseRequestResult:(NSData*)data response:(NSURLResponse*)response returnBlock:(void (^)(NSDictionary *resultDic, NSError *error, BOOL loginExpired))returnBlock
{
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger status_code = httpResponse.statusCode;
    NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *decData = [self convertToNSDate:responseStr];
    NSMutableDictionary *dic;
    if (nil == decData || decData.length == 0)
    {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        [tempDic setObject:NSBaseLocalizedString(@"error_network2", nil) forKey:@"message"];
        NSError *error = [NSError errorWithDomain:@"" code:1000 userInfo:tempDic];
        returnBlock(tempDic, error, NO);
        return;
    }
    else
    {
        id APIParseResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([APIParseResult isKindOfClass:[NSDictionary class]])
        {
            dic = [[NSMutableDictionary alloc] initWithDictionary:APIParseResult];
        }
        else
        {
            NSArray *resultArray = [[NSMutableArray alloc] initWithArray:APIParseResult];
            
            dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:resultArray, @"records", nil];
        }
        
    }
    
    if (200 <= status_code && status_code <= 299)
    {
        returnBlock(dic, nil, NO);
    }
    else
    {
        if (status_code != 401)
        {
            if (nil == [dic objectForKey:@"message"] || [[dic objectForKey:@"message"] isEqualToString:@""])
            {
                [dic setObject:NSBaseLocalizedString(@"error_network2", nil) forKey:@"message"];
            }
            
            NSError *error = [NSError errorWithDomain:@"" code:1000 userInfo:dic];
            returnBlock(dic, error, NO);
        }
        else
        {
            NSLog(@"login expired!!!!!");
            returnBlock(dic, nil, YES);
        }
    }
}

@end
