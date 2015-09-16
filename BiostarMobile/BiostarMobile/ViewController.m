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

#import "ViewController.h"
#import "CommonUtil.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    isSidemenuOpen = NO;
    
    isGetDoorsFailed = NO;
    isGetEventMessageFailed = NO;
    isGetUsersInfoFailed = NO;
    isGetPreferenceFailed = NO;
    isLogoutFailed = NO;
    hasNewAlarm = NO;
    isGradientLoaded = NO;
    
    UIScreenEdgePanGestureRecognizer *edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePan:)];
    edgePanGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:edgePanGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [sidemenuView addGestureRecognizer:panGesture];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleVersion"];
    versionLabel.text = [NSString stringWithFormat:@"V.%@", version];
    
    authProvider = [[AuthProvider alloc] init];
    authProvider.delegate = self;
    // 사용자 수 가져오기
    userProvider = [[UserProvider alloc] init];
    userProvider.delegate = self;
    [userProvider getUsersOffset:0 limit:10 groupID:@"1" query:nil];
    requestCount++;
    
    // 도어 수 가져오기
    doorProvider = [[DoorProvider alloc] init];
    doorProvider.delegate = self;
    [doorProvider getDoors];
    requestCount++;
    
    // 알람 카운트 셋팅
    [self setAlarmCount];
    
    // 이벤트 메세지 셋팅
    eventProvider = [[EventProvider alloc] init];
    eventProvider.delegate = self;
    [eventProvider getEventMessage];
    requestCount++;
    
    // 프리프런스 가져오기
    preferenceProvoder = [[PreferenceProvider alloc] init];
    preferenceProvoder.delegate = self;
    [preferenceProvoder getPreferenceProvider];
    
    requestCount++;
    
    [self startLoading:self];
    
    // 사용자, 도어, 알람 갯수 노트 옵저버 등록하기
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userCountUpdated:)
                                                 name:USER_COUNT_UPDATE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doorCountUpdated:)
                                                 name:DOOR_COUNT_UPDATE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(alarmCountUpdated:)
                                                 name:ALARM_COUNT_UPDATE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationIsOccured:)
                                                 name:PUSH_HAS_BEEN_OCCURED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveToAlarmByNoti)
                                                 name:MOVING_TO_ALARM
                                               object:nil];
    
    
}

- (void)setAlarmCount
{
    // 알람 수 가져오기
    if (![AuthProvider hasWritePermission:@"DOOR"])
    {
        [alarmCountView setHidden:YES];
    }
    else
    {
        [alarmCountView setHidden:NO];
        alarmCountLabel.text = [[_userDic objectForKey:@"unread_notification_count"] stringValue];
        
        NSInteger newBadgeCount = [[_userDic objectForKey:@"unread_notification_count"] integerValue];
        
        UIApplication *application = [UIApplication sharedApplication];
        
        if (newBadgeCount != 0)
        {
            application.applicationIconBadgeNumber = newBadgeCount;
            hasNewAlarm = YES;
            [alarmCountImage setImage:[UIImage imageNamed:@"list_new_btn"]];
        }
        else
        {
            hasNewAlarm = NO;
            [alarmCountImage setImage:[UIImage imageNamed:@"list_normal_btn"]];
        }
        
        NSNumber *alarmCount = [NSNumber numberWithInteger:[[_userDic objectForKey:@"unread_notification_count"] integerValue]];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:alarmCount forKey:@"AlarmCount"];
        [userDefaults synchronize];
        
        badgeNumberLabel.text = alarmCountLabel.text;
        
    }
    [self setBadgeViewWidth];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (isGradientLoaded)
    {
        return;
    }
    [self setGradation];
    
    pressedGradient  = [CAGradientLayer layer];
    pressedGradient.frame = [self getCurrentViewFrame:userView.bounds];
    pressedGradient.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x362c2f).CGColor, (id)UIColorFromRGB(0x362c2f).CGColor, nil];
    
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    pressedGradient.locations = gradientLocations;
    
    infoPressedGradient  = [CAGradientLayer layer];
    infoPressedGradient.frame = [self getCurrentViewFrame:infoBackgroundView.bounds];
    infoPressedGradient.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x362c2f).CGColor, (id)UIColorFromRGB(0x362c2f).CGColor, nil];
    
    infoPressedGradient.locations = gradientLocations;
    
    isGradientLoaded = YES;
    
}

- (CGRect)getCurrentViewFrame:(CGRect)bounds
{
    CGRect frame = bounds;
    frame.size.width = sidemenuView.frame.size.width;
    
    return frame;
}

- (void)setGradation
{
    infoBackgroundGradient = [CAGradientLayer layer];
    infoBackgroundGradient.frame = [self getCurrentViewFrame:infoBackgroundView.bounds];
    infoBackgroundGradient.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x4d3d40).CGColor, (id)UIColorFromRGB(0x4e3f42).CGColor, nil];
    
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    infoBackgroundGradient.locations = gradientLocations;
    
    [infoBackgroundView.layer insertSublayer:infoBackgroundGradient atIndex:0];
    
    userGradient = [CAGradientLayer layer];
    userGradient.frame = [self getCurrentViewFrame:userView.bounds];
    userGradient.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x4e3f42).CGColor, (id)UIColorFromRGB(0x4d3f42).CGColor, nil];
    
    gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    userGradient.locations = gradientLocations;
    
    [userView.layer insertSublayer:userGradient atIndex:0];
    
    doorGradient = [CAGradientLayer layer];
    doorGradient.frame = [self getCurrentViewFrame:doorView.bounds];
    doorGradient.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x4d3f42).CGColor, (id)UIColorFromRGB(0x4b3e41).CGColor, nil];
    
    gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    doorGradient.locations = gradientLocations;
    
    [doorView.layer insertSublayer:doorGradient atIndex:0];
    
    
    monitorGradient = [CAGradientLayer layer];
    monitorGradient.frame = [self getCurrentViewFrame:monitoringView.bounds];
    monitorGradient.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x4b3e41).CGColor, (id)UIColorFromRGB(0x473c3f).CGColor, nil];
    
    gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    monitorGradient.locations = gradientLocations;
    
    [monitoringView.layer insertSublayer:monitorGradient atIndex:0];
    
    
    alarmGradient = [CAGradientLayer layer];
    alarmGradient.frame = [self getCurrentViewFrame:alarmView.bounds];
    alarmGradient.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x473c3f).CGColor, (id)UIColorFromRGB(0x443a3d).CGColor, nil];
    
    gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    alarmGradient.locations = gradientLocations;
    
    [alarmView.layer insertSublayer:alarmGradient atIndex:0];

    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self getCurrentViewFrame:bottomView.bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x443a3d).CGColor,UIColorFromRGB(0x342e30).CGColor, nil];
    
    gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    gradient.locations = gradientLocations;
    
    [bottomView.layer insertSublayer:gradient atIndex:0];
}

- (void)setBadgeViewWidth
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:badgeNumberLabel.font, NSFontAttributeName, nil];
    CGFloat width = [[[NSAttributedString alloc] initWithString:badgeNumberLabel.text attributes:attributes] size].width;
    
    badgeViewWidthConstraint.constant = width + 16;
    
    NSInteger badgeNumber = [badgeNumberLabel.text integerValue];
    
    if (badgeNumber > 999)
    {
        badgeNumberLabel.text = @"999+";
    }
    
    if ([badgeNumberLabel.text isEqualToString:@"0"] || [badgeNumberLabel.text isEqualToString:@""])
    {
        [badgeView setHidden:YES];
    }
    else
    {
        [badgeView setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    userName.text = [_userDic objectForKey:@"name"];
    NSArray *roles = [_userDic objectForKey:@"roles"];
    userOperator.text = [[roles lastObject] objectForKey:@"description"];
    
    if (nil != [_userDic objectForKey:@"photo"])
    {
        NSData *imageData = [NSData base64DataFromString:[_userDic objectForKey:@"photo"]];
        UIImage *userImage = [UIImage imageWithData:imageData];
        
        UIImage *image = [CommonUtil imageWithImage:userImage scaledToSize:CGSizeMake(30, 30)];
        
        userPhoto.image = image;
        
        userPhoto.layer.cornerRadius = userPhoto.frame.size.height /2;
        userPhoto.layer.masksToBounds = YES;
        userPhoto.layer.borderWidth = 0;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateWatch) userInfo:nil repeats:YES];
    [self updateWatch];
}

- (void)setUserDic:(NSDictionary *)userDic
{
    _userDic = userDic;
}

- (void)updateWatch
{
    NSDate *date = [NSDate date];
    NSString *currentTime = [CommonUtil stringFromCurrentLocaleDateString:[date description]
                                                         originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                          transDateFormat:@"a hh:mm MM/dd, EEE  "];
    
    NSArray *timeArray = [currentTime componentsSeparatedByString:@" "];
    
    NSString *isoCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    AMLabel.text = [timeArray objectAtIndex:0];
    timeLabel.text = [timeArray objectAtIndex:1];
    
    if ([isoCode isEqualToString:@"ko"])
    {
        NSString *day = [NSString stringWithFormat:@"%@요일", [timeArray objectAtIndex:3]];
        dateLabel.text = [NSString stringWithFormat:@"%@ %@",[timeArray objectAtIndex:2]
                          ,day];
    }
    else
    {
        dateLabel.text = [NSString stringWithFormat:@"%@ %@",[timeArray objectAtIndex:2]
                          ,[timeArray objectAtIndex:3]];
    }
}


- (IBAction)showSlideMenu:(id)sender {
    [self openSideMenu:10];
}

- (IBAction)moveToUserController:(id)sender
{
    [userButtonLabel setTextColor:[UIColor colorWithRed:172/255.0 green:169/255.0 blue:161/255.0 alpha:1]];
    
    if (![AuthProvider hasReadPermission:@"USER"])
    {
        [self.view makeToast:NSLocalizedString(@"no_permission", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        return;
    }
    
    [self popToRootViewController];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UsersViewController *usersViewController = [storyboard instantiateViewControllerWithIdentifier:@"UsersViewController"];

    [self pushChildViewController:usersViewController
             parentViewController:self
                      contentView:contentView animated:YES];
    
}

- (IBAction)moveToDoorController:(id)sender
{
    [doorButtonLabel setTextColor:[UIColor colorWithRed:172/255.0 green:169/255.0 blue:161/255.0 alpha:1]];
    
    if (![AuthProvider hasReadPermission:@"DOOR"])
    {
        [self.view makeToast:NSLocalizedString(@"no_permission", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        return;
    }
    
    [self popToRootViewController];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DoorsViewController *doorsViewController = [storyboard instantiateViewControllerWithIdentifier:@"DoorsViewController"];
    
    [self pushChildViewController:doorsViewController
             parentViewController:self
                      contentView:contentView animated:YES];
    
}

- (IBAction)moveToMonitorController:(id)sender
{
    [monitorButtonLabel setTextColor:[UIColor colorWithRed:172/255.0
                                                     green:169/255.0
                                                      blue:161/255.0 alpha:1]];
    
    if (![AuthProvider hasReadPermission:@"MONITORING"])
    {
        [self.view makeToast:NSLocalizedString(@"no_permission", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        return;
    }
    
    [self popToRootViewController];
    
//    [timer invalidate];
//    timer = nil;
    
    [MonitorFilterViewController setResetFilter:NO];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MonitoringViewController *monitoringViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitoringViewController"];
    monitoringViewController.requestType = EVENT_MONITOR;
    [self pushChildViewController:monitoringViewController
             parentViewController:self
                      contentView:contentView animated:YES];
}

- (IBAction)moveToAlarmController:(id)sender
{
    [alarmButtonLabel setTextColor:[UIColor colorWithRed:172/255.0
                                                   green:169/255.0
                                                    blue:161/255.0 alpha:1]];
    
    if (![AuthProvider hasWritePermission:@"DOOR"])
    {
        [self.view makeToast:NSLocalizedString(@"no_permission", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        return;
    }
    
    [self popToRootViewController];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AlarmViewController *alarmViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmViewController"];
    [self pushChildViewController:alarmViewController
             parentViewController:self
                      contentView:contentView animated:YES];
    
}

- (IBAction)userButtonDown:(id)sender {
    [userButtonLabel setTextColor:[UIColor colorWithRed:255/255.0 green:211/255.0 blue:131/255.0 alpha:1]];
}

- (IBAction)doorButtonDown:(id)sender {
    [doorButtonLabel setTextColor:[UIColor colorWithRed:255/255.0 green:211/255.0 blue:131/255.0 alpha:1]];
}

- (IBAction)monitorButtonDown:(id)sender {
    [monitorButtonLabel setTextColor:[UIColor colorWithRed:255/255.0 green:211/255.0 blue:131/255.0 alpha:1]];
}

- (IBAction)alarmButtonDown:(id)sender {
    [alarmButtonLabel setTextColor:[UIColor colorWithRed:255/255.0 green:211/255.0 blue:131/255.0 alpha:1]];
}

- (IBAction)userButtonTouchUpOutside:(id)sender {
    [userButtonLabel setTextColor:[UIColor colorWithRed:172/255.0 green:169/255.0 blue:161/255.0 alpha:1]];
}

- (IBAction)doorButtonTouchUpOutside:(id)sender {
    [doorButtonLabel setTextColor:[UIColor colorWithRed:172/255.0 green:169/255.0 blue:161/255.0 alpha:1]];
}

- (IBAction)monitorButtonTouchUpOutside:(id)sender {
    [monitorButtonLabel setTextColor:[UIColor colorWithRed:172/255.0 green:169/255.0 blue:161/255.0 alpha:1]];
}

- (IBAction)alarmButtonTouchUpOutside:(id)sender {
    [alarmButtonLabel setTextColor:[UIColor colorWithRed:172 green:169 blue:161 alpha:1]];
}

- (IBAction)closeSideMenuView:(id)sender
{
    [self closeSideMenu:10];
}

- (IBAction)userMenuButtonTouchUpInside:(id)sender
{
    [userView.layer replaceSublayer:[userView.layer.sublayers objectAtIndex:0]
                               with:userGradient];
    [userCountImageView setImage:[UIImage imageNamed:@"list_normal_btn"]];
    [self moveToUserController:nil];
    [self closeSideMenu:10];
    
}

- (IBAction)userMenuButtonTouchUpOutside:(id)sender
{
    [userView.layer replaceSublayer:[userView.layer.sublayers objectAtIndex:0]
                               with:userGradient];
    [userCountImageView setImage:[UIImage imageNamed:@"list_normal_btn"]];
}

- (IBAction)userMenuButtonTouchDown:(id)sender
{
    [userView.layer replaceSublayer:[userView.layer.sublayers objectAtIndex:0]
                               with:pressedGradient];
    [userCountImageView setImage:[UIImage imageNamed:@"list_btn_pre"]];
}

- (IBAction)doorMenuButtonTouchUpInside:(id)sender
{
    [doorView.layer replaceSublayer:[doorView.layer.sublayers objectAtIndex:0]
                               with:doorGradient];
    [doorCountImageView setImage:[UIImage imageNamed:@"list_normal_btn"]];
    [self closeSideMenu:10];
    [self moveToDoorController:nil];
}

- (IBAction)doorMenuButtonTouchUpOutside:(id)sender
{
    [doorView.layer replaceSublayer:[doorView.layer.sublayers objectAtIndex:0]
                               with:doorGradient];
    [doorCountImageView setImage:[UIImage imageNamed:@"list_normal_btn"]];
}

- (IBAction)doorMenuButtonTouchDown:(id)sender
{
    [doorView.layer replaceSublayer:[doorView.layer.sublayers objectAtIndex:0]
                               with:pressedGradient];
    [doorCountImageView setImage:[UIImage imageNamed:@"list_btn_pre"]];
}

- (IBAction)monitorMenuButtonTouchUpInside:(id)sender
{
    [monitoringView.layer replaceSublayer:[monitoringView.layer.sublayers objectAtIndex:0]
                                     with:monitorGradient];
    [self closeSideMenu:10];
    [self moveToMonitorController:nil];
}

- (IBAction)monitorMenuButtonTouchUpOutside:(id)sender
{
    [monitoringView.layer replaceSublayer:[monitoringView.layer.sublayers objectAtIndex:0]
                                     with:monitorGradient];
}

- (IBAction)monitorMenuButtonTouchDown:(id)sender
{
    [monitoringView.layer replaceSublayer:[monitoringView.layer.sublayers objectAtIndex:0]
                                     with:pressedGradient];
}

- (IBAction)alarmMenuButtonTouchUpInside:(id)sender
{
    [alarmView.layer replaceSublayer:[alarmView.layer.sublayers objectAtIndex:0]
                                with:alarmGradient];
    if (hasNewAlarm)
    {
        [alarmCountImage setImage:[UIImage imageNamed:@"list_new_btn"]];
    }
    else
    {
        [alarmCountImage setImage:[UIImage imageNamed:@"list_normal_btn"]];
    }
    
    [self closeSideMenu:10];
    [self moveToAlarmController:nil];
}

- (IBAction)alarmMenuButtonTouchUpOutside:(id)sender
{
    [alarmView.layer replaceSublayer:[alarmView.layer.sublayers objectAtIndex:0]
                                with:alarmGradient];
    [alarmCountImage setImage:[UIImage imageNamed:@"list_normal_btn"]];
}

- (IBAction)alarmMenuButtonTouchDown:(id)sender
{
    [alarmView.layer replaceSublayer:[alarmView.layer.sublayers objectAtIndex:0]
                                with:pressedGradient];
    [alarmCountImage setImage:[UIImage imageNamed:@"list_btn_pre"]];
}

- (IBAction)moveToHome:(id)sender
{
    [self closeSideMenu:10];
    [self popToRootViewController];
}



- (IBAction)moveToPreperence:(id)sender
{
    [self closeSideMenu:10];
    [self popToRootViewController];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingViewController *settingViewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    
    [settingViewController setUserID:[_userDic objectForKey:@"user_id"]];
    [self pushChildViewController:settingViewController
             parentViewController:self
                      contentView:contentView animated:YES];
}

- (IBAction)profileButtonTouchUpOutside:(UIButton *)sender {
    [infoBackgroundView.layer replaceSublayer:[infoBackgroundView.layer.sublayers objectAtIndex:0]
                                         with:infoBackgroundGradient];
}

- (IBAction)profileButtonTouchDown:(UIButton *)sender {
    
    [infoBackgroundView.layer replaceSublayer:[infoBackgroundView.layer.sublayers objectAtIndex:0]
                                         with:infoPressedGradient];
}

- (IBAction)moveToMyProfile:(id)sender
{
    [self closeSideMenu:10];
    [self popToRootViewController];
    
    [infoBackgroundView.layer replaceSublayer:[infoBackgroundView.layer.sublayers objectAtIndex:0]
                                         with:infoBackgroundGradient];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserNewDetailViewController __weak *userDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
    userDetailViewController.delegate = self;
    [userDetailViewController getUserInfo:[_userDic valueForKey:@"user_id"]];
    [userDetailViewController setType:PROFILE_MODE];
    [self pushChildViewController:userDetailViewController
             parentViewController:self
                      contentView:contentView animated:YES];
}

- (IBAction)logout:(id)sender
{
    [authProvider logout];
    [self startLoading:self];
    
}



- (void)handleEdgePan:(UIScreenEdgePanGestureRecognizer *)sender {

    if (isLoading)
    {
        return;
    }
    
    if (isSidemenuOpen)
    {
        return;
    }
    
    [sidemenuView setHidden:NO];
    
    CGPoint translatedPoint = [sender translationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    
    sidemenuConstraint.constant = translatedPoint.x - sidemenuView.frame.size.width;
    
    blackAlphaView.alpha = (sidemenuConstraint.constant + sidemenuView.frame.size.width) / self.view.frame.size.width;
    
    if (blackAlphaView.alpha > 0.8)
    {
        blackAlphaView.alpha = 0.8;
    }
    
    if (sidemenuConstraint.constant > 0)
        sidemenuConstraint.constant = 0;
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        NSInteger positiveVelocity = (velocity.x > 0) ? velocity.x : velocity.x * -1;
        
        if (positiveVelocity >= SIDE_MENU_VELOCOTY)
        {
            if (velocity.x > 0)
            {
                [self openSideMenu:velocity.x];
            }
            else
            {
                [self closeSideMenu:velocity.x];
            }
        }
        else
        {
            if (sidemenuConstraint.constant > -translatedPoint.x)
            {
                [self openSideMenu:velocity.x];
            }
            else
            {
                [self closeSideMenu:velocity.x];
            }
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    
    if (!isSidemenuOpen)
    {
        return;
    }
    
    [sidemenuView setHidden:NO];
    
    CGPoint translatedPoint = [sender translationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    
    sidemenuConstraint.constant = translatedPoint.x;
    
    blackAlphaView.alpha = (sidemenuConstraint.constant + sidemenuView.frame.size.width) / self.view.frame.size.width;
    
    if (blackAlphaView.alpha > 0.8)
    {
        blackAlphaView.alpha = 0.8;
    }
    
    if (sidemenuConstraint.constant > 0)
        sidemenuConstraint.constant = 0;
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        NSInteger positiveVelocity = (velocity.x > 0) ? velocity.x : velocity.x * -1;
        
        if (positiveVelocity >= SIDE_MENU_VELOCOTY)
        {
            if (velocity.x > 0)
            {
                [self openSideMenu:velocity.x];
            }
            else
            {
                [self closeSideMenu:velocity.x];
            }
        }
        else
        {
            if (sidemenuConstraint.constant > -sidemenuView.frame.size.width/2 )
            {
                [self openSideMenu:velocity.x];
            }
            else
            {
                [self closeSideMenu:velocity.x];
            }
        }
    }
}

- (void)openSideMenu:(NSInteger)velocity
{
    [sidemenuView setHidden:NO];
    
    [self.view layoutIfNeeded];
    NSTimeInterval duration = labs(3000 - velocity)*.0002;// + 0.1;
    if (duration > 0.3)
    {
        duration = 0.1;
    }
    sidemenuConstraint.constant = 0;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        [self.view layoutIfNeeded];
        blackAlphaView.alpha = 0.8;
        
    } completion:^(BOOL finished) {
        isSidemenuOpen = YES;
        blackAlphaView.alpha = 0.8;
        [closeButton setHidden:NO];
    }];
    
}

- (void)closeSideMenu:(NSInteger)velocity
{
    [self.view layoutIfNeeded];
    NSTimeInterval duration = labs(-3000-velocity)*.0002;//+ 0.1;
    
    if (duration > 0.3)
    {
        duration = 0.1;
    }
    
    sidemenuConstraint.constant = -sidemenuView.frame.size.width;
    [UIView animateWithDuration:duration delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
    {
        
        [self.view layoutIfNeeded];
        blackAlphaView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        isSidemenuOpen = NO;
        [sidemenuView setHidden:YES];
        blackAlphaView.alpha = 0.0;
        [closeButton setHidden:YES];
    }];
    
}

- (void)backToLoginController
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"hasCookie"];
    
    NSHTTPCookieStorage * sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray * cookies = [sharedCookieStorage cookies];
    for (NSHTTPCookie * cookie in cookies)
    {
        NSLog(@"%@",cookie.domain);
        NSLog(@"cookie : %@", cookie);
        [sharedCookieStorage deleteCookie:cookie];
    }
    
    [userDefaults synchronize];
    
    [NetworkController resetSharedInstance];
    [self popToRootViewController];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)checkRequestCount
{
    requestCount--;
    
    if (requestCount == 0)
    {
        [self finishLoading];
    }
}

- (void)updateDoorCount:(NSInteger)doorCount
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSInteger preDoorCount = [[userdefaults objectForKey:@"DoorCount"] integerValue];
    if (preDoorCount > doorCount)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:doorCount]
                                                  forKey:@"DoorCount"];
        // 뷰 색 변경
        [doorCountImageView setImage:[UIImage imageNamed:@"list_new_btn"]];
    }
}

- (void)updateUserCount:(NSInteger)userCount
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSInteger preUserCount = [[userdefaults objectForKey:@"UserCount"] integerValue];
    if (preUserCount > userCount)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:userCount]
                                                  forKey:@"UserCount"];
        // 뷰 색 변경
        [userCountImageView setImage:[UIImage imageNamed:@"list_new_btn"]];
    }
}

#pragma mark - NotificationCenter method


- (void)userCountUpdated:(NSNotification*)userInfo
{
    
    NSInteger userCount = [[userInfo.object objectForKey:@"count"] integerValue];
    
    [self updateUserCount:userCount];
    
    userCountLabel.text = [NSString stringWithFormat:@"%ld", (long)userCount];
}

- (void)doorCountUpdated:(NSNotification*)userInfo
{
    NSInteger doorCount = [[userInfo.object objectForKey:@"count"] integerValue];
    
    [self updateDoorCount:doorCount];
    
    doorCountLabel.text = [NSString stringWithFormat:@"%ld", (long)doorCount];
}

- (void)alarmCountUpdated:(NSNotification*)userInfo
{
    NSInteger deletedNewAlarmCount = [[userInfo.object objectForKey:@"count"] integerValue];
    
    UIApplication *application = [UIApplication sharedApplication];
    NSInteger badgeCount = application.applicationIconBadgeNumber;
    badgeCount = badgeCount - deletedNewAlarmCount;
    if (badgeCount < 0)
    {
        badgeCount = 0;
    }
    application.applicationIconBadgeNumber = badgeCount;
    alarmCountLabel.text = [NSString stringWithFormat:@"%ld", (long)badgeCount];
    
    badgeNumberLabel.text = alarmCountLabel.text;
    [self setBadgeViewWidth];
    
    if (application.applicationIconBadgeNumber == 0)
    {
        [alarmCountImage setImage:[UIImage imageNamed:@"list_normal_btn"]];
    }
}

- (void)notificationIsOccured:(NSNotification*)userInfo
{
    if (nil != [[userInfo.object objectForKey:@"aps"] objectForKey:@"badge"])
    {
        alarmCountLabel.text = [[[userInfo.object objectForKey:@"aps"] objectForKey:@"badge"] stringValue];
        
        badgeNumberLabel.text = alarmCountLabel.text;
        [self setBadgeViewWidth];
    }
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    NotiPopupController *notiPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"NotiPopupController"];
    [notiPopupCtrl setNotiDic:userInfo.object];
    [self showPopup:notiPopupCtrl parentViewController:self parentView:self.view];
}

- (void)moveToAlarmByNoti
{
    [self moveToAlarmController:nil];
}

#pragma mark - UserProviderDelegate

- (void)requestDidFinishGettingUsersInfo:(NSArray*)userArray totclCount:(NSInteger)count
{
    [self updateUserCount:count];
    
    isGetUsersInfoFailed = NO;
    userCountLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    [self checkRequestCount];
}

- (void)requestDidFinishGettingMyProfile:(NSDictionary*)result
{
    NSLog(@"requestDidFinishGettingMyProfile : %@", result);
}

- (void)requestUserProviderDidFail:(NSDictionary*)errDic
{
    isGetUsersInfoFailed = YES;
    [self checkRequestCount];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}


#pragma mark - DoorProviderDelegate

- (void)requestGetDoorsDidFinish:(NSArray*)doorArray totalCount:(NSInteger)total
{
    [self updateDoorCount:total];
    
    isGetDoorsFailed = NO;
    doorCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)total];
    [self checkRequestCount];
}

- (void)requestDoorProviderDidFail:(NSDictionary*)errDic
{
    isGetDoorsFailed = YES;
    NSLog(@"requestDoorProviderDidFail");
    [self checkRequestCount];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - EventProviderDelegate

- (void)requestGetEventMessageDidFinish:(NSArray *)eventTypes
{
    isGetEventMessageFailed = NO;
    [self checkRequestCount];
}

- (void)requestEventProviderDidFail:(NSDictionary*)errDic
{
    isGetEventMessageFailed = YES;
    NSLog(@"requestEventProviderDidFail");
    [self checkRequestCount];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - PreferenceProviderDelegate
- (void)requestGetPreferenceDidFinish:(NSDictionary*)_preferenceDic
{
    isGetPreferenceFailed = NO;
    preferenceDic = [[NSMutableDictionary alloc] initWithDictionary:_preferenceDic];
    [self checkRequestCount];
    
}


- (void)requestPreferenceProviderDidFail:(NSDictionary*)errDic
{
    isGetPreferenceFailed = YES;
    NSLog(@"requestPreferenceProviderDidFail");
    [self checkRequestCount];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - AuthProviderDelegate

- (void)logoutDidFinish:(NSDictionary*)userInfo
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    [self finishLoading];
    
    [self backToLoginController];
}

- (void)logoutDidFail:(NSDictionary*)errDic
{
    isLogoutFailed = YES;
    [self finishLoading];
    [self closeSideMenu:10];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - ImagePopupDelegate

- (void)cancelImagePopup
{
    // 4개의 API 중 하나라도 실패하면 앱 실행에 필요한 데이터가 없어 로그인 페이지로 이동
    [self logout:nil];
}

- (void)confirmImagePopup
{
    if (isGetUsersInfoFailed)
    {
        [userProvider getUsersOffset:0 limit:10 groupID:@"1" query:nil];
        [self startLoading:self];
        requestCount++;
        isGetUsersInfoFailed = NO;
        return;
    }
    
    if (isGetDoorsFailed)
    {
        [doorProvider getDoors];
        [self startLoading:self];
        requestCount++;
        isGetDoorsFailed = NO;
        return;
    }
    
    if (isGetEventMessageFailed)
    {
        [eventProvider getEventMessage];
        [self startLoading:self];
        requestCount++;
        isGetEventMessageFailed = NO;
        return;
    }
    
    if (isGetPreferenceFailed)
    {
        [preferenceProvoder getPreferenceProvider];
        [self startLoading:self];
        requestCount++;
        isGetPreferenceFailed = NO;
        return;
    }
    
    if (isLogoutFailed)
    {
        [self backToLoginController];
        isLogoutFailed = NO;
        return;
    }
}

#pragma mark - UserDetailDelegate

- (void)needToReloadUsers
{
    NSLog(@"needToRefreshUsers");
    [userProvider getMyProfile];
    [self startLoading:self];
    
}
@end
