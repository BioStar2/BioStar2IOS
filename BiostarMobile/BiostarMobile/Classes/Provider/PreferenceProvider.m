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

NSArray <DateFormat *> *dataFormatArray = nil;
NSArray <TimeFormat *> *timeFormatArray = nil;
NSString *timeFormat = nil;
NSString *dateFormat = nil;
NSString *deviceToken = nil;            // 푸쉬에 사용될 토큰
Setting *setting = nil;

BioStarSetting *biostarSetting = nil;


@implementation PreferenceProvider

- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
        
        mappingProvider = [[InCodeMappingProvider alloc] init];
        
        mapper = [[ObjectMapper alloc] init];
        mapper.mappingProvider = mappingProvider;
    }
    
    return self;
}

+ (BioStarSetting*)getBioStarSetting
{
    return biostarSetting;
}

+ (void)setBioStarSetting:(BioStarSetting*)setting
{
    biostarSetting = setting;
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
        DateFormat *first_format = [DateFormat new];
        first_format.date_format = @"yyyy/MM/dd";
        first_format.isSelected = NO;
        
        DateFormat *second_format = [DateFormat new];
        second_format.date_format = @"MM/dd/yyyy";
        second_format.isSelected = NO;
        
        DateFormat *third_format = [DateFormat new];
        third_format.date_format = @"dd/mm/yyyy";
        third_format.isSelected = NO;
        
        dataFormatArray = @[first_format, second_format, third_format];
    }
    return dataFormatArray;
}

+ (NSArray*)getTimeFormatList
{
    if (nil == timeFormatArray)
    {
        TimeFormat *first_format = [TimeFormat new];
        first_format.time_format = @"hh:mm";
        first_format.isSelected = NO;
        
        TimeFormat *second_format = [TimeFormat new];
        second_format.time_format = @"a hh:mm";
        second_format.isSelected = NO;
        
        TimeFormat *third_format = [TimeFormat new];
        third_format.time_format = @"hh:mm a";
        third_format.isSelected = NO;
        
        
        timeFormatArray = @[first_format,
                            second_format,
                            third_format];
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

- (void)checkUpdateWithCompleteHandler:(VersionObjectBlock)resultBlock onError:(SettingErrorBlock)errorBlock
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@?mobile_device_type=IOS", [NetworkController sharedInstance].serverURL, API_CHECK_UPDATE, bundleIdentifier];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            AppVersionInfo *versionInfo = [mapper objectFromSource:responseObject toInstanceOfClass:[AppVersionInfo class]];
            resultBlock(versionInfo);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
    
}


- (void)getPreferenceWithCompleteHandler:(SettingObjectBlock)resultBlock onError:(SettingErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_PREFERENCE];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"noti_description" forClass:[NotificationSetting class]];
            
            [mappingProvider mapFromDictionaryKey:@"notifications" toPropertyKey:@"notifications" withObjectType:[NotificationSetting class] forClass:[Setting class]];
            
            setting = [mapper objectFromSource:responseObject toInstanceOfClass:[Setting class]];
            
            timeFormat = setting.time_format;
            dateFormat = setting.date_format;
            
            resultBlock(setting);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
        
    }];
}


- (void)setPreferenceProvider:(Setting *)preference CompleteHandler:(ResultBlock)resultBlock onError:(SettingErrorBlock)errorBlock;
{
    setting = preference;
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[mapper dictionaryFromObject:preference] options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_PREFERENCE];
    
    [network request:url withParam:jsonString method:PUT completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            timeFormat = setting.time_format;
            dateFormat = setting.date_format;
            
            Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            resultBlock(response);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
    
    
}

- (void)getAppVersionsWithCompleteHandler:(VersionObjectBlock)resultBlock onError:(SettingErrorBlock)errorBlock
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@?mobile_device_type=IOS", [NetworkController sharedInstance].serverURL, API_APP_VERSIONS, bundleIdentifier];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        if (nil == error)
        {
            AppVersionInfo *versionInfo = [mapper objectFromSource:responseObject toInstanceOfClass:[AppVersionInfo class]];
            resultBlock(versionInfo);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
    
}



- (void)getNotifications:(NSInteger)limit offset:(NSInteger)offset resultBlock:(NotificationsBlock)resultBlock onError:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@?limit=%ld&offset=%ld", [NetworkController sharedInstance].serverURL, API_NOTIFICATIONS, (long)limit, (long)offset];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"loc-args" toPropertyKey:@"loc_args" forClass:[EventModel class]];
            [mappingProvider mapFromDictionaryKey:@"loc-key-args" toPropertyKey:@"loc_key_args" forClass:[EventModel class]];
            [mappingProvider mapFromDictionaryKey:@"title-loc-key" toPropertyKey:@"title_loc_key" forClass:[EventModel class]];
            
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[GetNotification class] forClass:[NotificationSearchResult class]];
            
            NotificationSearchResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[NotificationSearchResult class]];
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}

- (void)readNotification:(NSString*)notiID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_NOTIFICATIONS, notiID];
    
    [network request:url withParam:nil method:PUT completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            completeBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
    
}

- (void)deleteNotifications:(NSArray*)notiIDs onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_DELETE_NOTIFICATIONS];
    
    NSError *jsonError;
    NSDictionary *ids = @{@"ids" : notiIDs};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ids options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [network request:url withParam:jsonString method:DELETE completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            completeBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
    
    
}


- (void)updateNotificationToken:(NSString*)token resultBlock:(ResultBlock)resultBlock onError:(ErrorBlock)errorBlock
{
#warning error meessage must be in
    if (nil == deviceToken)
    {
        return;
    }
    
    NSError *jsonError;
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *param = @{@"mobile_app_version" : version,
                            @"mobile_device_type" : @"IOS",
                            @"mobile_os_version" : [UIDevice currentDevice].systemVersion,
                            @"notification_token" : deviceToken};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_UPDATE_TOKEN];
    
    [network request:url withParam:jsonString method:PUT completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *resoponse = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            if (nil != resultBlock)
            {
                resultBlock(resoponse);
            }
        }
        else
        {
            if (nil != errorBlock)
            {
                errorBlock(resoponse);
            }
            
        }
        
    }];
}


- (void)getBiostarVersion:(NSString*)name onComplete:(SystemVersionBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_SYSTEM_VERSIONS, name]];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        if (nil == error)
        {
            BioStarVersion *biostarVersion = [mapper objectFromSource:responseObject toInstanceOfClass:[BioStarVersion class]];
            
            completeBlock(biostarVersion);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}


- (void)getBiostarACSetting:(SystemSettingBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_SYSTEM_SETTING];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        if (nil == error)
        {
            BioStarSetting *setting = [mapper objectFromSource:responseObject toInstanceOfClass:[BioStarSetting class]];
            
            [PreferenceProvider setBioStarSetting:setting];
            
            completeBlock(setting);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}

+ (BOOL)isUpperVersion
{
    NSString *version = [LocalDataManager getBiostarACVersion];
    if ([APP_SEPARATION_VERSION compare:version options:NSNumericSearch] == NSOrderedDescending)
    {
        // V1
        return NO;
    }
    else
    {
        // V2
        return YES;
    }
}

@end
