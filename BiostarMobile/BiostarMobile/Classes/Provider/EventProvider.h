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
#import "EventLogSearchResultWithoutTotal.h"
#import "EventTypeSearchResult.h"
#import "EventQuery.h"

static NSMutableArray <EventType*> *eventTypes = nil;

/**
 *
 *  @brief EventProvider handle event log API
 */

@interface EventProvider : NSObject
{
    BSNetwork *network;
    ObjectMapper *mapper;
    InCodeMappingProvider *mappingProvider;
}

typedef void(^EventSearchCompleteBolck)(EventLogSearchResultWithoutTotal *result);
typedef void(^EventTypeCompleteBolck)(EventTypeSearchResult *result);

/**
 *  Return event description converted by eventCode
 *
 *  @param code         Event code
 *  @return NSString event description
 */

+ (NSString*)convertEventCodeToDescription:(NSInteger)code;


/**
 *  Return all event messages
 *
 *  @return all event messages
 */

- (NSMutableArray*)getEventTypes;

/**
 *  Get All Event Type
 *
 *  @param handler      NetworkCompleteBolck
 */

- (void)getEventTypes:(EventTypeCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock;



/**
 *  Search event logs
 *
 *  @param condition        Search condition (nullable)
 *  @param offset           The number of start point on the List
 *  @param limit            The number of displayed on the List
 *  @param handler          NetworkCompleteBolck
 
 * Here is a sample example of condition each key and object is optional.
 *
 * @code
 
 NSDictionary *condition = @{@"datetime" : @[@"2016-10-19T15:00:00.00Z", @"2016-10-20T14:59:59.00Z"],
                             @"event_type_code" : @[@"28416", @"28160"],
                             @"user_id" : @[@"4294967294", @"345"],
                             @"device_id" : @[@"541531097", @"541531078"]};
 
 * @endcode
 */

- (void)searchEvent:(EventQuery*)query completeBlock:(EventSearchCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock;



@end
