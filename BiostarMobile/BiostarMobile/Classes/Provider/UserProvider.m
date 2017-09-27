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


@implementation UserProvider



- (id)init
{
    if (self = [super init])
    {
        _type = UserInfo_Request;
        network = [[BSNetwork alloc] init];
        
        mappingProvider = [[InCodeMappingProvider alloc] init];
        mapper = [[ObjectMapper alloc] init];
        mapper.mappingProvider = mappingProvider;
    }
    
    return self;
}


- (void)getMyProfile:(UserBolck)userBlock onError:(ErrorBlock)errorBlock
{
    _type = MyProfile_Request;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_MY_PROFILE];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error) {
            
            if ([PreferenceProvider isUpperVersion])
            {
                
                // V2
                [mappingProvider mapFromDictionaryKey:@"permissions" toPropertyKey:@"permissions" withObjectType:[PermissionItem class] forClass:[Permission class]];
                
                [mappingProvider mapFromDictionaryKey:@"access_groups" toPropertyKey:@"access_groups" withObjectType:[UserItemAccessGroup class] forClass:[User class]];
                
                User *result = [mapper objectFromSource:responseObject toInstanceOfClass:[User class]];
                
                [AuthProvider setLoginUserInfo:result];
                
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
                
                [AuthProvider setLoginUserInfo:result];
                
                userBlock(result);
            }
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
}


- (void)getUsersOffset:(NSInteger)offset limit:(NSInteger)limit groupID:(NSString*)groupID query:(NSString*)query completeHandler:(UserArrayCompleteBolck)resultBlock onError:(ErrorBlock)errorBlock
{
    _type = UsersInfo_Request;
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (nil != groupID)
    {
        [param setObject:groupID forKey:@"group_id"];
    }
    
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
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[User class] forClass:[UserSearchResult class]];
            
            UserSearchResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[UserSearchResult class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
}

- (void)getUser:(NSString*)userID userBlock:(UserBolck)userBlock onError:(ErrorBlock)errorBlock
{
    _type = UserInfo_Request;
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_USERS, userID];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            if ([PreferenceProvider isUpperVersion])
            {
                // V2
                [mappingProvider mapFromDictionaryKey:@"permissions" toPropertyKey:@"permissions" withObjectType:[PermissionItem class] forClass:[Permission class]];
                
                [mappingProvider mapFromDictionaryKey:@"access_groups" toPropertyKey:@"access_groups" withObjectType:[UserItemAccessGroup class] forClass:[User class]];
                
                User *result = [mapper objectFromSource:responseObject toInstanceOfClass:[User class]];
                userBlock(result);
            }
            else
            {
                [mappingProvider mapFromDictionaryKey:@"permissions" toPropertyKey:@"permissions" withObjectType:[CloudPermission class] forClass:[User class]];
                
                [mappingProvider mapFromDictionaryKey:@"access_groups" toPropertyKey:@"access_groups" withObjectType:[UserItemAccessGroup class] forClass:[User class]];
                
                [mappingProvider mapFromDictionaryKey:@"description" toPropertyKey:@"role_description" forClass:[UserRole class]];
                
                [mappingProvider mapFromDictionaryKey:@"roles" toPropertyKey:@"roles" withObjectType:[UserRole class] forClass:[User class]];
                
                User *result = [mapper objectFromSource:responseObject toInstanceOfClass:[User class]];
                
                userBlock(result);
            }
            
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
}


- (void)getUserPhoto:(NSString*)userID completeHandler:(UserPhotoBolck)handler
{
    _type = UserPhoto_Request;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
    
    [network request:url withParam:nil method:PHOTO_GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        handler(responseObject, error);
    }];
    
}

- (void)updateUserPhoto:(NSString*)userID photo:(NSString*)photo completeHandler:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSString *jsonString = photo;
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
    
    [network request:url withParam:jsonString method:PHOTO_PUT completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            responseBlock(response);
        }
        else
        {
            errorBlock(response);
        }
        
    }];
}

- (void)modifyUser:(User*)user responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    _type = UserModify_Request;
    
    
    NSDictionary *userDic = [mapper dictionaryFromObject:user];
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_USERS, user.user_id];
    
    [network request:url withParam:jsonString method:PUT completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            responseBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
    
}


- (void)updateProfile:(User*)user responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    _type = MyProfileModify_Request;
    
    
    NSDictionary *userDic = [mapper dictionaryFromObject:user];
    
    NSMutableDictionary *updateDic = [[NSMutableDictionary alloc] init];
    if ([userDic objectForKey:@"email"])
    {
        [updateDic setObject:[userDic objectForKey:@"email"] forKey:@"email"];
    }
    if ([userDic objectForKey:@"login_id"])
    {
        [updateDic setObject:[userDic objectForKey:@"login_id"] forKey:@"login_id"];
    }
    if ([userDic objectForKey:@"name"])
    {
        [updateDic setObject:[userDic objectForKey:@"name"] forKey:@"name"];
    }
    if ([userDic objectForKey:@"password"])
    {
        [updateDic setObject:[userDic objectForKey:@"password"] forKey:@"password"];
    }
    if ([userDic objectForKey:@"phone_number"])
    {
        [updateDic setObject:[userDic objectForKey:@"phone_number"] forKey:@"phone_number"];
    }
    if ([userDic objectForKey:@"photo"])
    {
        [updateDic setObject:[userDic objectForKey:@"photo"] forKey:@"photo"];
    }
    if ([userDic objectForKey:@"pin"])
    {
        [updateDic setObject:[userDic objectForKey:@"pin"] forKey:@"pin"];
    }
    
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:updateDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_MY_PROFILE];
    
    [network request:url withParam:jsonString method:PUT completionHandler:^(NSDictionary *responseObject, NSError *error) {
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            responseBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
    
}



- (void)createUser:(User*)user responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    _type = UserCreate_Request;
    
    
    NSDictionary *userDic = [mapper dictionaryFromObject:user];
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_USERS];
    
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            responseBlock(response);
        }
        else
        {
            errorBlock(response);
        }
        
    }];

}


- (void)getUserGroups:(UserGroupArrayBolck)resultBlock onError:(ErrorBlock)errorBlock
{
    _type = UserGroup_Request;
    
    NSString* url = [NSString stringWithFormat:@"%@%@?limit=1000&offset=0", [NetworkController sharedInstance].serverURL, API_USER_GROUPS];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (error == nil)
        {
            [mappingProvider mapFromDictionaryKey:@"records" toPropertyKey:@"records" withObjectType:[UserGroup class] forClass:[UserGroupSearchResult class]];
            
            UserGroupSearchResult *result = [mapper objectFromSource:responseObject toInstanceOfClass:[UserGroupSearchResult class]];
            
            NSArray *sortedArray = [result.records  sortedArrayUsingComparator:
                                    ^NSComparisonResult(UserGroup *obj1, UserGroup *obj2){
                                        
                                        const char *obj1Name = [[obj1.name lowercaseString] UTF8String];
                                        const char *obj2Name = [[obj2.name lowercaseString] UTF8String];
                                        
                                        int order = strcmp(obj1Name, obj2Name);
                                        return order;
                                    }];
            
            result.records = sortedArray;
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
    
}

- (void)deleteUser:(NSString*)userID responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    _type = UserDelete_Request;
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [NetworkController sharedInstance].serverURL, API_USERS, userID];

    [network request:url withParam:nil method:DELETE completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            responseBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
    
}

- (void)deleteUsers:(NSArray*)userIDs responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    _type = UserDelete_Request;

    NSDictionary *ids = @{@"ids" : userIDs};
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ids options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_DELETE_USERS];
    
    [network request:url withParam:jsonString method:DELETE completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            responseBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
    
}


#pragma mark - User Card APIs


- (void)getUserCards:(NSString*)userID responseBlock:(UserCardListBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_CARDS, userID]];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"card_list" toPropertyKey:@"card_list" withObjectType:[Card class] forClass:[UserCardList class]];
            
            UserCardList *result = [mapper objectFromSource:responseObject toInstanceOfClass:[UserCardList class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
}


- (void)updateUserCard:(CardList*)cardList userID:(NSString*)userID responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary *cardListDic = [mapper dictionaryFromObject:cardList];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cardListDic options:kNilOptions error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_CARDS, userID]];
    
    [network request:url withParam:jsonString method:PUT completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            responseBlock(response);
        }
        else
        {
            errorBlock(response);
        }
    }];
}




#pragma mark - User Mobile Credential APIs

- (void)getMyMobileCredentials:(UserMobileCredentialListBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, API_MY_PROFILE_MOBILE_CREDENTIAL];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"access_groups" toPropertyKey:@"access_groups" withObjectType:[UserItemAccessGroup class] forClass:[GetMobileCredential class]];
            
            [mappingProvider mapFromDictionaryKey:@"mobile_credential_list" toPropertyKey:@"mobile_credential_list" withObjectType:[GetMobileCredential class] forClass:[MobileCredentialList class]];
            
            MobileCredentialList *result = [mapper objectFromSource:responseObject toInstanceOfClass:[MobileCredentialList class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
}

- (void)getUserMobileCredentials:(NSString*)userID resultBlock:(UserMobileCredentialListBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_MOBILE_CREDENTIAL, userID]];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"mobile_credential_list" toPropertyKey:@"mobile_credential_list" withObjectType:[GetMobileCredential class] forClass:[MobileCredentialList class]];
            
            MobileCredentialList *result = [mapper objectFromSource:responseObject toInstanceOfClass:[MobileCredentialList class]];
            
            resultBlock(result);
        }
        else
        {
            Response *error = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(error);
        }
        
    }];
}

- (void)issueMobileCredential:(MobileCredential*)mobileCredential userID:(NSString*)userID responseBlock:(AddBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary *cardDic = [mapper dictionaryFromObject:mobileCredential];
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cardDic options:kNilOptions error:&jsonError];
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_ISSUE_MOBILE_CREDENTIAL, userID]];
    
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            AddResponse *response = [mapper objectFromSource:responseObject toInstanceOfClass:[AddResponse class]];
            responseBlock(response);
        }
        else
        {
            Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(response);
        }
    }];
}



- (void)reissueUserMobileCredential:(NSString*)userID cardRecordID:(NSString*)cardRecordID responseBlock:(AddBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_REISSUE_MOBILE_CREDENTIAL, userID, cardRecordID]];
    
    [network request:url withParam:nil method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            AddResponse *response = [mapper objectFromSource:responseObject toInstanceOfClass:[AddResponse class]];
            responseBlock(response);
        }
        else
        {
            Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(response);
        }
    }];
}


- (void)registerMobileCredential:(NSString*)cardRecoreID UUID:(NSString*)UUID responseBlock:(MobileCredentialBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSDictionary *RegisterMobileCredential = @{@"udid" : UUID};
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:RegisterMobileCredential options:kNilOptions error:&jsonError];
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_REGISTER_MOBILE_CREDENTIAL, cardRecoreID]];
    
    [network request:url withParam:jsonString method:POST completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            MobileCredentialRegisterResponse *response = [mapper objectFromSource:responseObject toInstanceOfClass:[MobileCredentialRegisterResponse class]];
            responseBlock(response);
        }
        else
        {
            Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(response);
        }
    }];
}



#pragma mark - User Fingerprint APIs

- (void)getUserFingerprints:(NSString*)userID resultBlock:(UserFingerprintTemplatesBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_FINGERPRINT_TEMPLATES, userID]];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"fingerprint_template_list" toPropertyKey:@"fingerprint_template_list" withObjectType:[FingerprintTemplate class] forClass:[UserFingerprintRecords class]];
            
            UserFingerprintRecords *result = [mapper objectFromSource:responseObject toInstanceOfClass:[UserFingerprintRecords class]];
            
            resultBlock(result.fingerprint_template_list);
        }
        else
        {
            Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(response);
        }
        
    }];
}


- (void)updateUserFingerprints:(UserFingerprintRecords*)templateList userID:(NSString*)userID resultBlock:(ResultBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSError *jsonError;
    
    NSDictionary *templatesDic = [mapper dictionaryFromObject:templateList];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:templatesDic options:NSJSONWritingPrettyPrinted error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_FINGERPRINT_TEMPLATES, userID]];
    
    [network request:url withParam:jsonString method:PUT completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            resultBlock(response);
        }
        else
        {
            errorBlock(response);
        }
        
    }];
}

#pragma mark - User Face Templates APIs

- (void)getUserFaceTemplate:(NSString*)userID resultBlock:(UserFaceTemplateListBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_FACE_TEMPLATES, userID]];
    
    [network request:url withParam:nil method:GET completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        if (nil == error)
        {
            [mappingProvider mapFromDictionaryKey:@"face_template_list" toPropertyKey:@"face_template_list" withObjectType:[FaceTemplate class] forClass:[UserFaceTemplateList class]];
            
            UserFaceTemplateList *result = [mapper objectFromSource:responseObject toInstanceOfClass:[UserFaceTemplateList class]];
            
            resultBlock(result);
        }
        else
        {
            Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
            errorBlock(response);
        }
        
    }];
}

- (void)updateUserFaceTemplate:(UserFaceTemplateList*)templateList userID:(NSString*)userID resultBlock:(ResultBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock
{
    NSError *jsonError;
    
    NSMutableArray *face_template_list = [NSMutableArray new];
    for (FaceTemplate *template in templateList.face_template_list)
    {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:[mapper dictionaryFromObject:template]];
        
        if ([template.id integerValue] == 0)
        {
            [tempDic removeObjectForKey:@"id"];
        }
        
        [face_template_list addObject:tempDic];
    }
    
    NSDictionary *updateUserFaceTemplateList = @{@"face_template_list" : face_template_list};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:updateUserFaceTemplateList options:NSJSONWritingPrettyPrinted error:&jsonError];
    
    if (nil != jsonError)
    {
        Response *response = [Response new];
        response.message = [jsonError localizedDescription];
        errorBlock(response);
        
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* url = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USERS_FACE_TEMPLATES, userID]];
    
    [network request:url withParam:jsonString method:PUT completionHandler:^(NSDictionary *responseObject, NSError *error) {
        
        Response *response = [mapper objectFromSource:responseObject toInstanceOfClass:[Response class]];
        
        if (nil == error)
        {
            resultBlock(response);
        }
        else
        {
            errorBlock(response);
        }
        
    }];
}


@end
