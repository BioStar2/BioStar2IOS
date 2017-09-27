
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
#import "BaseViewController.h"
#import "Response.h"
#import "AddResponse.h"
#import "LocalDataManager.h"

/**
 *
 *  @brief BSNetwork request API to server and parse the result.
 */

@interface BSNetwork : NSObject
{
    NSURLSessionDataTask* task;
}


typedef enum{
    /*! Get mothod */
    GET,
    /*! Post method */
    POST,
    /*! Put method */
    PUT,
    /*! Delete method */
    DELETE,
    /*! Post method for login */
    LOGIN_POST,
    /*! Get mothod for photo*/
    PHOTO_GET,
    PHOTO_PUT
} Method;


typedef void(^ResultBlock)(Response *response);
typedef void(^ErrorBlock)(Response *error);
typedef void(^AddBlock)(AddResponse *response);

/**
 * Block method
 *
 * This block method will be returned when network request finish
 * 
 * @param responseObject    API result object
 * @param error             API error object
 *
 */
typedef void(^NetworkCompleteBolck)(NSDictionary *responseObject, NSError *error);

/**
 * Block method
 *
 * This block method will be returned after API result parse
 *
 * @param resultDic         API result object
 * @param error             API error object
 * @param loginExpired      YES if session was expired
 */
typedef void(^ParserCompleteBolck)(NSDictionary *resultDic, NSError *error, BOOL loginExpired);

/**
 * Get NSData for request body
 *
 * @param body       NSString body
 * @return           Converted NSData from NSString body
 */
- (NSData*)convertToNSDate:(NSString*)body;

/**
 * Get NSData for request body
 *
 * @param URL         Server API URL
 * @param param       Body data(Json string)
 * @param method      GET, POST, PUT, DELETE
 * @param handler     A callback block that should be executed when get API response
 */
- (void)request:(NSString *)URL withParam:(NSString*)param method:(Method)method completionHandler:(NetworkCompleteBolck)handler;

/**
 * Get NSData for request body
 *
 * @param data              API result data
 * @param response          API response
 * @param returnBlock       Callback block
 */
- (void)parseRequestResult:(NSData*)data response:(NSURLResponse*)response returnBlock:(ParserCompleteBolck)returnBlock;


@end
