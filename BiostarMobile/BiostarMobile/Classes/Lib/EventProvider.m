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
#import "EventProvider.h"

@implementation EventProvider

- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
        [network setDelegate:self];
    }
    
    return self;
}

- (void)getEventMessage
{
    if (nil == eventMessages)
    {
        eventMessages = [[NSMutableArray alloc] init];
    }
    
    requestType = REQUEST_GET_EVENT_MESSAGE;
    NSString* url = [NSString stringWithFormat:@"%@%@?limit=50&offset=0", [NetworkController sharedInstance].serverURL, API_EVENT_TYPES];
    [network requestURL:url withParam:nil method:GET];

}

+ (NSString*)getEventMessage:(NSInteger)eventTypeID
{
    NSString *description = nil;
    
    for (NSDictionary *dic in eventMessages)
    {
        //NSLog(@"%@",dic);
        if (eventTypeID == [[dic objectForKey:@"code"] integerValue])
        {
            description = [dic objectForKey:@"name"];
            break;
        }
    }
    
    return description;
}

+ (NSArray*)getEventCondition:(NSArray*)events
{
    return nil;
}

+ (NSArray*)getUserCondition:(NSArray*)users
{
    return nil;
}

+ (NSDictionary*)getDeviceCondition:(NSArray*)devices
{
    NSDictionary *deviceCondition = @{@"device_id" : devices};
    
    return deviceCondition;
}

- (NSMutableArray*)getEventMessages
{
    return eventMessages;
}


- (void)searchEventByUserID:(NSString*)userID
{
    
    requestType = REQUEST_SEARCH_EVENT;
    
    NSError *jsonError;
    NSData *jsonData;
    
    NSDictionary *order = @{@"column" : @"datetime",
                            @"descending" : [NSNumber numberWithBool:YES]};
    NSArray *orders = @[order];
    
    NSArray *values = @[userID];    // 컨디션에 들어갈 밸류
    NSDictionary *condition = @{@"column" : @"user_id.user_id",
                                @"values" : values,
                                @"total" : [NSNumber numberWithInteger:[values count]],
                                @"operator" : @"2"};
    
    NSArray *conditions = @[condition];
    
    
    NSDictionary *query = @{@"orders" : orders,
                            @"conditions" : conditions,
                            @"limit" : [NSNumber numberWithInt:100],
                            @"offset" : [NSNumber numberWithInt:0],
                            @"atLeastOneFilterExists" : [NSNumber numberWithBool:NO],
                            @"total" : [NSNumber numberWithInteger:[orders count]]};
    query = @{@"Query" : query};
    
    jsonData = [NSJSONSerialization dataWithJSONObject:query options:kNilOptions error:&jsonError];


    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_EVENTS_SEARCH];
    [network requestURL:url withParam:jsonString method:POST];

}

- (void)searchEvent:(NSDictionary*)conditions
{
    [self searchEvent:conditions offset:0 limit:INFINITY];
}

- (void)searchEvent:(NSDictionary*)condition offset:(NSInteger)offset limit:(NSInteger)limit
{
    requestType = REQUEST_SEARCH_EVENT;
    
    NSError *jsonError;
    NSData *jsonData;
    
    if (nil == condition)
    {
        NSDictionary *query = @{@"limit" : [NSNumber numberWithInteger:limit],
                                @"offset" : [NSNumber numberWithInteger:offset]};
        
        jsonData = [NSJSONSerialization dataWithJSONObject:query options:kNilOptions error:&jsonError];
    }
    else
    {
        NSMutableDictionary *query = [[NSMutableDictionary alloc] initWithDictionary:condition];
        [query setObject:[NSNumber numberWithInteger:limit] forKey:@"limit"];
        [query setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
        
        jsonData = [NSJSONSerialization dataWithJSONObject:query options:kNilOptions error:&jsonError];

    }
    
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_EVENTS_SEARCH];
    
    
    [network requestURL:url withParam:jsonString method:POST];
}



#pragma mark - BSNetworkDelegate

- (void)didFinishRequest:(NSDictionary*)resultDic
{
    switch (requestType)
    {
        case REQUEST_GET_EVENT_MESSAGE:
            [eventMessages removeAllObjects];
            [eventMessages addObjectsFromArray:[resultDic objectForKey:@"records"]];
            if ([self.delegate respondsToSelector:@selector(requestGetEventMessageDidFinish:)])
            {
                [self.delegate requestGetEventMessageDidFinish:[resultDic objectForKey:@"records"]];
            }
            break;
        case REQUEST_SEARCH_EVENT:
            if ([self.delegate respondsToSelector:@selector(requestSearchEventDidFinish:isNextPage:)])
            {
                [self.delegate requestSearchEventDidFinish:[resultDic objectForKey:@"records"] isNextPage:[[resultDic objectForKey:@"is_next"] boolValue]];
            }
            break;
        default:
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
        if ([self.delegate respondsToSelector:@selector(requestEventProviderDidFail:)])
        {
            [self.delegate requestEventProviderDidFail:errDic];
        }
        
    }
}

@end
