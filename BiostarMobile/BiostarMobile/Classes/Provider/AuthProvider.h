
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
#import "BSNetwork.h"
#import <UIKit/UIKit.h>
#import "ObjectMapper.h"
#import "InCodeMappingProvider.h"
#import "UserProvider.h"
#import "User.h"
#import "PreferenceProvider.h"


#define LoginProviderInstance   [LoginProvider sharedInstance]

/**
 *
 *  @brief AuthProvider request API and respond for auth.
 */

@interface AuthProvider : NSObject
{
    BSNetwork *network;
    ObjectMapper *mapper;
    InCodeMappingProvider *mappingProvider;
}

typedef void(^LoginUserBlock)(User *userResult);






/**
 *  Get user Info(logged in)
 *
 *  @return User
 */
+ (User*)getLoginUserInfo;

/**
 *  Set user Info(logged in)
 *
 *  @param loginInfo    User Info dictionary
 */
+ (void)setLoginUserInfo:(User*)user;

/**
 *  Check write permission
 *
 *  @param permissionValue    Permission String
 *  @return BOOL              YES if User has write permission
 */
+ (BOOL)hasWritePermission:(NSString*)permissionValue;

/**
 *  Check read permission
 *
 *  @param permissionValue    Permission String
 *  @return BOOL              YES if User has read permission
 */
+ (BOOL)hasReadPermission:(NSString*)permissionValue;

/**
 *  Login request
 *
 *  @param loginID              User Login ID
 *  @param password             Password
 *  @param name                 Biostar subdomain name
 *  @param handler              NetworkCompleteBolck
 */
- (void)login:(NSString*)loginID password:(NSString*)password name:(NSString*)name userBlock:(LoginUserBlock)userBlock onError:(ErrorBlock)errorBlock;


/**
 *  Logout request
 *
 *  @param handler              NetworkCompleteBolck
 */
- (void)logout:(ResultBlock)responseBlock onError:(ErrorBlock)errorBlock;

@end
