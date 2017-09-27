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

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UserProvider.h"
#import "CommonUtil.h"
#import "UserDetailPictureCell.h"
#import "UserDetailNormalCell.h"
#import "UserDetailAcclCell.h"
#import "UserDetailDateCell.h"
#import "UserVerificationAddViewController.h"
#import "AccessGroupProvider.h"
#import "DatePickerPopupViewController.h"
#import "UserDetailDateAccCell.h"
#import <MessageUI/MessageUI.h>
#import "ListPopupViewController.h"
#import "TextPopupViewController.h"
#import "MonitoringViewController.h"
#import "OneButtonTablePopupViewController.h"
#import "ImagePopupViewController.h"
#import "OneButtonPopupViewController.h"
#import "UserDetailSwitchCell.h"
#import "PinPopupViewController.h"
#import "UserDetailOperatorCell.h"
#import "MonitorFilterViewController.h"
#import "PermissionPopupViewController.h"
#import "UserGroupPopupViewController.h"
#import "SDImageCache.h"
#import "CardCredentialViewController.h"
#import "PreferenceProvider.h"
#import "LocalDataManager.h"
#import "PermissionProvider.h"


@protocol UserDetailDelegate <NSObject>

- (void)needToReloadUsers;

@end

@interface UserNewDetailViewController : BaseViewController <MFMailComposeViewControllerDelegate, UserDetailAccCellDelegate, UserVerificationAddViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SwitchCellDelegate, CardCredentialDelegate>
{
    
    __weak IBOutlet UIButton *editButton;
    __weak IBOutlet UIButton *doneButton;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *detailTableView;
    __weak IBOutlet NSLayoutConstraint *tableViewConstraint;
    __weak IBOutlet UIView *editButtonView;
    __weak IBOutlet UIView *titleView;
    __weak IBOutlet UIButton *logButton;

    UserProvider *provider;
    PreferenceProvider *preferenceProvoder;
    User *currentUser;
    User *toUpdateUser;
    NSString *userID;
    BOOL hasOperator;
    BOOL isUpdatedOrDeleted;
    NSInteger rowCount;
}

@property (assign, nonatomic) id <UserDetailDelegate> delegate;
@property (assign, nonatomic) DetailType type;

- (void)getUserInfo:(NSString*)_userID;

- (void)getMyProfile;

- (void)loadUserInfo:(User*)user;

- (void)setDefaultPeriod;

- (void)setUserGroup:(UserGroup*)userGroup;      // 사용자 리스트에서 필터로 선택한 그룹을 사용자 추가 일때 디폴트로 설정하기

- (void)showUserGroupPopup;

- (void)showPeriodPopup;

- (void)showPermissionPopup;

- (void)moveToVerificationViewController:(VerificationType)type;

- (void)moveToFingerPrintCredentialViewController;

- (void)moveToCardCredentialViewController;

- (BOOL)verifyUserIDByNumber:(NSString*)ID;

- (BOOL)verifyUserID;

- (BOOL)verifyUserEmail;

- (BOOL)verifyPeriod;

- (BOOL)verifyOperator;

- (void)showOneButtonPopup:(OneButtonPopupType)type withMessage:(NSString*)message;

- (void)showImageButtonPopup:(ImagePopupType)type title:(NSString*)title message:(NSString*)message;

- (void)showPinPopup:(PinPopupType)type;

- (void)showPinPopupAfterAPICall:(PinPopupType)type;

- (void)modifyUser:(User*)user;

- (void)createUser:(User*)user;

- (void)updateMyProfile:(User*)user;

- (void)deleteUserInfo:(NSString*)deleteUserID;

- (void)getUser:(NSString*)ID;

- (IBAction)moveToMonitoring:(id)sender;


- (IBAction)moveToBack:(id)sender;
- (IBAction)updateUserInfo:(id)sender;
- (IBAction)switchEditMode:(id)sender;
- (IBAction)showStartDatePopup:(id)sender;
- (IBAction)showExpireDatePopup:(id)sender;
- (IBAction)deleteUser:(id)sender;
- (IBAction)showPhotoPopup:(id)sender;

@end
