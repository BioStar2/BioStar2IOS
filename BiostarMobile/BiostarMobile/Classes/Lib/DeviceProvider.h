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
#import "BSNetwork.h"

typedef enum{
    REQUEST_GET_DEVICE,
    REQUEST_GET_DEVICES,
    REQUEST_SCAN_FINGERPRINT,
    REQUEST_VERIFY_FINGERPRINT,
    REQUEST_SCAN_CARD,
    REQUEST_REGISTER_CARD,
    REQUEST_GET_CARDS,
    
} DeviceRequestType;

typedef enum{
    ALL_DEVICES,
    FINGERPRINT_MODE,
    CARD_MODE,
} DeviceMode;

@protocol DeviceProviderDelegate <NSObject>

@optional

- (void)requestGetDevicesDidFinish:(NSArray*)devices totalCount:(NSInteger)total;
- (void)requestGetDeviceDidFinish:(NSDictionary*)dic;
- (void)requestScanFingerprintDidFinish:(NSDictionary*)dic;
- (void)requestVerifyFingerprint:(NSDictionary*)dic;
- (void)requestScanCardDidFinish:(NSDictionary*)dic;
- (void)requestRegisterCardDidFinish:(NSDictionary*)dic;
- (void)requestGetCardsDidFinish:(NSDictionary *)cardColletion;

- (void)requestDeviceProviderDidFail:(NSDictionary*)errDic;

- (void)cookieWasExpired:(NSDictionary*)errDic;

@end

@interface DeviceProvider : NSObject <BSNetworkDelegate>
{
    BSNetwork *network;
    DeviceRequestType type;
    DeviceMode mode;
}

@property(assign, nonatomic) id <DeviceProviderDelegate>delegate;

- (void)getDevices:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset;
- (void)getDevices:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset mode:(DeviceMode)deviceMode;
- (void)getDevice:(NSString*)deviceID;
- (void)scanFingerprint:(NSString*)deviceID;
- (void)verifyFingerprint:(NSString*)deviceID firstTemplate:(NSDictionary*)firstTemplate secondTemplate:(NSDictionary*)secondTemplate;
- (void)scanCard:(NSString*)deviceID;
- (void)registerCard:(NSDictionary*)cardInfo;
- (void)getCardsWithGroupID:(NSString*)groupID limit:(NSInteger)limit offset:(NSInteger)offset;
- (void)getCards:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset;
- (void)getCard:(NSInteger)cardID;
@end
