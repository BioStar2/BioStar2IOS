
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
#import "UserProvider.h"

#define LoginProviderInstance   [LoginProvider sharedInstance]

@protocol AuthProviderDelegate <NSObject>

@optional

- (void)loginDidFinish:(NSDictionary*)userInfo;
- (void)loginDidFail:(NSDictionary*)errDic;


- (void)logoutDidFinish:(NSDictionary*)userInfo;
- (void)logoutDidFail:(NSDictionary*)errDic;

- (void)cookieWasExpired:(NSDictionary*)errDic;
@end


@interface AuthProvider : NSObject <BSNetworkDelegate>
{

    
    BSNetwork *network;
    BOOL isForLogin;
}

@property (nonatomic, assign)id <AuthProviderDelegate> delegate;

+ (NSDictionary*)getLoginUserInfo;
+ (void)setLoginUserInfo:(NSDictionary*)loginInfo;
- (void)setServerURL:(NSString*)URL;
+ (BOOL)hasWritePermission:(NSString*)permissionValue;
+ (BOOL)hasReadPermission:(NSString*)permissionValue;
/**
 *  로그인 요청
 *
 *  @param loginID  ID
 *  @param password Password
 *  @param address  server URL
 */
- (void)login:(NSString*)loginID passwork:(NSString*)password name:(NSString*)name;
- (void)logout;
@end
