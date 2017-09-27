//
//  NSString+EnumParser.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 17..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EnumParser)

typedef NS_ENUM(NSInteger, CardType) {
    CSN                     = 0,
    WIEGAND                 = 1,
    CSN_WIEGAND             = 2,
    SECURE_CREDENTIAL       = 3,
    ACCESS_ON               = 4
};

- (CardType)cardTypeEnumFromString;
+ (NSString*)cardTypeStringFromEnum:(CardType)type;

typedef NS_ENUM(NSInteger, NotificationType) {
    DOOR_OPEN_REQUEST           = 0,
    DOOR_FORCED_OPEN            = 1,
    DOOR_HELD_OPEN              = 2,
    DEVICE_TAMPERING            = 3,
    DEVICE_REBOOT               = 4,
    DEVICE_RS485_DISCONNECT     = 5,
    ZONE_APB                    = 6,
    ZONE_FIRE                   = 7
};

- (NotificationType)notificationTypeEnumFromString;

typedef NS_ENUM(NSInteger, EventLevel) {
    GREEN               = 0,
    YELLOW              = 1,
    RED                 = 2
};

- (EventLevel)eventLevelEnumFromString;


typedef NS_ENUM(NSInteger, LogType) {
    DEVICE                  = 0,
    DOOR                    = 1,
    USER                    = 2,
    ZONE                    = 3,
    AUTHENTICATION          = 4
};

- (LogType)logTypeEnumFromString;


typedef NS_ENUM(NSInteger, BLEStatus) {
    BROADCAST_BLE_SUCESS                  = 0,
    BROADCAST_BLE_ERROR_CONNECT           = 1,
    BROADCAST_BLE_ERROR_DATA              = 2,
    BROADCAST_BLE_CONNECT                 = 3,
    BROADCAST_NONE                        = 4
};

- (BLEStatus)BLEStatusTypeEnumFromString;
+ (NSString*)BLEStatusTypeStringFromEnum:(BLEStatus)type;

typedef NS_ENUM(NSInteger, BLEConnectionStatus) {
    READY_TO_SCAN                         = 0,
    SCANNING,
    TRYING_TO_SCAN,
    CONNECTING,
    CONNECTED,
    FAIL_TO_CONNECT,
    DISCONNECTED,
    DISCONNECTED_WITH_ERROR,
    STATUS_NONE,
    SUCCESS_TRANSACTION,
    FAILED_TRANSACTION,
    POWER_OFF
};

- (BLEConnectionStatus)BLEConnectionStatusTypeEnumFromString;
+ (NSString*)BLEConnectionStatusTypeStringFromEnum:(BLEConnectionStatus)type;


@end


