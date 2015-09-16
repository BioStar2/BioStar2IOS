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

#import "PreferenceProvider.h"

NSArray *dataFormatArray = nil;
NSArray *timeFormatArray = nil;
NSString *timeFormat = nil;
NSString *dateFormat = nil;
NSString *deviceToken = nil;            // 푸쉬에 사용될 토큰

@interface PreferenceProvider()



@end

@implementation PreferenceProvider

- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
        [network setDelegate:self];

    }
    
    return self;
}

+ (void)setDeviceToken:(NSString*)token
{
    deviceToken = token;
}

+ (NSString*)getDeviceToken
{
    return deviceToken;
}


+ (NSArray*)getDataFormatList
{
    if (nil == dataFormatArray)
    {
        dataFormatArray = @[@{@"name" : @"yyyy/MM/dd"},
                            @{@"name" : @"MM/dd/yyyy"}];
    }
    return dataFormatArray;
}

+ (NSArray*)getTimeFormatList
{
    if (nil == timeFormatArray)
    {
        timeFormatArray = @[@{@"name" : @"hh:mm"},
                            @{@"name" : @"a hh:mm"},
                            @{@"name" : @"hh:mm a"}];
    }
    return timeFormatArray;
}

+ (NSString*)getDateFormat
{
    return dateFormat;
}

+ (NSString*)getTimeFormat
{
    return timeFormat;
}


- (void)checkUpdate
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    type = REQUEST_APP_VERSIONS;
    NSString* url = [NSString stringWithFormat:@"%@%@/%@?mobile_device_type=IOS", [NetworkController sharedInstance].serverURL, API_CHECK_UPDATE, bundleIdentifier];
    
    [network requestURL:url withParam:nil method:GET];
}

- (void)getAppVersions
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    type = REQUEST_APP_VERSIONS;
    NSString* url = [NSString stringWithFormat:@"%@%@/%@?mobile_device_type=IOS", [NetworkController sharedInstance].serverURL, API_APP_VERSIONS, bundleIdentifier];
    
    [network requestURL:url withParam:nil method:GET];
}

- (void)getPreferenceProvider
{
    type = REQUEST_GET_PREFERENCE;
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_PREFERENCE];
    [network requestURL:url withParam:nil method:GET];
}

- (void)getNotifications:(NSInteger)limit offset:(NSInteger)offset
{
    type = REQUEST_GET_NOTIFICATIONS;
    NSString* url = [NSString stringWithFormat:@"%@%@?limit=%ld&offset=%ld", [NetworkController sharedInstance].serverURL, API_NOTIFICATIONS, (long)limit, (long)offset];
    [network requestURL:url withParam:nil method:GET];
}

- (void)readNotification:(NSString*)notiID
{
    type = REQUEST_READ_NOTIFICATION;
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_NOTIFICATIONS, notiID];
    [network requestURL:url withParam:nil method:PUT];
}

- (void)deleteNotifications:(NSArray*)notiIDs
{
    type = REQUEST_DELETE_NOTIFICATION;
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_DELETE_NOTIFICATIONS];
    
    
    NSError *jsonError;
    NSData *jsonData;
    NSDictionary *ids = @{@"ids" : notiIDs};
    jsonData = [NSJSONSerialization dataWithJSONObject:ids options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [network requestURL:url withParam:jsonString method:DELETE];
}

- (void)setPreferenceProvider:(NSDictionary*)preference
{
    preferenceDic = preference;
    
    type = REQUEST_SET_PREFERENCE;
    NSError *jsonError;
    NSData *jsonData;
    
    jsonData = [NSJSONSerialization dataWithJSONObject:preference options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_PREFERENCE];
    [network requestURL:url withParam:jsonString method:PUT];
    
    
}

- (void)updateNotificationToken:(NSString*)token
{
    if (nil == deviceToken)
    {
        return;
    }
    type = REQUEST_UPDATE_TOKEN;
    NSError *jsonError;
    NSData *jsonData;
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleVersion"];
    
    NSDictionary *param = @{@"mobile_app_version" : version,
                            @"mobile_device_type" : @"IOS",
                            @"mobile_os_version" : [UIDevice currentDevice].systemVersion,
                            @"notification_token" : deviceToken};
    
    jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_UPDATE_TOKEN];
    [network requestURL:url withParam:jsonString method:PUT];
}


#pragma mark - BSNetworkDelegate

- (void)didFinishRequest:(NSDictionary*)resultDic
{
    switch (type)
    {
        case REQUEST_GET_PREFERENCE:
            timeFormat = [resultDic objectForKey:@"time_format"];
            dateFormat = [resultDic objectForKey:@"date_format"];
            
            if ([self.delegate respondsToSelector:@selector(requestGetPreferenceDidFinish:)])
            {
                [self.delegate requestGetPreferenceDidFinish:resultDic];
            }
            break;
            
        case REQUEST_SET_PREFERENCE:
            timeFormat = [preferenceDic objectForKey:@"time_format"];
            dateFormat = [preferenceDic objectForKey:@"date_format"];
            if ([self.delegate respondsToSelector:@selector(requestSetPreferenceDidFinish:)])
            {
                [self.delegate requestSetPreferenceDidFinish:[resultDic objectForKey:@"Response"]];
            }
            break;
            
        case REQUEST_UPDATE_TOKEN:
            if ([self.delegate respondsToSelector:@selector(requestUpdateTokenDidFinish:)])
            {
                [self.delegate requestUpdateTokenDidFinish:resultDic];
            }
            break;
        
        case REQUEST_APP_VERSIONS:
            if ([self.delegate respondsToSelector:@selector(requestAppVersionDidFinish:)])
            {
                [self.delegate requestAppVersionDidFinish:resultDic];
            }
            break;
        case REQUEST_GET_NOTIFICATIONS:
            if ([self.delegate respondsToSelector:@selector(requestGetNotificationsDidFinish:)])
            {
                [self.delegate requestGetNotificationsDidFinish:resultDic];
            }
            break;
        case REQUEST_READ_NOTIFICATION:
            if ([self.delegate respondsToSelector:@selector(requestReadNotificationDidFinish:)])
            {
                [self.delegate requestReadNotificationDidFinish:resultDic];
            }
            break;
        case REQUEST_DELETE_NOTIFICATION:
            if ([self.delegate respondsToSelector:@selector(requestDeleteNotificationDidFinish:)])
            {
                [self.delegate requestDeleteNotificationDidFinish:resultDic];
            }
            break;
            break;
    }
}

- (void)didFailRequest:(NSDictionary*)errDic
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
    else
    {
        if (type == REQUEST_UPDATE_TOKEN)
        {
            if ([self.delegate respondsToSelector:@selector(requestUpdateTokenDidFail:)])
            {
                [self.delegate requestPreferenceProviderDidFail:errDic];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(requestPreferenceProviderDidFail:)])
            {
                [self.delegate requestPreferenceProviderDidFail:errDic];
            }
        }
    }
}
@end
