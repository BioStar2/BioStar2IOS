
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

#define Time_Out_Interval               60
#define NetworkControllerInstance   [NetworkController sharedInstance]

#define API_LOGIN                                           @"/login"
#define API_LOGOUT                                          @"/logout"
#define API_MY_PROFILE                                      @"/users/my_profile"
#define API_USERS                                           @"/users"
#define API_USER_PHOTO                                      @"/users/%@/photo"
#define API_DELETE_USERS                                    @"/users/delete"
#define API_USERS_FINGERPRINT_TEMPLATES                     @"/users/%@/fingerprint_templates"
#define API_USERS_FACE_TEMPLATES                            @"/users/%@/face_templates"
#define API_USERS_CARDS                                     @"/users/%@/cards"
#define API_USERS_MOBILE_CREDENTIAL                         @"/users/%@/mobile_credentials"
#define API_USERS_ISSUE_MOBILE_CREDENTIAL                   @"/users/%@/mobile_credentials/issue"
#define API_USERS_REISSUE_MOBILE_CREDENTIAL                 @"/users/%@/mobile_credentials/%@/reissue"
#define API_USERS_REGISTER_MOBILE_CREDENTIAL                @"/users/my_profile/mobile_credentials/%@/register"

#define API_MY_PROFILE_MOBILE_CREDENTIAL                    @"/users/my_profile/mobile_credentials"
#define API_USER                                            @"/user/"
#define API_USER_GROUPS                                     @"/user_groups"
#define API_ACCESS_GROUPS                                   @"/access_groups"

#define API_CARDS                                           @"/cards/unassigned"
#define API_SMART_CARD_LAYOUT                               @"/cards/smart_cards/layouts"
#define API_WEIGAND_FORMAT                                  @"/cards/wiegand_cards/formats"
#define API_CSN_CARDS                                       @"/cards/csn_card"
#define API_WIEGAND_CARDS                                   @"/cards/wiegand_card"
#define API_SECURE_CARDS                                    @"/cards/secure_credential_card"
#define API_ACCESS_CARDS                                    @"/cards/access_on_card"
#define API_MOBILE_CREDENTIAL                               @"/cards/mobile_credentials"
#define API_BLOCK_CARD                                      @"/cards/%@/block"
#define API_UNBLOCK_CARD                                    @"/cards/%@/unblock"
#define API_DEVICES                                         @"/devices"
#define API_DEVICE_TYPES                                    @"/device_types"
#define API_DEVICE_SCAN_FINGERPRINT                         @"/scan_fingerprint"
#define API_DEVICE_SCAN_FACE                                @"/scan_face"
#define API_DEVICE_VERIFY_FINGERPRINT                       @"/verify_fingerprint"
#define API_DEVICE_WRITE_CARD                               @"/write_card"
#define API_DEVICE_SCAN_CARD                                @"/scan_card"

#define API_DOORS                                           @"/doors"
#define API_DOORS_OPEN                                      @"/doors/%ld/open"
#define API_DOORS_UNLOCK                                    @"/doors/%ld/unlock"
#define API_DOORS_RELEASE                                   @"/doors/%ld/release"
#define API_DOORS_LOCK                                      @"/doors/%ld/lock"
#define API_DOORS_CLEAR_ALARM                               @"/doors/%ld/clear_alarm"
#define API_DOORS_CLEAR_APB                                 @"/doors/%ld/clear_anti_pass_back"
#define API_DOORS_REQUEST_OPEN                              @"/doors/%ld/request_open"

#define API_EVENTS                                          @"/events"
#define API_EVENTS_SEARCH                                   @"/monitoring/event_log/search_more"
#define API_EVENT_TYPES                                     @"/references/event_types"

#define API_PERMISSIONS                                     @"/references/role_codes"
//#define API_PRIVILEGES                                      @"/permissions"
#define API_PRIVILEGES                                      @"/setting/permission_list"
#define API_PREFERENCE                                      @"/setting"
#define API_NOTIFICATIONS                                   @"/setting/notifications"
#define API_DELETE_NOTIFICATIONS                            @"/setting/notifications/delete"
#define API_SYSTEM_SETTING                                  @"/setting/biostar_ac"
#define API_UPDATE_TOKEN                                    @"/setting/update_notification_token"
#define API_APP_VERSIONS                                    @"/admin/app_versions"

#define API_SYSTEM_VERSIONS                                 @"/references/%@/biostar_version"
#define API_CHECK_UPDATE                                    @"/register/app_versions"



/**
 *
 *  @brief NetworkController control NSURLSession
 */

@interface NetworkController : NSObject


/**
 * Server URL for API request
 */
@property (nonatomic, strong) NSString *serverURL;

@property (nonatomic, strong) NSURLSession *URLsession;

+ (NetworkController*)sharedInstance;
+ (void)resetSharedInstance;

/**
 * Cancel All Requests
 *
 */
- (void)cancelAllRequests;


/**
 *  Set server URL for API request
 *  @param      URL String URL
 */
- (void)setServerURL:(NSString*)URL cloudVersion:(NSString*)version;
@end


