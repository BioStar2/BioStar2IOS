
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
#import "NSData+Base64.h"

#define NetworkControllerInstance   [NetworkController sharedInstance]

typedef enum{
    GET,
    POST,
    PUT,
    DELETE,
    LOGIN_POST,
    PHOTO_GET,
    UNDEFINED,
} Method;


#define API_LOGIN                       @"/login"
#define API_LOGOUT                      @"/logout"
#define API_MY_PROFILE                  @"/users/my_profile"
#define API_USERS                       @"/users"
#define API_USER_PHOTO                  @"/users/%@/photo"
#define API_DELETE_USERS                @"/users/delete"
#define API_USER                        @"/user/"
#define API_USER_GROUPS                 @"/user_groups"
#define API_ACCESS_GROUPS               @"/access_groups"
#define API_ACCESS_LEVELS               @"/access_levels"

#define API_CARDS                       @"/cards/unassigned"
#define API_DEVICES                     @"/devices"
#define API_DEVICE_TYPES                @"/device_types"
#define API_DEVICE_SCAN_FINGERPRINT     @"/scan_fingerprint"
#define API_DEVICE_VERIFY_FINGERPRINT   @"/verify_fingerprint"
#define API_DEVICE_WRITE_CARD           @"/write_card"
#define API_DEVICE_SCAN_CARD            @"/scan_card"

#define API_DOORS                       @"/doors"
#define API_DOORS_OPEN                  @"/doors/%ld/open"
#define API_DOORS_UNLOCK                @"/doors/%ld/unlock"
#define API_DOORS_LOCK                  @"/doors/%ld/lock"
#define API_DOORS_CLEAR_ALARM           @"/doors/%ld/clear_alarm"
#define API_DOORS_CLEAR_APB             @"/doors/%ld/clear_anti_pass_back"
#define API_DOORS_REQUEST_OPEN          @"/doors/%ld/request_open"

#define API_EVENTS                      @"/events"
#define API_EVENTS_SEARCH               @"/monitoring/event_log/search"
#define API_EVENT_TYPES                 @"/references/event_types"

#define API_PERMISSIONS                 @"/references/role_codes"
#define API_PREFERENCE                  @"/setting"
#define API_NOTIFICATIONS               @"/setting/notifications"
#define API_DELETE_NOTIFICATIONS        @"/setting/notifications/delete"
#define API_UPDATE_TOKEN                @"/setting/updateNotificationToken"
#define API_APP_VERSIONS                @"/admin/app_versions"
#define API_CHECK_UPDATE                @"/register/app_versions"



@interface NetworkController : NSObject
{
    NSMutableArray *networks;
}

@property (nonatomic, strong) NSString *serverURL;
@property (nonatomic, strong) NSURLSession *URLsession;

+ (NetworkController*)sharedInstance;       // 로그아웃이나 세션 만료일때 호출함
+ (void)resetSharedInstance;

- (void)cancelAllRequests;
- (NSData*)convertToNSDate:(NSString*)body;
- (void)setServerURL:(NSString*)url;
@end


