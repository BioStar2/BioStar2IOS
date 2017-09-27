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

@interface DoorProvider()

@end

@implementation DoorProvider

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

#warning error test 사용해도 되고 안해도 됨 현재 swagger 에서는 사용하지 않음 optional
//- (NSString*)getDoorRequestBody:(NSInteger)doorID
//{
//    NSDictionary *door = @{@"id" : [NSNumber numberWithInteger:doorID], @"status" : [NSNumber numberWithInteger:0]};
//    NSArray *doors = @[door];
//    
//    NSDictionary *doorsDic = @{@"rows" : doors, @"total" : [NSNumber numberWithInteger:doors.count]};
//    NSDictionary *doorCollection = @{@"DoorCollection" : doorsDic};
//    
//    NSError *jsonError;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:doorCollection options:kNilOptions error:&jsonError];
//    
//    if (nil != jsonError)
//    {
//        jsonParsingError = [jsonError copy];
//    }
//    else
//        jsonParsingError = nil;
//    
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    
//    return jsonString;
//}

- (void)searchDoors:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset completeBlock:(DoorsCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock
{
    if (nil == query)
    {
        query = @"";
    }
    NSString* url = [NSString stringWithFormat:@"%@%@?text=%@&limit=%ld&offset=%ld", [NetworkController sharedInstance].serverURL, API_DOORS, query, (long)limit, (long)offset];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"door_description" forClass:[ListDoorItem class]];
            
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[ListDoorItem class] forClass:[GetDoorList class]];
            
            GetDoorList *result = [mapper objectFromSource:responseObject toInstanceOfClass:[GetDoorList class]];
            
            completeBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
    
}


- (void)getDoor:(NSInteger)doorID completeBlock:(DoorCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%ld", [NetworkController sharedInstance].serverURL, API_DOORS, (long)doorID];
    
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"door_description" forClass:[ListDoorItem class]];
            
            ListDoorItem *result = [mapper objectFromSource:responseObject toInstanceOfClass:[ListDoorItem class]];
            
            completeBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
}

- (void)openDoor:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_OPEN, (long)doorID]];
    
    //NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    if (jsonParsingError)
    {
        Response *response = [Response new];
        response.message = [jsonParsingError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    [network request:url withParam:nil method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            completeBlock(response);
        }
        else
        {
            errorBlock(response);
        }
        
    }];
    
}

- (void)lockDoor:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_LOCK, (long)doorID]];
    
    //NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    if (jsonParsingError)
    {
        Response *response = [Response new];
        response.message = [jsonParsingError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    [network request:url withParam:nil method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            completeBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
}

- (void)unlockDoor:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_UNLOCK, (long)doorID]];
    
    //NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    if (jsonParsingError)
    {
        Response *response = [Response new];
        response.message = [jsonParsingError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    [network request:url withParam:nil method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            completeBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
}

- (void)releaseDoor:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_RELEASE, (long)doorID]];
    
    //NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    if (jsonParsingError)
    {
        Response *response = [Response new];
        response.message = [jsonParsingError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    [network request:url withParam:nil method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            completeBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
}

- (void)clearAlarm:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_CLEAR_ALARM, (long)doorID]];
    
    //NSString *jsonStringParam = [self getDoorRequestBody:doorID];
    
    if (jsonParsingError)
    {
        Response *response = [Response new];
        response.message = [jsonParsingError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    [network request:url withParam:nil method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            completeBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
}

- (void)clearAntiPassback:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_DOORS_CLEAR_APB, (long)doorID]];
    
    //NSString *jsonString = [self getDoorRequestBody:doorID];
    
    if (jsonParsingError)
    {
        Response *response = [Response new];
        response.message = [jsonParsingError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    [network request:url withParam:nil method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            completeBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
}

- (void)reqeustOpen:(NSInteger)doorID phoneNumber:(NSString*)phoneNumber onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock
{
    
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
    
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            completeBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
}

@end
