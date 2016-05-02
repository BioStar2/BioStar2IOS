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
    REQUEST_GET_EVENT_MESSAGE,
    REQUEST_SEARCH_EVENT,
    
} EventRequestType;

@protocol EventProviderDelegate <NSObject>

@optional

- (void)requestSearchEventDidFinish:(NSArray*)eventArray totalCount:(NSInteger)count;
- (void)requestSearchEventDidFinish:(NSArray*)eventArray isNextPage:(BOOL)isNext;
- (void)requestGetEventMessageDidFinish:(NSArray *)eventTypes;
- (void)requestEventProviderDidFail:(NSDictionary*)errDic;
- (void)cookieWasExpired:(NSDictionary*)errDic;
@end


static NSMutableArray *eventMessages = nil;

@interface EventProvider : NSObject <BSNetworkDelegate>
{
    BSNetwork *network;
    EventRequestType requestType;
}

@property (assign, nonatomic)id <EventProviderDelegate> delegate;

- (NSMutableArray*)getEventMessages;
- (void)getEventMessage;    // 모니터링 필터링에서 필요한 event type
- (void)searchEvent:(NSDictionary*)conditions;   // 모든 이벤트 가져오기
- (void)searchEvent:(NSDictionary*)condition offset:(NSInteger)offset limit:(NSInteger)limit;
- (void)searchEventByUserID:(NSString*)userID;
+ (NSString*)getEventMessage:(NSInteger)eventTypeID;
+ (NSArray*)getEventCondition:(NSArray*)events;
+ (NSArray*)getUserCondition:(NSArray*)users;
+ (NSDictionary*)getDeviceCondition:(NSArray*)devices;

@end
