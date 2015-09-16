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
#import "ListSubInfoPopupViewController.h"
#import "TextPopupViewController.h"
#import "MonitoringViewController.h"
#import "OneButtonTablePopupViewController.h"
#import "ImagePopupViewController.h"
#import "OneButtonPopupViewController.h"
#import "UserDetailSwitchCell.h"
#import "PinPopupViewController.h"
#import "UserDetailOperatorCell.h"
#import "MonitorFilterViewController.h"
#import "SDImageCache.h"

@protocol UserDetailDelegate <NSObject>

- (void)needToReloadUsers;

@end

@interface UserNewDetailViewController : BaseViewController <UserProviderDelegate, MFMailComposeViewControllerDelegate, UserDetailAccCellDelegate, UserVerificationAddViewControllerDelegate, DatePickerDelegate, ListPopupViewControllerDelegate, ListSubInfoPopupDelegate, TextPopupDelegate, OneButtonTableDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePopupDelegate, OneButtonPopupDelegate, SwitchCellDelegate, PinPopupDelegate>
{
    
    __weak IBOutlet UIButton *editButton;
    __weak IBOutlet UIButton *doneButton;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *detailTableView;
    __weak IBOutlet NSLayoutConstraint *tableViewConstraint;
    __weak IBOutlet UIView *editButtonView;
    __weak IBOutlet UIView *titleView;

    
    NSMutableDictionary *userInfoDic;
    NSMutableDictionary *toUpdateUserInfoDic;
    UserProvider *provider;
    NSString *userID;
    BOOL hasOperator;
    BOOL isUpdatedOrDeleted;
    BOOL isForPopupRequest;
}

@property (assign, nonatomic) id <UserDetailDelegate> delegate;
@property (assign, nonatomic) DetailType type;

- (void)getUserInfo:(NSString*)_userID;
- (void)loadUserInfo:(NSDictionary *)userInfo;
- (void)setDefaultPeriod;
- (void)setDefaultUserGroup;
- (void)setUserGroup:(NSDictionary*)userGroup;      // 사용자 리스트에서 필터로 선택한 그룹을 사용자 추가 일때 디폴트로 설정하기
- (void)setDefaultUserID;
- (void)showUserGroupPopup;
- (void)showPeriodPopup;
- (void)moveToVerificationViewController:(VerificationType)type;
- (BOOL)verifyUserID;
- (BOOL)verifyUserEmail;
- (BOOL)verifyPeriod;
- (BOOL)verifyOperator;
- (void)showVerificationPopup:(NSString*)message;

- (IBAction)moveToBack:(id)sender;
- (IBAction)updateUserInfo:(id)sender;
- (IBAction)switchEditMode:(id)sender;
- (IBAction)moveToLog:(id)sender;
- (IBAction)showStartDatePopup:(id)sender;
- (IBAction)showExpireDatePopup:(id)sender;
- (IBAction)deleteUser:(id)sender;
- (IBAction)showPhotoPopup:(id)sender;


@end
