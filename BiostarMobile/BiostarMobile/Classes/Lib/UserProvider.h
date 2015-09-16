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

#define UserProviderInstance   [[UserProvider alloc] init]


typedef enum{
    MyProfile,
    UserInfo,
    UserPhoto,
    UsersInfo,
    UserModify,
    UserCreate,
    UserDelete,
    UserGroup,
} UserRequestType;


@protocol UserProviderDelegate <NSObject>

@optional

- (void)requestDidFinishGettingMyProfile:(NSDictionary*)result;
- (void)requestDidFinishGettingUsersInfo:(NSArray*)userArray totclCount:(NSInteger)count;
- (void)requestDidFinishGettingUserInfo:(NSDictionary*)userInfo;
- (void)requestDidFinishGettingUserPhoto;
- (void)requestDidFinishModifyUserInfo:(NSDictionary*)result;
- (void)requestDidFinishCreateUser:(NSDictionary*)result;
- (void)requestDidFinishGetUserGroups:(NSArray*)groups;
- (void)requestDidFinishDeleteUser:(NSDictionary*)result;
- (void)requestUserProviderDidFail:(NSDictionary*)errDic;
- (void)cookieWasExpired:(NSDictionary*)errDic;

@end

@interface UserProvider : NSObject <BSNetworkDelegate>
{
    BSNetwork *network;
    
}

@property (assign, nonatomic, readonly) UserRequestType type;
@property (nonatomic, assign) id <UserProviderDelegate> delegate;       // URLConnection 델리게이트 결과를 호출한 클래스로 넘겨주기위한 델리게이트

+(UserProvider*)sharedInstance;
+(NSString*)getPasswordStrengthLevel;
+(void)setPasswordStrengthLevel:(NSString*)level;

- (void)getMyProfile;
- (void)setServerURL:(NSString*)url;
- (void)getUsersOffset:(NSInteger)offset limit:(NSInteger)limit groupID:(NSString*)groupID query:(NSString*)query;
- (void)getUser:(NSString*)userID;
- (void)getUserPhoto:(NSString*)userID;
- (void)modifyUser:(NSString*)userID userInfo:(NSDictionary*)userInfoDic;
- (void)createUser:(NSDictionary*)userInfoDic;
- (void)updateProfile:(NSDictionary*)userInfoDic;
- (void)getUserGroups;
- (void)deleteUser:(NSString*)userID;
- (void)deleteUsers:(NSArray*)userIDs;
- (UIImage *)scaledImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
