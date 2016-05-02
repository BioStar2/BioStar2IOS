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

#define SIDE_MENU_VELOCOTY      600



@interface ViewController : BaseViewController <UserProviderDelegate, DoorProviderDelegate,UIActionSheetDelegate, EventProviderDelegate, PreferenceProviderDelegate, ImagePopupDelegate, UserDetailDelegate, AuthProviderDelegate>
{
    __weak IBOutlet UIView *infoBackgroundView;
    __weak IBOutlet UILabel *userButtonLabel;
    __weak IBOutlet UILabel *doorButtonLabel;
    __weak IBOutlet UILabel *monitorButtonLabel;
    __weak IBOutlet UILabel *alarmButtonLabel;
    __weak IBOutlet UILabel *AMLabel;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIView *sidemenuView;
    __weak IBOutlet NSLayoutConstraint *sidemenuConstraint;
    __weak IBOutlet UIView *blackAlphaView;
    __weak IBOutlet UIButton *closeButton;
    __weak IBOutlet UIView *sidemenuBottonView;
    __weak IBOutlet UIView *userView;
    __weak IBOutlet UIView *doorView;
    __weak IBOutlet UIView *monitoringView;
    __weak IBOutlet UIView *alarmView;
    __weak IBOutlet UIView *bottomView;
    __weak IBOutlet UILabel *versionLabel;
    __weak IBOutlet UIView *alarmCountView;
    
    __weak IBOutlet UIImageView *userImageView;
    __weak IBOutlet UIImageView *userCountImageView;
    __weak IBOutlet UILabel *userCountLabel;
    
    __weak IBOutlet UIImageView *doorImageView;
    __weak IBOutlet UIImageView *doorCountImageView;
    __weak IBOutlet UILabel *doorCountLabel;
    
    __weak IBOutlet UIImageView *mornitorImageView;
    
    __weak IBOutlet UIImageView *alarmImageView;
    __weak IBOutlet UIImageView *alarmCountImage;
    __weak IBOutlet UILabel *alarmCountLabel;
    
    __weak IBOutlet UILabel *userName;
    __weak IBOutlet UILabel *userOperator;
    __weak IBOutlet UIImageView *userPhoto;
    
    __weak IBOutlet UIView *badgeView;
    __weak IBOutlet NSLayoutConstraint *badgeViewWidthConstraint;
    __weak IBOutlet UILabel *badgeNumberLabel;
    
    
    CAGradientLayer *infoBackgroundGradient;
    CAGradientLayer *infoPressedGradient;
    CAGradientLayer *userGradient;
    CAGradientLayer *doorGradient;
    CAGradientLayer *monitorGradient;
    CAGradientLayer *alarmGradient;
    CAGradientLayer *pressedGradient;
    
    NSTimer *timer;
    BOOL isSidemenuOpen;
    BOOL isGetUsersInfoFailed;
    BOOL isGetDoorsFailed;
    BOOL isGetEventMessageFailed;
    BOOL isGetPreferenceFailed;
    BOOL isLogoutFailed;
    BOOL hasNewAlarm;
    BOOL isGradientLoaded;
    CGPoint draggingPoint;
    NSInteger requestCount;
    
    
    UserProvider *userProvider;
    DoorProvider *doorProvider;
    EventProvider *eventProvider;
    PreferenceProvider *preferenceProvoder;
    AuthProvider *authProvider;
    NSMutableDictionary *preferenceDic;
    __weak IBOutlet UILabel *buildVersionButton;
}

@property (strong, nonatomic) NSDictionary *userDic;

- (IBAction)showSlideMenu:(id)sender;

- (IBAction)moveToUserController:(id)sender;
- (IBAction)moveToDoorController:(id)sender;
- (IBAction)moveToMonitorController:(id)sender;
- (IBAction)moveToAlarmController:(id)sender;
- (IBAction)showBuildVersion:(id)sender;

- (IBAction)userButtonDown:(id)sender;
- (IBAction)doorButtonDown:(id)sender;
- (IBAction)monitorButtonDown:(id)sender;
- (IBAction)alarmButtonDown:(id)sender;

- (IBAction)userButtonTouchUpOutside:(id)sender;
- (IBAction)doorButtonTouchUpOutside:(id)sender;
- (IBAction)monitorButtonTouchUpOutside:(id)sender;
- (IBAction)alarmButtonTouchUpOutside:(id)sender;

- (IBAction)closeSideMenuView:(id)sender;

- (IBAction)userMenuButtonTouchUpInside:(id)sender;
- (IBAction)userMenuButtonTouchUpOutside:(id)sender;
- (IBAction)userMenuButtonTouchDown:(id)sender;

- (IBAction)doorMenuButtonTouchUpInside:(id)sender;
- (IBAction)doorMenuButtonTouchUpOutside:(id)sender;
- (IBAction)doorMenuButtonTouchDown:(id)sender;

- (IBAction)monitorMenuButtonTouchUpInside:(id)sender;
- (IBAction)monitorMenuButtonTouchUpOutside:(id)sender;
- (IBAction)monitorMenuButtonTouchDown:(id)sender;

- (IBAction)alarmMenuButtonTouchUpInside:(id)sender;
- (IBAction)alarmMenuButtonTouchUpOutside:(id)sender;
- (IBAction)alarmMenuButtonTouchDown:(id)sender;

- (IBAction)moveToHome:(id)sender;
- (IBAction)profileButtonTouchDown:(UIButton *)sender;
- (IBAction)moveToPreperence:(id)sender;
- (IBAction)profileButtonTouchUpOutside:(UIButton *)sender;
- (IBAction)moveToMyProfile:(id)sender;
- (IBAction)logout:(id)sender;

- (void)setAlarmCount;
- (void)openSideMenu:(NSInteger)velocity;
- (void)closeSideMenu:(NSInteger)velocity;
- (void)checkRequestCount;
- (void)setGradation;
- (void)backToLoginController;
- (void)updateDoorCount:(NSInteger)doorCount;
- (void)updateUserCount:(NSInteger)userCount;
- (CGRect)getCurrentViewFrame:(CGRect)bounds;
- (void)setBadgeViewWidth;
- (void)loadMyprofile;
@end

