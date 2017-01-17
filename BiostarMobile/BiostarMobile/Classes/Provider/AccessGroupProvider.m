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

#import "AccessGroupProvider.h"

@implementation AccessGroupProvider

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

- (void)getAccessGroups:(AccessGroupObjectBlock)resultBlock onError:(ErrorBlock)errorBlock
{
    
    NSString* url = [NSString stringWithFormat:@"%@%@?limit=10000&offset=0", [NetworkController sharedInstance].serverURL, API_ACCESS_GROUPS];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"access_group_description" forClass:[AccessGroupItem class]];
            
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[AccessGroupItem class] forClass:[AccessGroupSearchResult class]];
            
            AccessGroupSearchResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[AccessGroupSearchResult class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
        
    }];
    
}


- (void)getAccessGroups:(NSString*)query limit:(NSInteger)limit offset:(NSInteger)offset CompleteHandler:(NetworkCompleteBolck)handler
{
    
    NSString* url;
    if (nil == query)
    {
        url = [NSString stringWithFormat:@"%@%@?limit=%ld&offset=%ld", [NetworkController sharedInstance].serverURL, API_ACCESS_GROUPS, (long)limit, (long)offset];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@%@?text=%@limit=%ld&offset=%ld", [NetworkController sharedInstance].serverURL, API_ACCESS_GROUPS, query, (long)limit, (long)offset];
    }
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        handler(responseObject, error);
    }];
}

@end
