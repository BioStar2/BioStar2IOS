
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

#import "AuthProvider.h"

NSDictionary *loginUserInfo = nil;

@interface AuthProvider()

@end

@implementation AuthProvider

@synthesize delegate;


+ (NSDictionary*)getLoginUserInfo
{
    return loginUserInfo;
}

+ (void)setLoginUserInfo:(NSDictionary*)loginInfo
{
    loginUserInfo = loginInfo;
}

- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
        network.delegate = self;
        isForLogin = NO;
    }
    
    return self;
}

- (void)setServerURL:(NSString*)URL
{
    [network setServerURL:URL];
}


+ (BOOL)hasWritePermission:(NSString*)permissionValue
{
    if (nil == loginUserInfo)
    {
        return NO;
    }
    
    NSArray *permissions = [loginUserInfo objectForKey:@"permissions"];
    
    NSDictionary *permission = nil;
    
    for (NSDictionary *tempPermission in permissions)
    {
        if ([permissionValue isEqualToString:[tempPermission objectForKey:@"module"]])
        {
            permission = tempPermission;
            break;
        }
    }
    
    if (!permission)
    {
        return NO;
    }
    
    return [[permission objectForKey:@"write"] boolValue];
}

+ (BOOL)hasReadPermission:(NSString*)permissionValue
{
    NSArray *permissions = [loginUserInfo objectForKey:@"permissions"];
    
    NSDictionary *permission = nil;
    
    for (NSDictionary *tempPermission in permissions)
    {
        if ([permissionValue isEqualToString:[tempPermission objectForKey:@"module"]])
        {
            permission = tempPermission;
            break;
        }
    }
    
    if (!permission)
    {
        return NO;
    }
    
    return [[permission objectForKey:@"read"] boolValue];
}

- (void)login:(NSString*)loginID passwork:(NSString*)password name:(NSString*)name
{

    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    version = [NSString stringWithFormat:@"V.%@", version];
    
    NSDictionary *userDic = @{@"user_id" : loginID,
                              @"password" : password,
                              @"name" : name,
                              @"mobile_app_version" : version,
                              @"mobile_device_type" : @"IOS",
                              @"mobile_os_version" : [UIDevice currentDevice].systemVersion, 
                              };

    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:userDic options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    [network requestURL:[NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_LOGIN] withParam:jsonString method:LOGIN_POST];
    isForLogin = YES;
}

- (void)logout
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_LOGOUT];
    
    [network requestURL:url withParam:nil method:GET];
    isForLogin = NO;
}


#pragma mark - BSNetwork delegate


- (void)didFinishRequest:(NSDictionary*)resultDic
{
    if (isForLogin)
    {
        if ([self.delegate respondsToSelector:@selector(loginDidFinish:)])
        {
            loginUserInfo = resultDic;
            [UserProvider setPasswordStrengthLevel:[resultDic objectForKey:@"password_strength_level"]];
            [self.delegate loginDidFinish:resultDic];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(logoutDidFinish:)])
        {
            loginUserInfo = nil;
            [self.delegate logoutDidFinish:resultDic];
        }
    }
    

}

- (void)didFailRequest:(NSDictionary*)errDic
{
    if (isForLogin)
    {
        NSInteger code = [[errDic objectForKey:@"responseCode"] integerValue];
        
        if (code == 401)
        {
            // 세션 만료
            if ([self.delegate respondsToSelector:@selector(cookieWasExpired:)])
            {
                [self.delegate cookieWasExpired:errDic];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(loginDidFail:)])
        {
            [self.delegate loginDidFail:errDic];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(logoutDidFail:)])
        {
            [self.delegate logoutDidFail:errDic];
        }
    }
    
}
@end
