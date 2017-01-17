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

#import "DeviceProvider.h"

@implementation DeviceProvider


- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
        mappingProvider = [[InCodeMappingProvider alloc] init];
        mapper = [[ObjectMapper alloc] init];
        mapper.mappingProvider = mappingProvider;
    }
    
    return self;
}

- (void)getDevices:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset mode:(DeviceMode)deviceMode deviceBlock:(SearchDeviceCompleteBolck)deviceBlock onError:(ErrorBlock)errorBlock
{
    NSDictionary *param;
    if (nil == query)
    {
        param = @{@"limit" : [NSNumber numberWithInteger:limit],
                  @"offset" : [NSNumber numberWithInteger:offset]};
    }
    else
    {
        param = @{@"text" : query,
                  @"limit" : [NSNumber numberWithInteger:limit],
                  @"offset" : [NSNumber numberWithInteger:offset]};
    }
    
    NSArray *allKeys = [param allKeys];
    NSMutableString *subURL = [[NSMutableString alloc] initWithString:@""];
    for (NSString *key in allKeys)
    {
        [subURL appendString:[NSString stringWithFormat:@"%@=%@&", key, [param objectForKey:key]]];
    }
    [subURL setString:[subURL substringToIndex:subURL.length -1]];
    
    
    self.mode = deviceMode;
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", [NetworkController sharedInstance].serverURL, API_DEVICES, subURL];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"wiegand_card_id_list" toPropertyKey:@"wiegand_card_id_list" withObjectType:[WiegandCardIDList class] forClass:[WiegandFormat class]];
            
            [mappingProvider mapFromDictionaryKey:@"wiegand_format_list" toPropertyKey:@"wiegand_format_list" withObjectType:[WiegandFormat class] forClass:[SearchResultDevice class]];
            
            [mappingProvider mapFromDictionaryKey:@"children" toPropertyKey:@"children" withObjectType:[ChildDevice class] forClass:[SearchResultDevice class]];
            
            [mappingProvider mapFromDictionaryKey:@"used_by_doors" toPropertyKey:@"used_by_doors" withObjectType:[SimpleModel class] forClass:[SearchResultDevice class]];

            
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[SearchResultDevice class] forClass:[SearchDeviceListResult class]];
            
            SearchDeviceListResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[SearchDeviceListResult class]];
            
            NSMutableArray <SearchResultDevice*> *deviceCollections = [[NSMutableArray alloc] init];
            
            switch (self.mode)
            {
#warning 2.4.1 에서 ALL_DEVICES_MODE 어디에서 사용하는지 확인 필요
#warning 2.4.1 에서 READING_CARD_MODE 에서는 카드 device.device_type.scan_card true 인 장치만 추가해서 보여주게 수정해야 함
                case ALL_DEVICES_MODE:
                case READING_CARD_MODE:
                    [deviceCollections addObjectsFromArray:result.records];
                    break;
                case FINGERPRINT_MODE:
                    
                    for (SearchResultDevice *device in result.records)
                    {
                        if ([PreferenceProvider isUpperVersion])
                        {
                            if(device.device_type.scan_fingerprint && [device.rs485 typeEnumFromString] != SLAVE)
                            {
                                [deviceCollections addObject:device];
                            }
                        }
                        else
                        {
                            if(device.device_type.scan_fingerprint && ![device.mode isEqualToString:@"CHILD"])
                            {
                                [deviceCollections addObject:device];
                            }
                        }
                        
                    }
                    break;
                case CARD_MODE:
                    for (SearchResultDevice *device in result.records)
                    {
                        if(device.device_type.scan_card)
                        {
                            [deviceCollections addObject:device];
                        }
                    }
                    break;

                case CSN_CARD_MODE:
                    for (SearchResultDevice *device in result.records)
                    {
                        if(device.device_type.scan_card)
                        {
                            if (!device.csn_wiegand_format)
                            {
                                [deviceCollections addObject:device];
                            }
                        }
                        
//                        if(!device.csn_wiegand_format && device.wiegand_format_list.count == 0)
//                        {
//                            [deviceCollections addObject:device];
//                        }
                    }
                    break;
                    
                case WIEGAND_CARD_MODE:
                    for (SearchResultDevice *device in result.records)
                    {
                        if(device.csn_wiegand_format || device.wiegand_format_list.count != 0)
                        {
                            [deviceCollections addObject:device];
                        }
                    }
                    break;
                    
                case SMART_CARD_MODE:
                    for (SearchResultDevice *device in result.records)
                    {
                        if(device.smart_card_layout)
                        {
                            [deviceCollections addObject:device];
                        }
                    }
                    break;
                default:
                    break;
                    
            }
            deviceBlock(result, deviceCollections);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
}

- (void)getDevice:(NSString*)deviceID deviceBlock:(DeviceCompleteBolck)deviceBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_DEVICES, deviceID];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"children" toPropertyKey:@"children" withObjectType:[ChildDevice class] forClass:[SearchResultDevice class]];
            
            [mappingProvider mapFromDictionaryKey:@"used_by_doors" toPropertyKey:@"used_by_doors" withObjectType:[SimpleModel class] forClass:[SearchResultDevice class]];
            
            
            SearchResultDevice *result = [mapper objectFromSource:responseObject toInstanceOfClass:[SearchResultDevice class]];
            
            deviceBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
}




- (void)scanFingerprint:(NSString*)deviceID quality:(NSUInteger)quality scanBlock:(FingerprintScanBolck)scanBlock onError:(ErrorBlock)errorBlock
{
    
    NSDictionary *param = @{@"enroll_quality" : [NSNumber numberWithUnsignedInteger:quality],
                            @"retrieve_raw_image" : [NSNumber numberWithBool:YES]};
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@%@", [NetworkController sharedInstance].serverURL, API_DEVICES, deviceID, API_DEVICE_SCAN_FINGERPRINT];
    
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil ==error)
        {
            FingerprintScanResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[FingerprintScanResult class]];
            scanBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
    
}

- (void)verifyFingerprint:(NSString*)deviceID firstTemplate:(NSString*)firstTemplate secondTemplate:(NSString*)secondTemplate verifyBlock:(FingerprintVerifyBolck)verifyBlock onError:(ErrorBlock)errorBlock
{
    VerifyFingerprintOption *option = [VerifyFingerprintOption new];
    option.security_level = @"DEFAULT";
    option.template0 = firstTemplate;
    option.template1 = secondTemplate;
    
    NSDictionary *param = [mapper dictionaryFromObject:option];
                         
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@%@", [NetworkController sharedInstance].serverURL, API_DEVICES, deviceID, API_DEVICE_VERIFY_FINGERPRINT];
    
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil ==error)
        {
            VerifyFingerprintResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[VerifyFingerprintResult class]];
            
            verifyBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
    
}

- (void)scanCard:(NSString*)deviceID scanBlock:(CardScanBolck)scanBlock onError:(ErrorBlock)errorBlock
{
    
    NSDictionary *param = @{@"device_id" : deviceID};
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@%@", [NetworkController sharedInstance].serverURL, API_DEVICES, deviceID, API_DEVICE_SCAN_CARD];
    
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        if (nil ==error)
        {
            
            [mappingProvider mapFromDictionaryKey:@"wiegand_card_id_list" toPropertyKey:@"wiegand_card_id_list" withObjectType:[WiegandCardIDList class] forClass:[WiegandFormat class]];
            
            [mappingProvider mapFromDictionaryKey:@"fingerprint_templates" toPropertyKey:@"fingerprint_templates" withObjectType:[FingerprintTemplate class] forClass:[Card class]];
            
            
            Card *result = [mapper objectFromSource:responseObject toInstanceOfClass:[Card class]];
            
            scanBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}



@end
