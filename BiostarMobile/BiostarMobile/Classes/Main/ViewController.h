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
#import "BSNetwork.h"
#import "AuthProvider.h"
#import "UserProvider.h"
#import "DoorProvider.h"
#import "EventProvider.h"
#import "UsersViewController.h"
#import "DoorsViewController.h"
#import "MonitoringViewController.h"
#import "SettingViewController.h"
#import "PreferenceProvider.h"
#import "ImagePopupViewController.h"
#import "UserNewDetailViewController.h"
#import "AlarmViewController.h"
#import "MonitorFilterViewController.h"
#import "NotiPopupController.h"
#import "SideMenuCell.h"
#import "HelpViewController.h"
#import "MobileCardViewController.h"
#import "ButtonModel.h"
#import "LocalDataManager.h"

#define SIDE_MENU_VELOCOTY      600


/**
 *
 *  @brief ViewController is main screen controller
 */

@interface ViewController : BaseViewController <UIActionSheetDelegate, UserDetailDelegate, HelpDelegate>
{
    __weak IBOutlet UIView *infoBackgroundView;
    __weak IBOutlet UILabel *AMLabel;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIView *sidemenuView;
    __weak IBOutlet NSLayoutConstraint *sidemenuConstraint;
    __weak IBOutlet UIView *blackAlphaView;
    __weak IBOutlet UIButton *closeButton;
    __weak IBOutlet UIView *sidemenuBottonView;
    __weak IBOutlet UILabel *versionLabel;
    
    __weak IBOutlet UILabel *userName;
    __weak IBOutlet UILabel *userOperator;
    __weak IBOutlet UIImageView *userPhoto;
    
    __weak IBOutlet UIView *badgeView;
    __weak IBOutlet UIImageView *badgeImageView;
    __weak IBOutlet UILabel *badgeNumberLabel;          // 하단 알람버튼의 알람 갯수
    __weak IBOutlet UIImageView *badgeAlertView;
    __weak IBOutlet UILabel *buildVersionButton;
    __weak IBOutlet NSLayoutConstraint *bottomConstraint;
    
    __weak IBOutlet UITableView *menuTableView;
    IBOutletCollection(UIButton) NSArray *buttons;
    IBOutletCollection(UILabel) NSArray *buttonLabels;
    
    NSLayoutConstraint *badgeWidthConstraint;
    NSLayoutConstraint *badgeTrailingConstraint;
    
    NSTimer *timer;
    BOOL isSidemenuOpen;
    CGPoint draggingPoint;
    NSInteger requestCount;
    
    
    UserProvider *userProvider;
    DoorProvider *doorProvider;
    EventProvider *eventProvider;
    PreferenceProvider *preferenceProvoder;
    AuthProvider *authProvider;
    
    NSMutableArray <ButtonModel*> *buttonDatas;
    NSMutableArray <ButtonModel*> *sideMenuButtons;
    
    SEL buttonsTouchDown;
    SEL buttonsTouchUpOutside;
    SEL buttonsTouchUpInside;
    
    NSInteger badgeCount;
}

typedef enum
{
    USER_FAIL,
    DOOR_FAIL,
    EVENT_FAIL,
    PREFERENCE_FAIL,
    
} FailType;

//@property (strong, nonatomic) User *user;

/**
 *  Get User list to display total user count
 *
 */
- (void)getUserList;

/**
 *  Get Door list to display total door count
 *
 */
- (void)getDoors;

/**
 *  Get Evemt message
 *
 */
- (void)getEventMessage;

/**
 *  Get Setting infomaiton
 *
 */
- (void)getPreference;


- (void)buttonsTouchDown:(UIButton*)sender;
- (void)buttonsTouchUpOutside:(UIButton*)sender;
- (void)buttonsTouchUpInside:(UIButton*)sender;
- (void)showImagePopup:(NSString*)message type:(FailType)failType;
- (IBAction)showSlideMenu:(id)sender;
- (void)moveToUserController;
- (void)moveToDoorController;
- (void)moveToMonitorController;
- (void)moveToAlarmController;
- (IBAction)showBuildVersion:(id)sender;
- (IBAction)closeSideMenuView:(id)sender;
- (IBAction)moveToHome:(id)sender;
- (IBAction)profileButtonTouchDown:(UIButton *)sender;
- (IBAction)moveToPreperence:(id)sender;
- (IBAction)profileButtonTouchUpOutside:(UIButton *)sender;
- (IBAction)moveToMyProfile:(id)sender;
- (void)moveToMobileCard;

/**
 *  Log out and Go to Login view
 *
 */
- (IBAction)logout:(id)sender;

- (void)addBadgeViewConstraint:(UIButton*)button;
- (void)openSideMenu:(NSInteger)velocity;
- (void)closeSideMenu:(NSInteger)velocity;
- (void)checkRequestCount;
- (void)setGradation;
- (void)backToLoginController;
- (CGRect)getCurrentViewFrame:(CGRect)bounds;
- (void)setBadgeViewWidth;
- (void)loadMyprofile;
- (void)setMenuItems;
- (void)setTotalCount:(NSNumber*)count type:(ButtonType)type;

@end

