
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

#import "AuthProvider.h"

User *loginUser = nil;


@implementation AuthProvider

+ (User*)getLoginUserInfo
{
    return loginUser;
}

+ (void)setLoginUserInfo:(User*)user
{
    loginUser = user;
}

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



+ (BOOL)hasWritePermission:(NSString*)permissionValue
{
    if (nil == loginUser)
    {
        return NO;
    }
    
    if ([PreferenceProvider isUpperVersion])
    {
        // V2
        PermissionItem *selectedPermission;
        for (PermissionItem *permission in loginUser.permission.permissions)
        {
            if ([permissionValue isEqualToString:permission.module])
            {
                selectedPermission = permission;
                break;
            }
        }
        
        if (!selectedPermission)
        {
            return NO;
        }
        
        return selectedPermission.write;
    }
    else
    {
        // V1
        CloudPermission *selectedPermission;
        for (CloudPermission *permission in loginUser.permissions)
        {
            if ([permissionValue isEqualToString:permission.module])
            {
                selectedPermission = permission;
                break;
            }
        }
        
        if (!selectedPermission)
        {
            return NO;
        }
        
        return selectedPermission.write;
    }
}

+ (BOOL)hasReadPermission:(NSString*)permissionValue
{
    if (nil == loginUser)
    {
        return NO;
    }
    
    if ([PreferenceProvider isUpperVersion])
    {
        // V2
        PermissionItem *selectedPermission;
        for (PermissionItem *permission in loginUser.permission.permissions)
        {
            if ([permissionValue isEqualToString:permission.module])
            {
                selectedPermission = permission;
                break;
            }
        }
        
        if (!selectedPermission)
        {
            return NO;
        }
        
        if (selectedPermission.write)
        {
            return YES;
        }
        
        return selectedPermission.read;
    }
    else
    {
        // V1
        CloudPermission *selectedPermission;
        for (CloudPermission *permission in loginUser.permissions)
        {
            if ([permissionValue isEqualToString:permission.module])
            {
                selectedPermission = permission;
                break;
            }
        }
        
        if (!selectedPermission)
        {
            return NO;
        }
        
        if (selectedPermission.write)
        {
            return YES;
        }
        
        return selectedPermission.read;
    }
}

- (void)login:(NSString*)loginID password:(NSString*)password name:(NSString*)name userBlock:(LoginUserBlock)userBlock onError:(ErrorBlock)errorBlock
{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    version = [NSString stringWithFormat:@"V.%@", version];
    
    NSDictionary *userDic = @{@"user_id" : loginID,
                              @"password" : password,
                              @"name" : name,
                              @"mobile_app_version" : version,
                              @"mobile_device_type" : @"IOS",
                              @"mobile_os_version" : [UIDevice currentDevice].systemVersion,
                              };
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:userDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_LOGIN];
    
    [network request:url withParam:jsonString method:LOGIN_POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (nil == error)
            {

                if ([PreferenceProvider isUpperVersion])
                {
                    // V2
                    [mappingProvider mapFromDictionaryKey:@"permissions" toPropertyKey:@"permissions" withObjectType:[PermissionItem class] forClass:[Permission class]];
                    
                    [mappingProvider mapFromDictionaryKey:@"access_groups" toPropertyKey:@"access_groups" withObjectType:[UserItemAccessGroup class] forClass:[User class]];
                    
                    User *result = [mapper objectFromSource:responseObject toInstanceOfClass:[User class]];
                    
                    loginUser = result;
                    
                    
                    userBlock(result);
                }
                else
                {
                    // V1
                    [mappingProvider mapFromDictionaryKey:@"permissions" toPropertyKey:@"permissions" withObjectType:[CloudPermission class] forClass:[User class]];
                    
                    [mappingProvider mapFromDictionaryKey:@"access_groups" toPropertyKey:@"access_groups" withObjectType:[UserItemAccessGroup class] forClass:[User class]];
                    
                    [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"role_description" forClass:[UserRole class]];
                    
                    [mappingProvider mapFromDictionaryKey:@"roles" toPropertyKey:@"roles" withObjectType:[UserRole class] forClass:[User class]];
                    
                    User *result = [mapper objectFromSource:responseObject toInstanceOfClass:[User class]];
                    
                    loginUser = result;
                    
                    
                    userBlock(result);
                }
            }
            else
            {
                Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
                errorBlock(error);
            }
            
        });
        
    }];
}

- (void)logout:(ResultBlock)responseBlock onError:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_LOGOUT];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            Response *resoponse = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            
            if (nil == error)
            {
                responseBlock(resoponse);
            }
            else
            {
                errorBlock(resoponse);
            }
        });
        
    }];

}


@end
