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
        [network setDelegate:self];
    }
    
    return self;
}

- (void)getAccessGroups
{
    requestType = REQUEST_GET_ACCESS_GROUPS;
    
    NSString* url = [NSString stringWithFormat:@"%@%@?limit=10000&offset=0", [NetworkController sharedInstance].serverURL, API_ACCESS_GROUPS];
    [network requestURL:url withParam:nil method:GET];
}


#pragma mark - BSNetwork delegate


- (void)didFinishRequest:(NSDictionary*)resultDic
{
    switch (requestType)
    {
        case REQUEST_GET_ACCESS_GROUPS:
            if ([self.delegate respondsToSelector:@selector(requestGetAccessGroupsDidFinish:)])
            {
                [self.delegate requestGetAccessGroupsDidFinish:resultDic];
            }
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
        [self.delegate requestAccessGroupProviderDidFail:errDic];
    }
}

@end
