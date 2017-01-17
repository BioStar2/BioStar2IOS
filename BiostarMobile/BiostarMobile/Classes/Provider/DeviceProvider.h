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
#import "ObjectMapper.h"
#import "InCodeMappingProvider.h"
#import "SearchDeviceListResult.h"
#import "FingerprintScanResult.h"
#import "VerifyFingerprintOption.h"
#import "VerifyFingerprintResult.h"
#import "CardSearchResult.h"
#import "PreferenceProvider.h"
#import "Common.h"
/**
 *
 *  @brief DeviceProvider handle device and card API
 */

@interface DeviceProvider : NSObject 
{
    BSNetwork *network;
    ObjectMapper *mapper;
    InCodeMappingProvider *mappingProvider;
}



/**
 *  @brief DeviceMode enum
 */
@property (nonatomic, assign) DeviceMode mode;

/**
 * SearchDeviceCompleteBolck
 *
 * This block method will be returned when network request finish
 *
 * @param result            API result object
 * @param responseArray     API result object that device array
 *
 */
typedef void(^SearchDeviceCompleteBolck)(SearchDeviceListResult *result, NSArray *responseArray);


/**
 * DeviceCompleteBolck
 *
 * This block method will be returned when network request finish
 *
 * @param responseObject    API result object
 * @param responseArray     API result object that device array
 * @param error             API error object
 *
 */
typedef void(^DeviceCompleteBolck)(SearchResultDevice *device);



/**
 * FingerprintScanBolck
 *
 * This block method will be returned when network request finish
 *
 * @param FingerprintScanResult    API result object
 *
 */
typedef void(^FingerprintScanBolck)(FingerprintScanResult *result);
typedef void(^FingerprintVerifyBolck)(VerifyFingerprintResult *result);
typedef void(^CardScanBolck)(Card *scanCard);

/**
 *  Get devices
 *
 *  @param query        Search string
 *  @param limit        device limit
 *  @param offset       device offset
 *  @param deviceMode   ALL_DEVICES_MODE, FINGERPRINT_MODE, CARD_MODE
 *  @param handler      DeviceCompleteBolck
 */

- (void)getDevices:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset mode:(DeviceMode)deviceMode deviceBlock:(SearchDeviceCompleteBolck)deviceBlock onError:(ErrorBlock)errorBlock;


/**
 *  Get a device
 *
 *  @param deviceID     a device ID
 *  @param handler      NetworkCompleteBolck
 */

- (void)getDevice:(NSString*)deviceID deviceBlock:(DeviceCompleteBolck)deviceBlock onError:(ErrorBlock)errorBlock;


/**
 *  Scan fingerprint by Device
 *
 *  @param deviceID         Device's id
 *  @param quality          Scan quality
 *  @param scanBlock        FingerprintScanBolck
 *  @param errorBlock       ErrorBlock
 *  @note When you use the method, the device will wait your's fingerprint input.
 */
- (void)scanFingerprint:(NSString*)deviceID quality:(NSUInteger)quality scanBlock:(FingerprintScanBolck)scanBlock onError:(ErrorBlock)errorBlock;

/**
 *  Verify fingerprint by Device
 *
 *  @param deviceID             Device's id
 *  @param firstTemplate        1st Fingerprint template
 *  @param secondTemplate       2nd Fingerprint template
 *  @param handler              NetworkCompleteBolck
 *
 *  @note To use this method you have to have two fingerprint template by using "- (void)scanFingerprint:(NSString*)deviceID completeHandler:(NetworkCompleteBolck)handler;" twice
 *
 */

- (void)verifyFingerprint:(NSString*)deviceID firstTemplate:(NSString*)firstTemplate secondTemplate:(NSString*)secondTemplate verifyBlock:(FingerprintVerifyBolck)verifyBlock onError:(ErrorBlock)errorBlock;

/**
 *  Scan Card by Device
 *
 *  @param deviceID             Device's id
 *  @param handler              NetworkCompleteBolck
 *
 *  @note When you use the method, the device will wait your's card input.
 *
 */

- (void)scanCard:(NSString*)deviceID scanBlock:(CardScanBolck)scanBlock onError:(ErrorBlock)errorBlock;


@end
