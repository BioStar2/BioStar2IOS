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
#import <UIKit/UIKit.h>
#import "BSNetwork.h"
#import "AuthProvider.h"
#import "SDImageCache.h"
#import "CommonUtil.h"
#import "Common.h"
#import "CardSearchResult.h"
#import "UserGroupSearchResult.h"
#import "ObjectMapper.h"
#import "InCodeMappingProvider.h"
#import "UserSearchResult.h"
#import "MobileCredential.h"
#import "MobileCredentialList.h"
#import "UnassignCards.h"
#import "CardList.h"
#import "UserFingerprintRecords.h"
#import "MobileCredentialRegisterResponse.h"
#import "UserCardList.h"
#import "UserFaceTemplateList.h"

#define UserProviderInstance   [[UserProvider alloc] init]


/**
 *
 *  @brief UserProvider request API and respond for user. ex) get, modify, delete, create user and so on...
 */

@interface UserProvider : NSObject
{
    BSNetwork *network;
    
    ObjectMapper *mapper;
    InCodeMappingProvider *mappingProvider;
}

typedef enum{
    /*! When get my profile */
    MyProfile_Request,
    /*! When get user info */
    UserInfo_Request,
    /*! When get user photo */
    UserPhoto_Request,
    /*! When get users info */
    UsersInfo_Request,
    /*! When modify user info*/
    UserModify_Request,
    /*! When create user*/
    UserCreate_Request,
    /*! When delete user*/
    UserDelete_Request,
    /*! When get user group*/
    UserGroup_Request,
    /*! When modify my profile*/
    MyProfileModify_Request,
} UserRequestType;


typedef void(^UserArrayCompleteBolck)(UserSearchResult *userSearchResult);
typedef void(^UserBolck)(User *userResult);
typedef void(^UserGroupArrayBolck)(UserGroupSearchResult *userSearchResult);
typedef void(^UserObjectBlock)(User *user);
typedef void(^UserCardsBlock)(CardSearchResult *result);
typedef void(^UserCardListBlock)(UserCardList *result);
typedef void(^UserMobileCredentialListBlock)(MobileCredentialList *result);
typedef void(^UserFingerprintTemplatesBlock)(NSArray <FingerprintTemplate*> *result);
typedef void(^UserPhotoBolck)(NSDictionary *responseObject, NSError *error);
typedef void(^MobileCredentialBlock)(MobileCredentialRegisterResponse *response);
typedef void(^UserFaceTemplateListBlock)(UserFaceTemplateList *result);

@property (assign, nonatomic, readonly) UserRequestType type;


/**
 *  Get my profile
 *
 *  @param handler      NetworkCompleteBolck
 */
- (void)getMyProfile:(UserBolck)userBlock onError:(ErrorBlock)errorBlock;


/**
 *  Get users
 *
 *  @param offset           user list offset
 *  @param limit            user list limit
 *  @param groupID          user group ID
 *  @param query            user query
 *  @param resultBlock      UserArrayCompleteBolck
 *  @param errorBlock       UserErrorBlock
 */
- (void)getUsersOffset:(NSInteger)offset limit:(NSInteger)limit groupID:(NSString*)groupID query:(NSString*)query completeHandler:(UserArrayCompleteBolck)resultBlock onError:(ErrorBlock)errorBlock;

/**
 *  Get an user
 *
 *  @param userID       An user ID
 *  @param handler      NetworkCompleteBolck
 */
- (void)getUser:(NSString*)userID userBlock:(UserBolck)userBlock onError:(ErrorBlock)errorBlock;

/**
 *  Get an user's photh
 *
 *  @param userID       An user ID
 *  @param handler      NetworkCompleteBolck
 */
- (void)getUserPhoto:(NSString*)userID completeHandler:(UserPhotoBolck)handler;

- (void)updateUserPhoto:(NSString*)userID photo:(NSString*)photo completeHandler:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;

/**
 *  Modify an user's info
 *
 *  @param user                 User Model
 *  @param responseBlock
 *  @param errorBlock
 *  @see https://api.biostar2.com/v1/docs/#!/User/users__user_id__put
 */
- (void)modifyUser:(User*)user responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;

/**
 *  Modify my profile
 *
 *  @param userInfoDic      NSDictionary that user's info (see the uner URL)
 *  @param handler          NetworkCompleteBolck
 *  @see https://api.biostar2.com/v1/docs/#!/User/users_my_profile_put
 */
- (void)updateProfile:(User*)user responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;

/**
 *  Create an user
 *
 *  @param userInfoDic      NSDictionary that user's info (see the uner URL)
 *  @param handler          NetworkCompleteBolck
 *  @see https://api.biostar2.com/v1/docs/#!/User/users_post
 */
- (void)createUser:(User*)user responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;

/**
 *  Get user group list
 *
 *  @param handler          NetworkCompleteBolck
 */
- (void)getUserGroups:(UserGroupArrayBolck)resultBlock onError:(ErrorBlock)errorBlock;

/**
 *  Delete an user
 *
 *  @param userID           User ID to be delete
 *  @param handler          NetworkCompleteBolck
 */
- (void)deleteUser:(NSString*)userID responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;

/**
 *  Delete users
 *
 *  @param userIDs          User ID array to be delete
 *  @param handler          NetworkCompleteBolck
 */
- (void)deleteUsers:(NSArray*)userIDs responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;


#pragma mark - User Card APIs

/**
 *  Get user Cards
 *
 *  @param userID                   User ID
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */
- (void)getUserCards:(NSString*)userID responseBlock:(UserCardListBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock;



/**
 *  Update user cards
 *
 *  @param card                     BaseCard
 *  @param userID                   User ID
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */
- (void)updateUserCard:(CardList*)cardList userID:(NSString*)userID responseBlock:(ResultBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;





#pragma mark - User Mobile Credential APIs

/**
 *  Get Loggered in user mobile_credentials
 *
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */
- (void)getMyMobileCredentials:(UserMobileCredentialListBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock;


/**
 *  Get user mobile_credentials
 *
 *  @param userID                   User ID
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */
- (void)getUserMobileCredentials:(NSString*)userID resultBlock:(UserMobileCredentialListBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock;

/**
 *  Issue user mobile_credential
 *
 *  @param card                     BaseCard
 *  @param userID                   User ID
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */
- (void)issueMobileCredential:(MobileCredential*)mobileCredential userID:(NSString*)userID responseBlock:(AddBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;


/**
 *  Reissue user mobile_credential
 *
 *  @param card                     BaseCard
 *  @param userID                   User ID
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */
- (void)reissueUserMobileCredential:(NSString*)userID cardRecordID:(NSString*)cardRecordID responseBlock:(AddBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;


/**
 *  Register user mobile_credential
 *
 *  @param cardRecoreID             cardRecoreID
 *  @param UUID                     UUID
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */
- (void)registerMobileCredential:(NSString*)cardRecoreID UUID:(NSString*)UUID responseBlock:(MobileCredentialBlock)responseBlock onErrorBlock:(ErrorBlock)errorBlock;




#pragma mark - User Fingerprint APIs

/**
 *  Get user Fingerprint templates
 *
 *  @param userID                   userID
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */

- (void)getUserFingerprints:(NSString*)userID resultBlock:(UserFingerprintTemplatesBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock;

/**
 *  Update user Fingerprint templates
 *
 *  @param templates                FingerprintTemplate array
 *  @param userID                   userID
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */

- (void)updateUserFingerprints:(UserFingerprintRecords*)templateList userID:(NSString*)userID resultBlock:(ResultBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock;



#pragma mark - User FaceTemplate APIs

/**
 *  Get user Face templates
 *
 *  @param userID                   userID
 *  @param resultBlock              UserFaceTemplateListBlock
 *  @param errorBlock               ErrorBlock
 */

- (void)getUserFaceTemplate:(NSString*)userID resultBlock:(UserFaceTemplateListBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock;

/**
 *  Update user Face templates
 *
 *  @param templates                FingerprintTemplate array
 *  @param userID                   userID
 *  @param responseBlock            ResultBlock
 *  @param errorBlock               ErrorBlock
 */

- (void)updateUserFaceTemplate:(UserFaceTemplateList*)templateList userID:(NSString*)userID resultBlock:(ResultBlock)resultBlock onErrorBlock:(ErrorBlock)errorBlock;

@end
