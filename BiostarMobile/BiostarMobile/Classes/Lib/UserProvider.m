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

#import "UserProvider.h"

NSString *password_strength_level = nil;

@implementation UserProvider

@synthesize delegate;

+(UserProvider*)sharedInstance
{
    static UserProvider *sharedInstance = nil;
    
    if (nil == sharedInstance)
    {
        @synchronized(self)
        {
            if (nil == sharedInstance)
            {
                sharedInstance = [[UserProvider alloc] init];
            }
        }
    }
    
    return sharedInstance;
}

+(NSString*)getPasswordStrengthLevel
{
    return password_strength_level;
}

+(void)setPasswordStrengthLevel:(NSString*)level
{
    password_strength_level = level;
}

- (id)init
{
    if (self = [super init])
    {
        network = [[BSNetwork alloc] init];
        _type = UserInfo;
    }
    
    return self;
}

- (void)setServerURL:(NSString*)URL
{
    [network setServerURL:URL];
}

- (void)getMyProfile
{
    [network setDelegate:self];
    _type = MyProfile;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_MY_PROFILE];
    
    [network requestURL:url withParam:nil method:GET];
}

- (void)getUsersOffset:(NSInteger)offset limit:(NSInteger)limit groupID:(NSString*)groupID query:(NSString*)query;
{
    [network setDelegate:self];
    
    _type = UsersInfo;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:groupID forKey:@"group_id"];
    [param setObject:[NSString stringWithFormat:@"%ld", (long)limit] forKey:@"limit"];
    [param setObject:[NSString stringWithFormat:@"%ld", (long)offset] forKey:@"offset"];
    
    if (nil != query)
    {
        [param setObject:query forKey:@"text"];
    }
    
    
    NSArray *allKeys = [param allKeys];
    NSMutableString *subURL = [[NSMutableString alloc] initWithString:@""];
    for (NSString *key in allKeys)
    {
        [subURL appendString:[NSString stringWithFormat:@"%@=%@&", key, [param objectForKey:key]]];
    }
    [subURL setString:[subURL substringToIndex:subURL.length -1]];
    

    NSString* url = [NSString stringWithFormat:@"%@%@?%@", [NetworkController sharedInstance].serverURL, API_USERS, subURL];
    
    [network requestURL:url withParam:nil method:GET];
    
}

- (void)getUser:(NSString*)userID;
{
    [network setDelegate:self];
    _type = UserInfo;
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_USERS, userID];
    [network requestURL:url withParam:nil method:GET];
}

- (void)getUserPhoto:(NSString*)userID
{
    [network setDelegate:self];
    _type = UserPhoto;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
    [network requestURL:url withParam:nil method:PHOTO_GET];
}

- (void)updateProfile:(NSDictionary*)userInfoDic
{
    [network setDelegate:self];
    _type = MyProfileModify;
    
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:userInfoDic];
    
    if ([[tempDic objectForKey:@"photo"] isKindOfClass:[UIImage class]])
    {
        UIImage *photo = [tempDic objectForKey:@"photo"];
        
        NSData *photoData = [CommonUtil getImageDataCompress:photo fileSize:MAX_IMAGE_FILE_SIZE];
        
        NSLog(@"Size of Image(bytes):%lu",(unsigned long)[photoData length]);
        
        NSString *photoStr = [photoData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        [tempDic setObject:photoStr forKey:@"photo"];
        
    }
    
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:tempDic options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_MY_PROFILE];
    [network requestURL:url withParam:jsonString method:PUT];
}

- (void)modifyUser:(NSString*)userID userInfo:(NSDictionary*)userInfoDic
{
    [network setDelegate:self];
    _type = UserModify;
    
    // 제이슨 데이터 서버 형식으로 변환
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:userInfoDic];
    
    if ([[tempDic objectForKey:@"photo"] isKindOfClass:[UIImage class]])
    {
        UIImage *photo = [tempDic objectForKey:@"photo"];
        
        NSData *photoData = [CommonUtil getImageDataCompress:photo fileSize:MAX_IMAGE_FILE_SIZE];
        
        NSLog(@"Size of Image(bytes):%lu",(unsigned long)[photoData length]);
        
        NSString *photoStr = [photoData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        [tempDic setObject:photoStr forKey:@"photo"];
        
    }
    
    
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:tempDic options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_USERS, [userInfoDic objectForKey:@"user_id"]];
    [network requestURL:url withParam:jsonString method:PUT];
}

- (void)createUser:(NSDictionary*)userInfoDic
{
    [network setDelegate:self];
    _type = UserCreate;
    
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:userInfoDic];
    
    if ([[tempDic objectForKey:@"photo"] isKindOfClass:[UIImage class]])
    {
        UIImage *photo = [tempDic objectForKey:@"photo"];
        
        NSData *photoData = [CommonUtil getImageDataCompress:photo fileSize:MAX_IMAGE_FILE_SIZE];
        
        NSLog(@"Size of Image(bytes):%lu",(unsigned long)[photoData length]);
        
        NSString *photoStr = [photoData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        [tempDic setObject:photoStr forKey:@"photo"];
        

    }
    
    
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:tempDic options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_USERS];
    
    [network requestURL:url withParam:jsonString method:POST];
}


- (void)getUserGroups
{
    [network setDelegate:self];
    _type = UserGroup;
    
    NSString* url = [NSString stringWithFormat:@"%@%@?limit=1000&offset=0", [NetworkController sharedInstance].serverURL, API_USER_GROUPS];
    
    [network requestURL:url withParam:nil method:GET];
}

- (void)deleteUser:(NSString*)userID
{
    [network setDelegate:self];
    _type = UserDelete;
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_USERS, userID];
    [network requestURL:url withParam:nil method:DELETE];
}

- (void)deleteUsers:(NSArray*)userIDs
{
    [network setDelegate:self];
    _type = UserDelete;

    NSDictionary *ids = @{@"ids" : userIDs};
    NSError *jsonError;
    NSData *jsonData;
    jsonData = [NSJSONSerialization dataWithJSONObject:ids options:kNilOptions error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_DELETE_USERS];
    [network requestURL:url withParam:jsonString method:DELETE];
}

#pragma mark - BSNetwork delegate


- (void)didFinishPhotoRequest:(NSString*)responseString fromURL:(NSString*)url
{
    NSRange range = [responseString rangeOfString:@","];
    
    
    NSString *imageString = [responseString substringFromIndex:range.location + 1];
    
    NSData *imageData = [NSData base64DataFromString:imageString];
    UIImage *userImage = [UIImage imageWithData:imageData];
    
    [[SDImageCache sharedImageCache] storeImage:userImage forKey:url toDisk:YES];
    
    if ([self.delegate respondsToSelector:@selector(requestDidFinishGettingUserPhoto)])
    {
        [self.delegate requestDidFinishGettingUserPhoto];
    }

}

- (void)didFinishRequest:(NSDictionary*)resultDic
{
    switch (_type)
    {
        case MyProfile:
            if ([self.delegate respondsToSelector:@selector(requestDidFinishGettingMyProfile:)])
            {
                [UserProvider setPasswordStrengthLevel:[resultDic objectForKey:@"password_strength_level"]];
                [AuthProvider setLoginUserInfo:resultDic];
                [self.delegate requestDidFinishGettingMyProfile:resultDic];
            }
            break;
        case UserInfo:
            if ([self.delegate respondsToSelector:@selector(requestDidFinishGettingUserInfo:)])
            {
                [self.delegate requestDidFinishGettingUserInfo:resultDic];
            }
            break;
            
        case UsersInfo:
            if ([self.delegate respondsToSelector:@selector(requestDidFinishGettingUsersInfo:totclCount:)])
            {
                
                [self.delegate requestDidFinishGettingUsersInfo:[resultDic objectForKey:@"records"] totclCount:[[resultDic objectForKey:@"total"] intValue]];
            }
            break;
            
        case UserModify:
            if ([self.delegate respondsToSelector:@selector(requestDidFinishModifyUserInfo:)])
            {
                [self.delegate requestDidFinishModifyUserInfo:resultDic];
            }
            break;
            
        case UserCreate:
            if ([self.delegate respondsToSelector:@selector(requestDidFinishCreateUser:)])
            {
                [self.delegate requestDidFinishCreateUser:resultDic];
            }
            break;
        case UserGroup:
            if ([self.delegate respondsToSelector:@selector(requestDidFinishGetUserGroups:)])
            {
                [self.delegate requestDidFinishGetUserGroups:[resultDic objectForKey:@"records"]];
            }
            break;
        case UserDelete:
            if ([self.delegate respondsToSelector:@selector(requestDidFinishDeleteUser:)])
            {
                [self.delegate requestDidFinishDeleteUser:resultDic];
            }
            break;
        case MyProfileModify:
            if ([self.delegate respondsToSelector:@selector(requestDidFinishModifyMyProfile:)])
            {
                [self.delegate requestDidFinishModifyMyProfile:resultDic];
            }
            break;
        default:
            break;
    }
    
    resultDic = nil;

    
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
        if ([self.delegate respondsToSelector:@selector(requestUserProviderDidFail:)])
        {
            [self.delegate requestUserProviderDidFail:errDic];
        }
    }
}
@end
