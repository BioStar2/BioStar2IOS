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

@protocol PreferenceProviderDelegate <NSObject>

@optional

- (void)requestGetPreferenceDidFinish:(NSDictionary*)preferenceDic;
- (void)requestSetPreferenceDidFinish:(NSDictionary*)resultdic;

- (void)requestUpdateTokenDidFinish:(NSDictionary*)resultdic;
- (void)requestUpdateTokenDidFail:(NSDictionary*)errDic;

- (void)requestAppVersionDidFinish:(NSDictionary*)resultdic;

- (void)requestGetNotificationsDidFinish:(NSDictionary*)resultdic;
- (void)requestReadNotificationDidFinish:(NSDictionary*)resultdic;
- (void)requestDeleteNotificationDidFinish:(NSDictionary*)resultdic;

- (void)requestPreferenceProviderDidFail:(NSDictionary*)errDic;

- (void)cookieWasExpired:(NSDictionary*)errDic;

@end

typedef enum{
    REQUEST_GET_PREFERENCE,
    REQUEST_SET_PREFERENCE,
    REQUEST_UPDATE_TOKEN,
    REQUEST_APP_VERSIONS,
    REQUEST_GET_NOTIFICATIONS,
    REQUEST_READ_NOTIFICATION,
    REQUEST_DELETE_NOTIFICATION,
} PreferenceType;


@interface PreferenceProvider : NSObject <BSNetworkDelegate>
{
    BSNetwork *network;
    PreferenceType type;
    NSDictionary *preferenceDic;    // 셋팅값 저장 성공 했을때, 전역변수 값 변경을 위한 딕션어리
}

@property (assign, nonatomic) id <PreferenceProviderDelegate> delegate;

- (void)checkUpdate;
- (void)getPreferenceProvider;
- (void)setPreferenceProvider:(NSDictionary*)preference;
- (void)updateNotificationToken:(NSString*)token;
- (void)getAppVersions;
- (void)getNotifications:(NSInteger)limit offset:(NSInteger)offset;
- (void)readNotification:(NSString*)notiID;
- (void)deleteNotifications:(NSArray*)notiIDs;

+ (NSArray*)getDataFormatList;
+ (NSArray*)getTimeFormatList;
+ (NSString*)getDateFormat;
+ (NSString*)getTimeFormat;
+ (void)setDeviceToken:(NSString*)token;
+ (NSString*)getDeviceToken;
@end
