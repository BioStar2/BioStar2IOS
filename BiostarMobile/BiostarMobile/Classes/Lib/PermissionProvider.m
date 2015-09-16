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

#import "PermissionProvider.h"

@implementation PermissionProvider

@synthesize delegate;

- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
    }
    
    return self;
}

- (void)getPermissions
{
    [network setDelegate:self];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_PERMISSIONS];
    [network requestURL:url withParam:nil method:GET];
}

#pragma mark - BSNetwork delegate


- (void)didFinishRequest:(NSDictionary*)resultDic
{
    if ([self.delegate respondsToSelector:@selector(requestGetPermissionDidFinish:)])
    {
        [self.delegate requestGetPermissionDidFinish:[resultDic objectForKey:@"records"]];
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
        [self.delegate requestPermisionProviderDidFail:errDic];
    }
}

@end
