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
#import "GetDoorList.h"

/**
 *
 *  @brief DoorProvider handle door API
 */

@interface DoorProvider : NSObject 
{
    BSNetwork *network;
    ObjectMapper *mapper;
    InCodeMappingProvider *mappingProvider;
    NSError *jsonParsingError;
}

typedef void(^DoorsCompleteBolck)(GetDoorList *result);
typedef void(^DoorCompleteBolck)(ListDoorItem *door);

/**
 *  Get Door List
 *
 *  @param query        Search string
 *  @param limit        Number of results
 *  @param offset       Results data offset
 *  @param handler      NetworkCompleteBolck
 */

- (void)searchDoors:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset completeBlock:(DoorsCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock;

//- (void)getDoors:(DoorsCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock;

/**
 *  Get a door
 *
 *  @param doorID       Door ID
 *  @param handler      NetworkCompleteBolck
 */

- (void)getDoor:(NSInteger)doorID completeBlock:(DoorCompleteBolck)completeBlock onError:(ErrorBlock)errorBlock;

/**
 *  Open a Door
 *
 *  @param doorID       Door ID
 *  @param handler      NetworkCompleteBolck
 */

- (void)openDoor:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock;

/**
 *  Lock a Door
 *
 *  @param doorID       Door ID
 *  @param handler      NetworkCompleteBolck
 */

- (void)lockDoor:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock;

/**
 *  Unlock a Door
 *
 *  @param doorID       Door ID
 *  @param handler      NetworkCompleteBolck
 */

- (void)unlockDoor:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock;


/**
 *  Release a Door
 *
 *  @param doorID       Door ID
 *  @param handler      NetworkCompleteBolck
 */

- (void)releaseDoor:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock;


/**
 *  Clear a Door Alarm
 *
 *  @param doorID       Door ID
 *  @param handler      NetworkCompleteBolck
 */

- (void)clearAlarm:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock;


/**
 *  Clear Anti Pass Back
 *
 *  @param doorID       Door ID
 *  @param handler      NetworkCompleteBolck
 */

- (void)clearAntiPassback:(NSInteger)doorID onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock;

/**
 *  Request Door Open
 *
 *  @param doorID               Door ID
 *  @param phoneNumber          
 *  @param handler              NetworkCompleteBolck
 */

- (void)reqeustOpen:(NSInteger)doorID phoneNumber:(NSString*)phoneNumber onComplete:(ResultBlock)completeBlock onError:(ErrorBlock)errorBlock;
@end
