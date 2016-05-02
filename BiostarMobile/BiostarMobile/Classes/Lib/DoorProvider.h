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
    SEARCH_DOORS,
    GET_DOORS,
    GET_DOOR,
    OPEN_DOOR,
    LOCK_DOOR,
    UNLOCK_DOOR,
    RELEASE_DOOR,
    CLEAR_ALARM_DOOR,
    CLEAR_ANTI_PASS_BACK_DOOR,
    REQUEST_OPEN_DOOR,
} DoorRequestType;


@protocol DoorProviderDelegate <NSObject>

@optional

- (void)requestGetDoorDidFinish:(NSDictionary*)door;
- (void)requestGetDoorsDidFinish:(NSArray*)doorArray totalCount:(NSInteger)total;
- (void)requestOpenDoorDidFinish:(NSDictionary*)result;
- (void)requestLockDoorDidFinish:(NSDictionary *)result;
- (void)requestUnlockDoorDidFinish:(NSDictionary *)result;
- (void)requestReleaseDoorDidFinish:(NSDictionary *)result;
- (void)requestClearArarmDidFinish:(NSDictionary *)result;
- (void)requestClearAntiPassBackDidFinish:(NSDictionary *)result;
- (void)requestAskOpenDoorDidFinish:(NSDictionary *)result;

- (void)requestDoorProviderDidFail:(NSDictionary*)errDic;

- (void)cookieWasExpired:(NSDictionary*)errDic;

@end

static NSMutableArray *doors = nil;         // 모니터링에서 도어디테일로 갈때 아이디 찾기 위한 어래이

@interface DoorProvider : NSObject <BSNetworkDelegate>
{
    BSNetwork *network;
    
}

@property (assign, nonatomic) id <DoorProviderDelegate> delegate;
@property (assign, nonatomic) DoorRequestType requestType;

+ (NSArray*)getDoors;
- (NSString*)getDoorRequestBody:(NSInteger)doorID;
- (void)searchDoors:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset;
- (void)getDoors;
- (void)getDoor:(NSInteger)doorID;
- (void)openDoor:(NSInteger)doorID;
- (void)lockDoor:(NSInteger)doorID;
- (void)unlockDoor:(NSInteger)doorID;
- (void)releaseDoor:(NSInteger)doorID;
- (void)clearAlarm:(NSInteger)doorID;
- (void)clearAntiPassback:(NSInteger)doorID;
- (void)reqeustOpen:(NSInteger)doorID phoneNumber:(NSString*)phoneNumber;
@end
