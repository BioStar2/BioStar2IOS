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

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define MOVING_TO_ALARM         @"MOVING_TO_ALARM"
#define USER_COUNT_UPDATE       @"USER_COUNT_UPDATE"
#define DOOR_COUNT_UPDATE       @"DOOR_COUNT_UPDATE"
#define ALARM_COUNT_UPDATE      @"ALARM_COUNT_UPDATE"
#define PUSH_HAS_BEEN_OCCURED   @"PUSH_HAS_BEEN_OCCURED"

#define LIST_POPUP_MINIMUM_HEIGHT 320      // 팝업 리스트뷰 최소 사이즈
#define LIST_SUB_POPUP_MINIMUM_HEIGHT 368      // 팝업 리스트뷰 최소 사이즈
#define NOT_SELECTED            10000
#define NETWORK_CONNETCTION_ERROR  @"NETWORK_CONNETCTION_ERROR"

#define MAX_IMAGE_FILE_SIZE         16000

typedef enum{
    USER_GROUP,                 // 사용자 편집에서 유저그룹 사용할때
    PERMISSON,                  // 사용자 편집에서 퍼비션
    DEVICE_FINGERPRINT,         // 사용자 편집에서 지문 스캔
    DEVICE_CARD,                // 사용자 편집에서 카드 스캔
    CARD_OPTION,                // 사용자 편집에서 카드 선택 옵션
    ASSIGN_CARD,                // 사용자 편집에서 assign card
    EXCHANGE_CARD,              // 사용자 편집에서 카드 변경
    EXCHANGE_ACCESS_GROUP,      // 사용자 편집에서 액세스 그룹 변경
    ADD_ACCESS_GROUP,           // 사용자 편집에서 액세스 그룹 추가
    PEROID,                     // 사용자 편집에서 시작 만료 시간
    EVENT_SELECT,               // 모니터링 필터에서 이벤트 선택
    USER_SELECT,                // 모니터링 필터에서 사용자 선택
    DEVICE_SELECT,              // 모니터링 필터에서 디바이스 선택
    DOOR_CONTROL,               // 도어 컨트롤
    TIME_ZONE,                  // 셋팅 타임존
    TIME_FORMAT,                // 셋팅 타임 포맷
    DATE_FORMAT,                // 셋팅 데이트 포맷
    
} ListType;

typedef enum{
    DOOR_OPEN_REQUEST,
    DOOR_FORCED_OPEN,
    DOOR_HELD_OPEN,
    DEVICE_TAMPERING,
    DEVICE_REBOOT,
    DEVICE_RS485_DISCONNECT,
    ZONE_APB,
    ZONE_FIRE,
    
} AlarmType;

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