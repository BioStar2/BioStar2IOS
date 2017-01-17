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
#import "AccessGroupSearchResult.h"
/**
 *
 *  @brief AccessGroupProvider handle Access Group API
 */

@interface AccessGroupProvider : NSObject 
{
    BSNetwork *network;
    ObjectMapper *mapper;
    InCodeMappingProvider *mappingProvider;
}


typedef void(^AccessGroupObjectBlock)(AccessGroupSearchResult *searchResult);

/**
 *  Get Access Group List
 *
 *  @param query            Search string
 *  @param limit            Number of results
 *  @param offset           Results data offset
 *  @param resultBlock      AccessGroupObjectBlock
 *  @param errorBlock       ErrorBlock
 */

- (void)getAccessGroups:(AccessGroupObjectBlock)resultBlock onError:(ErrorBlock)errorBlock;


/**
 *  Get Access Group List
 *
 *  @param query        Search string
 *  @param limit        Number of results
 *  @param offset       Results data offset
 *  @param handler      NetworkCompleteBolck
 */

- (void)getAccessGroups:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset CompleteHandler:(NetworkCompleteBolck)handler;

@end
