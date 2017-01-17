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

#ifndef BiostarMobile_Common_h
#define BiostarMobile_Common_h


#endif

#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MOVING_TO_ALARM                 @"MOVING_TO_ALARM"
#define USER_COUNT_UPDATE               @"USER_COUNT_UPDATE"
#define SCAN_QUALITY_CHANGE             @"SCAN_QUALITY_CHANGE"
#define DOOR_COUNT_UPDATE               @"DOOR_COUNT_UPDATE"
#define ALARM_COUNT_UPDATE              @"ALARM_COUNT_UPDATE"
#define PUSH_HAS_BEEN_OCCURED           @"PUSH_HAS_BEEN_OCCURED"
#define LOGGED_IN_USER_UPDATEED         @"LOGGED_IN_USER_UPDATEED"

#define QUALITY                         @"QUALITY"
#define APP_SEPARATION_VERSION          @"2.4.0"
#define ACVersion                       @"2.4.0"


#define LIST_POPUP_MINIMUM_HEIGHT 320      // 팝업 리스트뷰 최소 사이즈
#define LIST_SUB_POPUP_MINIMUM_HEIGHT 368      // 팝업 리스트뷰 최소 사이즈
#define NOT_SELECTED            10000
#define NETWORK_CONNETCTION_ERROR  @"NETWORK_CONNETCTION_ERROR"

#define MAX_IMAGE_FILE_SIZE         16000


// 권한 define
#define USER_PERMISSION                @"USER"
#define DOOR_PERMISSION                @"DOOR"
#define MONITORING_PERMISSION          @"MONITORING"
#define DEVICE_PERMISSION              @"DEVICE"



//typedef enum
//{
//    CSN_TYPE,
//    WIEGAND_TYPE,
//    SMART_CARD_TYPE,
//    CARD_READING_TYPE
//} CardAddType;

typedef enum{
    /*! When get all devices */
    ALL_DEVICES_MODE,
    /*! When get devices that support fingerprint */
    FINGERPRINT_MODE,
    /*! When get devices that support card */
    CARD_MODE,
    CSN_CARD_MODE,
    WIEGAND_CARD_MODE,
    SMART_CARD_MODE,
    MOBILE_CARD_MODE,
    READING_CARD_MODE,
} DeviceMode;


typedef enum
{
    NEW_CARD,
    ASSIGNMENT,
    INPUT,
} RegistrationType;


typedef enum{
    ASSIGN_CARD,                // 사용자 편집에서 assign card
    EXCHANGE_CARD,              // 사용자 편집에서 카드 변경
    
} ListPopupType;


// user detail mode
typedef enum{
    VIEW_MODE,
    MODIFY_MODE,
    CREATE_MODE,
    PROFILE_MODE,
} DetailType;

// user detail cell type
typedef enum{
    CELL_USER_ID,
    CELL_USER_NAME,
    CELL_USER_EMAIL,
    CELL_USER_TELEPHONE,
    CELL_USER_LOGIN_ID,
    CELL_USER_PASSWORD,
    CELL_USER_GROUP,
    CELL_USER_ACCESS_GROUP,
} CellType;
