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


- (void)getEventTypes:(EventTypeCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock
{
    if (nil == eventTypes)
    {
        eventTypes = [[NSMutableArray alloc] init];
    }
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_EVENT_TYPES];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"event_type_description" forClass:[EventType class]];
            
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[EventType class] forClass:[EventTypeSearchResult class]];
            
            EventTypeSearchResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[EventTypeSearchResult class]];
            
            [eventTypes removeAllObjects];
            
            NSMutableArray <EventType*> *sortArray = [[NSMutableArray alloc] initWithArray:result.records];
            
            NSArray <EventType*> *array = [sortArray sortedArrayUsingComparator:^NSComparisonResult(EventType *a, EventType *b) {
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
            
            [eventTypes addObjectsFromArray:array];
            
            completeBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
    

}

- (NSMutableArray<EventType *> *)getEventTypes
{
    for (EventType *type in eventTypes)
    {
        type.isSelected = NO;
    }
    return eventTypes;
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
                
        [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"event_type_description" forClass:[EventType class]];
        
        [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[EventLogResult class] forClass:[EventLogSearchResultWithoutTotal class]];
        
        EventLogSearchResultWithoutTotal *result = [mapper objectFromSource:responseObject toInstanceOfClass:[EventLogSearchResultWithoutTotal class]];
        
        if (nil == error)
        {
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
