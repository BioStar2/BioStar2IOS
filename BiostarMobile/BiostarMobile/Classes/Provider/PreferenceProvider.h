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
#import <UIKit/UIKit.h>
#import "BSNetwork.h"
#import "Setting.h"
#import "Response.h"
#import "DateFormat.h"
#import "TimeFormat.h"
#import "ObjectMapper.h"
#import "InCodeMappingProvider.h"
#import "AppVersionInfo.h"
#import "NotificationSearchResult.h"
#import "BioStarVersion.h"
#import "BioStarSetting.h"
#import "LocalDataManager.h"

/**
 *
 *  @brief PreferenceProvider handle setting API
 */

@interface PreferenceProvider : NSObject
{
    BSNetwork *network;
    ObjectMapper *mapper;
    InCodeMappingProvider *mappingProvider;
}


typedef void(^SettingObjectBlock)(Setting *setting);
typedef void(^VersionObjectBlock)(AppVersionInfo *versionInfo);
typedef void(^SettingErrorBlock)(Response *error);
typedef void(^NotificationsBlock)(NotificationSearchResult *result);
typedef void(^SystemVersionBlock)(BioStarVersion *result);
typedef void(^SystemSettingBlock)(BioStarSetting *result);


+ (BioStarSetting*)getBioStarSetting;

+ (void)setBioStarSetting:(BioStarSetting*)setting;

/**
 *  Set device token for APNS
 *
 *  @param token        Device token
 */

+ (void)setDeviceToken:(NSString*)token;


/**
 *  Get Devoce Token
 *
 *  @return NSString Device token
 */

+ (NSString*)getDeviceToken;


/**
 *  Get Data format list
 *
 *  @return NSArray data format list
 *  @code 
    NSArray *list = @[@{@"name" : @"yyyy/MM/dd"}, @{@"name" : @"MM/dd/yyyy"}];
 
 * @endcode
 */
+ (NSArray*)getDataFormatList;


/**
 *  Get Time format list
 *
 *  @return NSArray Time format list
 *  @code 
    NSArray *list = @[@{@"name" : @"hh:mm"}, 
                      @{@"name" : @"a hh:mm"}, 
                      @{@"name" : @"hh:mm a"}];
 
 * @endcode
 */
+ (NSArray*)getTimeFormatList;


/**
 *  Get Data format from Biostar2 Server
 *
 *  @return NSString Data format string
 */
- (NSString*)getDateFormat;


/**
 *  Get Time format from Biostar2 Server
 *
 *  @return NSString Time format string
 */
//+ (NSString*)getTimeFormat;




/**
 *  Check if there is an app have to be updated
 *
 *  @param handler          NetworkCompleteBolck
 *
 */
- (void)checkUpdateWithCompleteHandler:(VersionObjectBlock)resultBlock onError:(SettingErrorBlock)errorBlock;


/**
 *  Get Setting Information
 *
 *  @param handler          NetworkCompleteBolck
 *
 */
- (void)getPreferenceWithCompleteHandler:(SettingObjectBlock)resultBlock onError:(SettingErrorBlock)errorBlock;




/**
 *  Update Setting
 *
 *  @param preference       preference NSDictionary
 *  @param handler          NetworkCompleteBolck
 *  @code
 
 Sample preference
 
 NSDictionary *preference = @[@{@"date_format" : @"yyyy/MM/dd"},
                              @{@"notifications" : @[
                                                     @{@"type" : @"DOOR_OPEN_REQUEST",
                                                       @"subscribed" : [NSNumber numberWithBool:YES]},
                                                     @{@"type" : @"DOOR_FORCED_OPEN",
                                                       @"subscribed" : [NSNumber numberWithBool:NO]}
                                                    ]},
                              @{@"time_format" : @"HH:mm"}];
 
 * @endcode
 */
- (void)setPreferenceProvider:(Setting *)preference CompleteHandler:(ResultBlock)resultBlock onError:(SettingErrorBlock)errorBlock;

/**
 *  Update Setting
 *
 *  @param token            Device token
 *  @param handler          NetworkCompleteBolck
 */
- (void)updateNotificationToken:(NSString*)token resultBlock:(ResultBlock)resultBlock onError:(ErrorBlock)errorBlock;

/**
 *  Get App version (biostar2 ios movile
 *
 *  @param handler          NetworkCompleteBolck
 */
- (void)getAppVersionsWithCompleteHandler:(VersionObjectBlock)resultBlock onError:(SettingErrorBlock)errorBlock;


/**
 *  Retrieves notifications
 *
 *  @param limit            Number of results
 *  @param offset           Results data offset
 *  @param handler          NetworkCompleteBolck
 */
- (void)getNotifications:(NSInteger)limit offset:(NSInteger)offset resultBlock:(NotificationsBlock)resultBlock onError:(ErrorBlock)errorBlock;


/**
 *  Acknowledge read notification
 *
 *  @param notiID           Notification ID
 *  @param handler          NetworkCompleteBolck
 */
- (void)readNotification:(NSString*)notiID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock;


/**
 *  Acknowledge read notification
 *
 *  @param notiIDs          NSString array to be deleted notifications' ID
 *  @param handler          NetworkCompleteBolck
 */
- (void)deleteNotifications:(NSArray*)notiIDs onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock;


/**
 *  Get Biostar AC version
 *
 *  @param name                 NSString array to be deleted notifications' ID
 *  @param completeBlock        SystemVersionBlock
 */
- (void)getBiostarVersion:(NSString*)name onComplete:(SystemVersionBlock)completeBlock onError:(ErrorBlock)errorBlock;

- (void)getBiostarACSetting:(SystemSettingBlock)completeBlock onError:(ErrorBlock)errorBlock;

+ (BOOL)isUpperVersion;

+ (BOOL)isSupportMobileCredentialAndFaceTemplate;

+ (BOOL)isSupportCoreSation;

@end
