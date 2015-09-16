
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

#import <Foundation/Foundation.h>

#import "NetworkController.h"

@protocol BSNetworkDelegate <NSObject>

@required

- (void)didFinishRequest:(NSDictionary*)resultDic;
- (void)didFailRequest:(NSDictionary*)errDic;

@optional

- (void)didFinishPhotoRequest:(NSString*)responseString fromURL:(NSString*)url;

@end



@interface BSNetwork : NSObject <NSURLSessionDelegate>
{
    NSURLSessionDataTask* loginTask;
}

@property (nonatomic, weak)id <BSNetworkDelegate> delegate;

- (void)setBSNetworkDelegate:(id)_delegate;
- (void)requestURL:(NSString*)URL withParam:(NSString*)param method:(Method)method;
- (void)setServerURL:(NSString*)url;
- (void)requestLogin:(NSString*)URL withParam:(NSString*)param method:(Method)method;
- (void)requestGetMethod:(NSString*)URL withParam:(NSString*)param method:(Method)method;
- (void)requestPostMethod:(NSString*)URL withParam:(NSString*)param method:(Method)method;
- (void)requestDeleteMethod:(NSString*)URL withParam:(NSString*)param method:(Method)method;
- (void)requestPutMethod:(NSString*)URL withParam:(NSString*)param method:(Method)method;
- (void)parseRequestResult:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error;
- (void)parsePhotoRequestResult:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error;
- (void)parsePostRequestResult:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error;
@end
