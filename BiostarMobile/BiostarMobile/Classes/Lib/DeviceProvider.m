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

@synthesize delegate;

- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
    }
    
    return self;
}

- (void)getDevices:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset
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
    
    [network setDelegate:self];
    type = REQUEST_GET_DEVICES;
    
    mode = ALL_DEVICES;
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", [NetworkController sharedInstance].serverURL, API_DEVICES, subURL];
    [network requestURL:url withParam:nil method:GET];
}

- (void)getDevices:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset mode:(DeviceMode)deviceMode
{
    [self getDevices:query limit:limit offset:offset];
    mode = deviceMode;
}

- (void)getDevice:(NSString*)deviceID
{
    [network setDelegate:self];
    type = REQUEST_GET_DEVICE;
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_DEVICES, deviceID];
    [network requestURL:url withParam:nil method:GET];
}

// cloud 에서 변경되어서 안씀 지워도 되는 메소드
- (void)getCardsWithGroupID:(NSString*)groupID limit:(NSInteger)limit offset:(NSInteger)offset
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:groupID forKey:@"group_id"];
    [param setObject:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    [param setObject:@"false" forKey:@"nextEnabled"];
    [param setObject:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    [param setObject:@"false" forKey:@"previousEnabled"];
    
    
    NSArray *allKeys = [param allKeys];
    NSMutableString *subURL = [[NSMutableString alloc] initWithString:@""];
    for (NSString *key in allKeys)
    {
        [subURL appendString:[NSString stringWithFormat:@"%@=%@&", key, [param objectForKey:key]]];
    }
    [subURL setString:[subURL substringToIndex:subURL.length -1]];
    
    
    [network setDelegate:self];
    type = REQUEST_GET_CARDS;
    
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", [NetworkController sharedInstance].serverURL, API_CARDS, subURL];
    [network requestURL:url withParam:nil method:GET];
}

- (void)getCards:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (nil != query)
        [param setObject:query forKey:@"text"];
    
    [param setObject:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    [param setObject:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    
    NSArray *allKeys = [param allKeys];
    NSMutableString *subURL = [[NSMutableString alloc] initWithString:@""];
    for (NSString *key in allKeys)
    {
        [subURL appendString:[NSString stringWithFormat:@"%@=%@&", key, [param objectForKey:key]]];
    }
    [subURL setString:[subURL substringToIndex:subURL.length -1]];
    
    
    [network setDelegate:self];
    type = REQUEST_GET_CARDS;
    
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", [NetworkController sharedInstance].serverURL, API_CARDS, subURL];
    [network requestURL:url withParam:nil method:GET];
}


- (void)getCard:(NSInteger)cardID
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"0" forKey:@"group_id"];
    [param setObject:[NSString stringWithFormat:@"%d", 100] forKey:@"limit"];
    [param setObject:@"false" forKey:@"nextEnabled"];
    [param setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"offset"];
    [param setObject:@"false" forKey:@"previousEnabled"];
    [param setObject:[NSNumber numberWithInteger:cardID] forKey:@"query"];
    
    NSArray *allKeys = [param allKeys];
    NSMutableString *subURL = [[NSMutableString alloc] initWithString:@""];
    for (NSString *key in allKeys)
    {
        [subURL appendString:[NSString stringWithFormat:@"%@=%@&", key, [param objectForKey:key]]];
    }
    [subURL setString:[subURL substringToIndex:subURL.length -1]];
    
    
    [network setDelegate:self];
    type = REQUEST_GET_CARDS;
    
    NSString* url = [NSString stringWithFormat:@"%@%@?%@", [NetworkController sharedInstance].serverURL, API_CARDS, subURL];
    [network requestURL:url withParam:nil method:GET];
}

- (void)scanFingerprint:(NSString*)deviceID
{
    [network setDelegate:self];
    type = REQUEST_SCAN_FINGERPRINT;
    
    NSDictionary *param = @{@"enroll_quality" : [NSNumber numberWithInteger:40],
                            @"retrieve_raw_image" : [NSNumber numberWithBool:YES]};
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@%@", [NetworkController sharedInstance].serverURL, API_DEVICES, deviceID, API_DEVICE_SCAN_FINGERPRINT];
    [network requestURL:url withParam:jsonString method:POST];
}

- (void)verifyFingerprint:(NSString*)deviceID firstTemplate:(NSDictionary*)firstTemplate secondTemplate:(NSDictionary*)secondTemplate
{
    [network setDelegate:self];
    type = REQUEST_VERIFY_FINGERPRINT;
    
    
    NSDictionary *param = @{@"security_level" : @"DEFAULT",
                            @"template0" : firstTemplate,
                            @"template1" : secondTemplate};
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@%@", [NetworkController sharedInstance].serverURL, API_DEVICES, deviceID, API_DEVICE_VERIFY_FINGERPRINT];
    [network requestURL:url withParam:jsonString method:POST];
}

- (void)scanCard:(NSString*)deviceID
{
    [network setDelegate:self];
    type = REQUEST_SCAN_CARD;
    
    NSDictionary *param = @{@"device_id" : deviceID};
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@%@", [NetworkController sharedInstance].serverURL, API_DEVICES, deviceID, API_DEVICE_SCAN_CARD];
    [network requestURL:url withParam:jsonString method:POST];
}

- (void)registerCard:(NSDictionary*)cardInfo
{
    [network setDelegate:self];
    type = REQUEST_REGISTER_CARD;
    
    NSArray *cards = @[cardInfo];
    NSDictionary *param = @{@"rows" : cards, @"total" : [NSNumber numberWithInteger:cards.count]};
    param = @{@"CardCollection" : param};
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:param options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_CARDS];
    [network requestURL:url withParam:jsonString method:POST];
}

#pragma mark - BSNetwork delegate


- (void)didFinishRequest:(NSDictionary*)resultDic
{
    if (nil != [resultDic objectForKey:@"DeviceResponse"])
    {
        if (![[[resultDic objectForKey:@"DeviceResponse"] objectForKey:@"result"] boolValue])
        {
            NSMutableDictionary *errDic = [[NSMutableDictionary alloc] init];
            [errDic setObject:@"Time out" forKey:@"message"];
            [self.delegate requestDeviceProviderDidFail:errDic];
            return;
        }
    }
    
    switch (type)
    {
        case REQUEST_GET_DEVICES:
        {
            NSMutableArray *deviceCollections = [[NSMutableArray alloc] init];
            NSArray *records = [resultDic objectForKey:@"records"];
            switch (mode)
            {
                case ALL_DEVICES:
                    [deviceCollections addObjectsFromArray:[resultDic objectForKey:@"records"]];
                    break;
                case FINGERPRINT_MODE:
                    
                    if ([records isKindOfClass:[NSArray class]])
                    {
                        for (NSDictionary *device in [resultDic objectForKey:@"records"])
                        {
                            if ([device objectForKey:@"device_type"])
                            {
                                if ([[[device objectForKey:@"device_type"] objectForKey:@"scan_fingerprint"] boolValue] &&
                                    ![[device objectForKey:@"mode"] isEqualToString:@"CHILD"])
                                {
                                    [deviceCollections addObject:device];
                                }
                            }
                        }
                    }
                    
                    break;
                case CARD_MODE:
                    if ([records isKindOfClass:[NSArray class]])
                    {
                        for (NSDictionary *device in [resultDic objectForKey:@"records"])
                        {
                            if ([device objectForKey:@"device_type"])
                            {
                                if ([[[device objectForKey:@"device_type"] objectForKey:@"scan_card"] boolValue])
                                {
                                    [deviceCollections addObject:device];
                                }
                            }
                        }
                    }
                    break;
                
            }
            if ([self.delegate respondsToSelector:@selector(requestGetDevicesDidFinish:totalCount:)])
            {
                [self.delegate requestGetDevicesDidFinish:deviceCollections totalCount:deviceCollections.count];
            }
        }
            break;

        case REQUEST_SCAN_FINGERPRINT:
            if ([self.delegate respondsToSelector:@selector(requestScanFingerprintDidFinish:)])
            {
                [self.delegate requestScanFingerprintDidFinish:resultDic];
            }
            break;
        case REQUEST_SCAN_CARD:
            if ([self.delegate respondsToSelector:@selector(requestScanCardDidFinish:)])
            {
                [self.delegate requestScanCardDidFinish:resultDic];
            }
            break;
        case REQUEST_REGISTER_CARD:
            if ([self.delegate respondsToSelector:@selector(requestRegisterCardDidFinish:)])
            {
                [self.delegate requestRegisterCardDidFinish:[[[resultDic objectForKey:@"CardCollection"] objectForKey:@"rows"] objectAtIndex:0]];
            }
            break;
        case REQUEST_GET_CARDS:
            if ([self.delegate respondsToSelector:@selector(requestGetCardsDidFinish:)])
            {
                [self.delegate requestGetCardsDidFinish:resultDic];
            }
            break;
        case REQUEST_VERIFY_FINGERPRINT:
            if ([self.delegate respondsToSelector:@selector(requestVerifyFingerprint:)])
            {
                [self.delegate requestVerifyFingerprint:resultDic];
            }
        case REQUEST_GET_DEVICE:
            if ([self.delegate respondsToSelector:@selector(requestGetDeviceDidFinish:)])
            {
                [self.delegate requestGetDeviceDidFinish:resultDic];
            }
            break;
    }
    
    
}

- (void)didFailRequest:(NSDictionary*)errDic
{
    NSInteger code = [[errDic objectForKey:@"responseCode"] integerValue];
    
    if (code == 401)
    {
        // 세션 만료
        if ([self.delegate respondsToSelector:@selector(cookieWasExpired:)])
        {
            [self.delegate cookieWasExpired:errDic];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(requestDeviceProviderDidFail:)])
        {
            [self.delegate requestDeviceProviderDidFail:errDic];
        }
        
    }
}

@end
