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

#import "DoorProvider.h"

@implementation DoorProvider

- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
        [network setDelegate:self];
    }
    
    return self;
}

+ (NSArray*)getDoors
{
    return doors;
}

- (NSString*)getDoorRequestBody:(NSInteger)doorID
{
    NSDictionary *door = @{@"id" : [NSNumber numberWithInteger:doorID], @"status" : [NSNumber numberWithInteger:0]};
    NSArray *doors = @[door];
    
    NSDictionary *doorsDic = @{@"rows" : doors, @"total" : [NSNumber numberWithInteger:doors.count]};
    NSDictionary *doorCollection = @{@"DoorCollection" : doorsDic};
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:doorCollection options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

- (void)searchDoors:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset
{
    _requestType = SEARCH_DOORS;
    if (nil == query)
    {
        query = @"";
    }
    NSString* url = [NSString stringWithFormat:@"%@%@?text=%@&limit=%ld&offset=%ld", [NetworkController sharedInstance].serverURL, API_DOORS, query, (long)limit, (long)offset];
    
    [network requestURL:url withParam:nil method:GET];
}

- (void)getDoors
{
    _requestType = GET_DOORS;
    
    NSString* url = [NSString stringWithFormat:@"%@%@?limit=100&offset=0", [NetworkController sharedInstance].serverURL, API_DOORS];
    [network requestURL:url withParam:nil method:GET];
    
}

- (void)getDoor:(NSInteger)doorID
{
    _requestType = GET_DOOR;
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%ld", [NetworkController sharedInstance].serverURL, API_DOORS, (long)doorID];
    [network requestURL:url withParam:nil method:GET];
}

- (void)openDoor:(NSInteger)doorID
{
    _requestType = OPEN_DOOR;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_OPEN, (long)doorID]];
    
    NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    [network requestURL:url withParam:jsonStringParam method:POST];
}

- (void)lockDoor:(NSInteger)doorID
{
    _requestType = LOCK_DOOR;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_LOCK, (long)doorID]];
    
    NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    [network requestURL:url withParam:jsonStringParam method:POST];
}

- (void)unlockDoor:(NSInteger)doorID;
{
    _requestType = UNLOCK_DOOR;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_UNLOCK, (long)doorID]];
    
    NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    [network requestURL:url withParam:jsonStringParam method:POST];
}

- (void)releaseDoor:(NSInteger)doorID;
{
    _requestType = RELEASE_DOOR;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_RELEASE, (long)doorID]];
    
    NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    [network requestURL:url withParam:jsonStringParam method:POST];
}

- (void)clearAlarm:(NSInteger)doorID;
{
    _requestType = CLEAR_ALARM_DOOR;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_CLEAR_ALARM, (long)doorID]];
    
    NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    [network requestURL:url withParam:jsonStringParam method:POST];
}

- (void)clearAntiPassback:(NSInteger)doorID;
{
    _requestType = CLEAR_ANTI_PASS_BACK_DOOR;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_CLEAR_APB, (long)doorID]];
    
    NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    [network requestURL:url withParam:jsonStringParam method:POST];
}

- (void)reqeustOpen:(NSInteger)doorID phoneNumber:(NSString*)phoneNumber
{
    _requestType = REQUEST_OPEN_DOOR;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_REQUEST_OPEN, (long)doorID]];
    
    NSDictionary *body;
    if (nil == phoneNumber)
    {
        body = @{@"phone_number" : @""};
    }
    else
    {
        body = @{@"phone_number" : phoneNumber};
    }
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [network requestURL:url withParam:jsonString method:POST];
}

#pragma mark - BSNetwork delegate


- (void)didFinishRequest:(NSDictionary*)resultDic
{
    switch (_requestType)
    {
        case GET_DOORS:
            
            if ([self.delegate respondsToSelector:@selector(requestGetDoorsDidFinish:totalCount:)])
            {
                if (nil == doors)
                {
                    doors = [[NSMutableArray alloc] init];
                }
                
                [doors removeAllObjects];
                [doors addObjectsFromArray:[resultDic objectForKey:@"records"]];
                
                [self.delegate requestGetDoorsDidFinish:[resultDic objectForKey:@"records"] totalCount:[[resultDic objectForKey:@"total"] integerValue]];
            }
            break;
            
        case GET_DOOR:
            if ([self.delegate respondsToSelector:@selector(requestGetDoorDidFinish:)])
            {
                [self.delegate requestGetDoorDidFinish:resultDic];
            }
            break;
            
        case OPEN_DOOR:
            if ([self.delegate respondsToSelector:@selector(requestOpenDoorDidFinish:)])
            {
                [self.delegate requestOpenDoorDidFinish:resultDic];
            }
            break;
            
        case LOCK_DOOR:
            if ([self.delegate respondsToSelector:@selector(requestLockDoorDidFinish:)])
            {
                [self.delegate requestLockDoorDidFinish:resultDic];
            }
            break;
            
        case UNLOCK_DOOR:
            if ([self.delegate respondsToSelector:@selector(requestUnlockDoorDidFinish:)])
            {
                [self.delegate requestUnlockDoorDidFinish:resultDic];
            }
            break;
            
        case RELEASE_DOOR:
            if ([self.delegate respondsToSelector:@selector(requestReleaseDoorDidFinish:)])
            {
                [self.delegate requestReleaseDoorDidFinish:resultDic];
            }
            break;
            
        case CLEAR_ALARM_DOOR:
            if ([self.delegate respondsToSelector:@selector(requestClearArarmDidFinish:)])
            {
                [self.delegate requestClearArarmDidFinish:resultDic];
            }
            break;
            
        case CLEAR_ANTI_PASS_BACK_DOOR:
            if ([self.delegate respondsToSelector:@selector(requestClearAntiPassBackDidFinish:)])
            {
                [self.delegate requestClearAntiPassBackDidFinish:resultDic];
            }
            break;
        case SEARCH_DOORS:
            if ([self.delegate respondsToSelector:@selector(requestGetDoorsDidFinish:totalCount:)])
            {
                [self.delegate requestGetDoorsDidFinish:[resultDic objectForKey:@"records"] totalCount:[[resultDic objectForKey:@"total"] integerValue]];
            }
            break;
        case REQUEST_OPEN_DOOR:
            if ([self.delegate respondsToSelector:@selector(requestAskOpenDoorDidFinish:)])
            {
                [self.delegate requestAskOpenDoorDidFinish:resultDic];
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
        [self.delegate requestDoorProviderDidFail:errDic];
    }
}
@end
