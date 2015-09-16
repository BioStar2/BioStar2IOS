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

static const NSInteger NOT_DEFINED= -1;
// STATUS= OK
static const NSInteger SUCCESS= 0;		//< Success (no error)
static const NSInteger PARTIAL_SUCCESS= 1;		//< Request is successful; but partially
static const NSInteger ALREADY_LOGGED_IN= 2;		//< User has already logged in
static const NSInteger DEVICE_HAS_INVALID_CONFIG= '3'; //< Device has confugration which server can not be parsed.
static const NSInteger WEB_REQUEST_TIMEOUT= 4;		//< Synced Web Request is not respond in timeout period

// STATUS= UNAUTHORIZED
static const NSInteger LOGIN_REQUIRED= 10;		//< Login is required
static const NSInteger SESSION_TIMEOUT= 11;		//< Session is invalid for timeout

// STATUS= FORBIDDEN
static const NSInteger PERMISSION_DENIED= 20;		//< Request is forbidden because have no permission

static const NSInteger INVALID_PARAMETERS= 30;   //< Parameter(s) is(are) not valid on URI.

// BAD_REQUEST
// general
static const NSInteger LOGIN_FAILED= 101;		//< Failed to login for invalid username or password
static const NSInteger METHOD_NOT_ALLOWED= 102;		//< Request method is not allowed
static const NSInteger NOT_SUPPORTED_REQUEST= 103;		//< Request is not supported
static const NSInteger INVALID_JSON_FORMAT= 104;		//< Request parameter is invalid
static const NSInteger INVALID_QUERY_PARAMETER= 105;		//< Request query parameter is invalid
static const NSInteger COULD_NOT_UPDATE_OR_DELETE_PREDEFINED_ITEMS= 106; //< Impossible to update or delete predefined items.
// user
static const NSInteger USER_NOT_FOUND= 201;		//< User can not be found with id
static const NSInteger DUPLICATED_USER= 202;		//< User who has same id alreay exists
static const NSInteger DUPLICATED_FINGERPRINT= 203;		//< FingerprNSInteger template duplicated with other user
static const NSInteger DUPLICATED_USERGROUP= 204;		//< User group that has same name already exists
static const NSInteger ADMIN_COULD_NOT_BE_DELETED= 205;///< Admin could be deleted.
static const NSInteger ADMIN_COULD_NOT_HAVE_OTHER_PERMISSION= 206;
static const NSInteger ID_COULD_NOT_BE_CHANGED= 207;
static const NSInteger DUPLICATED_LOGIN_ID= 208;		//< User who has same id alreay exists
static const NSInteger FAILED_TO_ENROLL_USER= 209;		//< Failed to enroll user
static const NSInteger DEVICE_USERS_FULL= 210;		//< users maxed out on device

// device
static const NSInteger DUPLICATED_DEVICE= 300;		//< Device that has same name already exists
static const NSInteger DEVICE_NOT_FOUND= 301;		//< Device can not be found with id
static const NSInteger DEVICE_COULD_NOT_ENABLE_FULL_ACCESS= 302; //< Device what is included in an Access Group can not enable full access.
static const NSInteger TOO_MANY_DEVICE_OPERATOR= 303;//< The number of device operators can be up to 10.
static const NSInteger FAILED_TO_ADD_DEVICE= 304;//< Failed to add device.
static const NSInteger DUPLICATED_DEVICE_GROUP= 65645;		//< Device Group 명이 중복됩니다.
static const NSInteger TOO_MANY_ACCESS_GROUP_ASSIGNED= 65637;		//< Too many access groups are assigned for given user ( max 16 access groups)
// card
static const NSInteger CARD_NOT_FOUND= 400;		//< Card can not be found with id
static const NSInteger DUPLICATED_CARD= 401;		//< Card that has same id already exists
// device group
static const NSInteger DEVICE_GROUP_NOT_FOUND= 500;///< Device Group doesn't exist.
// User Group
static const NSInteger USER_GROUP_NOT_FOUND= 600;///< User Group doesn't exist.
// Door
static const NSInteger DOOR_NOT_FOUND= 601;///< Door doesn't exist.
static const NSInteger HOLIDAYGROUP_NOT_FOUND= 602;///< Holiday Group doesn't exist.
static const NSInteger ACCESSGROUP_NOT_FOUND= 603;///< Access Group doesn't exist.
static const NSInteger SCHEDULE_NOT_FOUND= 604;///< Schedule doesn't exist.
static const NSInteger ACCESSLEVEL_NOT_FOUND= 605;///< Access Level doesn't exist.
static const NSInteger PERMISSION_NOT_FOUND= 606;
static const NSInteger DOOR_GROUP_NOT_FOUND= 607;///< Door Group doesn't exist.
static const NSInteger PREFERENCE_NOT_FOUND= 608;
//Access Group
static const NSInteger COULD_HAVE_FULL_ACCESS_DEVICES= 650; //< Access Group can not have Device(s) what is(are) set Full Access enabled.
static const NSInteger TOO_MANY_ACCESSGROUP= 651;
static const NSInteger ACCESSGROUPLEVEL_DUPLICATED_NAME= 652;   //< The name is duplicated.
static const NSInteger NO_ACCESSGROUP_NAME_EXISTS= 653;
static const NSInteger INVALID_DOOR= 65644;

// Json
static const NSInteger FAILED_TO_PARSE_JSON= 700;///< Failed to parse json data.
static const NSInteger FAILED_TO_PARSE_JSON_INTERNAL= 701; //< Failed to parse json data by NSIntegerernal server error

static const NSInteger FAILED_TO_EXECUTE_DB_QUERY= 800;///< Failed to execute Database query
// STATUS= NSIntegerERNAL
// General
static const NSInteger SERVER_ERROR= 1000;		//< Something wrong with server
static const NSInteger DEVICE_IS_NOT_CONNECTED= 1001;		//< Device is not connected to biostar
static const NSInteger DEVICE_IS_NOT_READY= 1002;		//< Device is connected but not accpeted
static const NSInteger DEVICE_REQUEST_TIMEOUT= 1003;		//< Device does not respond within the timeout period
// Network
static const NSInteger NET_INVALID_ADDRESS= 1004;		//< Network address is invalid
static const NSInteger NET_CONNECTION_FAILED= 1005;		//< Failed to connect device
static const NSInteger NET_WRONG_CHECKSUM= 1010;		//< Packet checksum is wrong
static const NSInteger NET_MALFORMED_HEADER= 1011;		//< Header format is not valid
static const NSInteger NET_MALFORMED_PAYLOAD= 1012;		//< Payload format is not valid
static const NSInteger DEVICE_NOT_SUPPORTED= 1013;
// fingerprNSInteger scan
static const NSInteger FINGERPRINT_QUALITY_TOO_LOW= 1014;
static const NSInteger FAILED_TO_VERIFY_FINGERPRINT= 1015;
static const NSInteger FAILED_TO_UPGRADE_FIRMWARE= 1016;
static const NSInteger DEVICE_IS_BUSY= 1017;
static const NSInteger FAILED_TO_SCAN_FINGERPRINT= 1018;
//biostar update
static const NSInteger BIOSTAR_UPDATE_SERVER_BUSY= 1020;  //< biostar launcher is busy... try later.
static const NSInteger BIOSTAR_UPDATE_NOT_EXIST= 1021;  //< biostar update version is not exist
static const NSInteger LAUNCHER_REQUEST_TIMEOUT= 1022;	//< Launcher does not respond within the timeout period

//wet socket
static const NSInteger WEB_SOCKET_NOT_FOUND= 1100; //< web socket not found by session id
static const NSInteger WEB_SOCKET_INVALID_SESSION= 1101; //< invalid session

// user
static const NSInteger INVALID_LENGTH_OF_USERID= 131072;
static const NSInteger INVALID_USERID= 131073;
static const NSInteger INVALID_USER_NAME= 131074;
static const NSInteger INVALID_LENGTH_OF_TITLE= 131075;
static const NSInteger INVALID_LENGTH_OF_PHONE_NUM= 131076;
static const NSInteger INVALID_PHONE= 131077;
static const NSInteger INVALID_LENGTH_OF_EMAIL= 131078;
static const NSInteger INVALID_EMAIL= 131079;
static const NSInteger INVALID_LENGTH_OF_PIN= 131080;
static const NSInteger INVALID_PIN= 131081;
static const NSInteger INVALID_LENGTH_OF_LOGINID= 131082;
static const NSInteger INVALID_LOGINID= 131083;
static const NSInteger INVALID_LENGTH_OF_PASSWORD= 131084;
static const NSInteger INVALID_EXPIRY_DATE= 131085;
static const NSInteger EXPIRY_DATE_IS_LT_START= 131086;
static const NSInteger INVALID_LENGTH_OF_MESSAGE= 131087;
static const NSInteger INVALID_COUNT_OF_FINGERPRINT= 131088;
static const NSInteger INVALID_COUNT_OF_FACETEMPLATE= 131089;
static const NSInteger OVER_MAX_ACCESS_GROUPS= 131090;
static const NSInteger INVALID_SECURITY_LEVEL= 131091;
static const NSInteger INVALID_DEVICE_STATUS= 131092;
static const NSInteger EXCEED_DESCRIPTION_MAX_LENGTH= 131093;
static const NSInteger EXCEED_NAME_MAX_LENGTH= 131094;
static const NSInteger CARD_ID_IS_REQUIRED= 131095;
static const NSInteger PARENT_DOOR_GROUP_IS_REQUIRED= 131096;
static const NSInteger DUPLICATE_USER_GROUP= 65646;
static const NSInteger PARENT_USER_GROUP_NOT_FOUND= 65647;
static const NSInteger PARENT_USER_GROUP_NOT_SET= 65648;
static const NSInteger USER_NOT_EXIST= 65649;
static const NSInteger ERR_NUM_CARD_ID_ALREADY_EXISTS= 65651;
static const NSInteger ERR_NUM_DOOR_NAME_ALREADY_EXISTS= 65652;
static const NSInteger ERR_NUM_DOOR_GROUP_NAME_ALREADY_EXISTS= 65653;
static const NSInteger ERR_NUM_DOOR_GROUP_NOT_FOUND= 65654;
static const NSInteger ERR_NUM_DEVICE_ALREADY_USED= 65655;
static const NSInteger ERR_NUM_RELAY_ALREADY_USED= 65656;
static const NSInteger ERR_NUM_DEVICE_NOT_IN_SAME_RS485= 65657;

@interface ErrorMessageCodeTable : NSObject

+ (NSString*)getMessage:(NSInteger)code;

@end
