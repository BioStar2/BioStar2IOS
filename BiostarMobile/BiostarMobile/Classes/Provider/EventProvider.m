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
        mappingProvider = [[InCodeMappingProvider alloc] init];
        mapper = [[ObjectMapper alloc] init];
        mapper.mappingProvider = mappingProvider;
    }
    
    return self;
}

+ (NSString*)convertEventCodeToDescription:(NSInteger)code
{
    NSString *description = nil;
    
    NSArray *eventTypes = [LocalDataManager getEventTypes];
    
    for (NSDictionary *dic in eventTypes)
    {
        if (code == [[dic objectForKey:@"id_code"] integerValue])
        {
            description = [dic objectForKey:@"name"];
            break;
        }
    }
    
    return description;
}

+ (NSArray<EventType *>*)getLocalEventTypes
{
    NSArray *eventTypes = [LocalDataManager getEventTypes];
    
    eventTypes = [EventProvider getSortedEventType:eventTypes];
    
    for (EventType *type in eventTypes)
    {
        type.isSelected = NO;
    }
    
    return eventTypes;
}


+ (NSArray*)getSortedEventType:(NSArray*)originArray
{
    InCodeMappingProvider *mappingProvider = [[InCodeMappingProvider alloc] init];
    ObjectMapper *mapper = [[ObjectMapper alloc] init];
    mapper.mappingProvider = mappingProvider;
    
    [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"event_type_description" forClass:[EventType class]];
    
    NSArray <EventType*> *convertedArray = [mapper objectFromSource:originArray toInstanceOfClass:[EventType class]];
    
    NSArray <EventType*> *array = [convertedArray sortedArrayUsingComparator:^NSComparisonResult(EventType *a, EventType *b) {
        NSInteger first = a.code;
        NSInteger second = b.code;
        
        if (second > first) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (second < first) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
        
    }];
    
    return array;
}


- (void)getEventTypes:(EventTypeCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_EVENT_TYPES];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"event_type_description" forClass:[EventType class]];
            
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[EventType class] forClass:[EventTypeSearchResult class]];
            
            EventTypeSearchResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[EventTypeSearchResult class]];
            
            [LocalDataManager setEventTypes:[responseObject objectForKey:@"records"]];
            
            completeBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
    

}




- (void)searchEvent:(EventQuery*)query completeBlock:(EventSearchCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock
{
    NSError *jsonError;
    
    NSDictionary *queryDic = [mapper dictionaryFromObject:query];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:queryDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_EVENTS_SEARCH];
    
    
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"event_type_description" forClass:[EventType class]];
            
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[EventLogResult class] forClass:[EventLogSearchResultWithoutTotal class]];
            
            EventLogSearchResultWithoutTotal *result = [mapper objectFromSource:responseObject toInstanceOfClass:[EventLogSearchResultWithoutTotal class]];
            
            completeBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
    }];
    
    
}


@end
