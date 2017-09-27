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


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [logoutBtn setTitle:NSBaseLocalizedString(@"log_out", nil) forState:UIControlStateNormal];
    [self setSharedViewController:self];
    buttonDatas = [[NSMutableArray alloc] init];
    sideMenuButtons = [[NSMutableArray alloc] init];
    isSidemenuOpen = NO;
    
    UIScreenEdgePanGestureRecognizer *edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePan:)];
    edgePanGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:edgePanGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [sidemenuView addGestureRecognizer:panGesture];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString* buildversion = [infoDict objectForKey:@"CFBundleVersion"];
    
    NSString *totalVersion = [NSString stringWithFormat:@"%@.%@",version ,buildversion];
    versionLabel.text = [NSString stringWithFormat:@"V.%@", totalVersion];
    
    authProvider = [[AuthProvider alloc] init];
    
    // 사용자 수 가져오기
    userProvider = [[UserProvider alloc] init];
    
    [self getUserList];
    
    // 도어 수 가져오기
    doorProvider = [[DoorProvider alloc] init];
    [self getDoors];
    
    // 이벤트 메세지 셋팅
    eventProvider = [[EventProvider alloc] init];
    [self getEventMessage];
    
    // 프리프런스 가져오기
    preferenceProvoder = [[PreferenceProvider alloc] init];
    [self getPreference];
    
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loggedInUserUpdated)
                                                 name:LOGGED_IN_USER_UPDATEED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingDidUpdated)
                                                 name:SETTING_DID_UPDATE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needToGetMobileCredendial)
                                                 name:NEED_TO_GET_MOBILE_CREDENTIAL
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(useFaceTemplateForProfilePicture:)
                                                 name:USE_FACE_TEMPLATE
                                               object:nil];
    
    
    //menuTableView.estimatedRowHeight = 63.0;
    menuTableView.rowHeight = UITableViewAutomaticDimension;
    
    badgeCount = [AuthProvider getLoginUserInfo].unread_notification_count;
    
    badgeNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)badgeCount];
    
    [self setMenuItems];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isHomeScreen])
    {
        [self setGradation];
        [self loadMyprofile];
        [self getMobileCredential];
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
    
    NSLog(@"main viewWillAppear");
    transDateFormate = [NSString stringWithFormat:@"%@",[LocalDataManager getDateFormat]];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateWatch) userInfo:nil repeats:YES];
    [self updateWatch];
}



- (void)showImagePopup:(NSString*)message type:(FailType)failType
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:message];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    
    [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
        if (isConfirm)
        {
            switch (failType)
            {
                case USER_FAIL:
                    [self getUserList];
                    break;
                case DOOR_FAIL:
                    [self getDoors];
                    break;
                case EVENT_FAIL:
                    [self getEventMessage];
                    break;
                case PREFERENCE_FAIL:
                    [self getPreference];
                    break;
            }
        }
    }];
}

- (void)getPreference
{
    requestCount++;
    
    [preferenceProvoder getPreferenceWithCompleteHandler:^(Setting *user) {
        [self checkRequestCount];
    } onError:^(Response *error) {
        [self checkRequestCount];
        
        if (nil == [LocalDataManager getDateFormat] && nil == [LocalDataManager getDateFormat])
        {
            [self showImagePopup:error.message type:PREFERENCE_FAIL];
        }
        
    }];
    
}

- (void)getDoors
{
    if ([AuthProvider hasReadPermission:DOOR_PERMISSION])
    {
        requestCount++;
        
        [doorProvider searchDoors:nil limit:10 offset:0 completeBlock:^(GetDoorList *result) {
            [self checkRequestCount];
            
            [LocalDataManager setDoorCount:result.total];
            
            [self setTotalCount:[NSNumber numberWithInteger:result.total] type:DOOR_BUTTON];
        } onError:^(Response *error) {
            [self checkRequestCount];
            
            NSInteger doorCount = [LocalDataManager getDoorCount];
            [self setTotalCount:[NSNumber numberWithInteger:doorCount] type:DOOR_BUTTON];
            //[self showImagePopup:error.message type:DOOR_FAIL];
        }];
    }
    
    
    
}

- (void)getUserList
{
    if ([AuthProvider hasReadPermission:USER_PERMISSION])
    {
        requestCount++;
        
        NSString *groupID;
        
        if ([PreferenceProvider isUpperVersion])
        {
            groupID = nil;
        }
        else
        {
            groupID = @"1";
        }
        
        [userProvider getUsersOffset:0 limit:1 groupID:groupID query:nil completeHandler:^(UserSearchResult *userSearchResult) {
            
            [LocalDataManager setUserCount:userSearchResult.total];
            
            [self checkRequestCount];
            
            [self setTotalCount:[NSNumber numberWithInteger:userSearchResult.total] type:USER_BUTTON];
            
        } onError:^(Response *error) {
            
            [self checkRequestCount];
            
            NSInteger userCount = [LocalDataManager getUserCount];
            
            [self setTotalCount:[NSNumber numberWithInteger:userCount] type:USER_BUTTON];
            
            //[self showImagePopup:error.message type:USER_FAIL];
        }];
    }
}

- (void)setTotalCount:(NSNumber*)count type:(ButtonType)type
{
    NSInteger index = 0;
    ButtonModel *sideMenuButton;
    for (ButtonModel *button in sideMenuButtons)
    {
        if (button.type == type)
        {
            sideMenuButton = [button copy];
            sideMenuButton.count = [count unsignedIntegerValue];
            [sideMenuButtons replaceObjectAtIndex:index withObject:sideMenuButton];
            break;
        }
        index++;
    }
    
    [menuTableView reloadData];
}

- (void)getEventMessage
{
    requestCount++;
    [eventProvider getEventTypes:^(EventTypeSearchResult *result) {
        
        
        [self checkRequestCount];
        
    } onError:^(Response *error) {
        [self checkRequestCount];
        
        if (nil == [EventProvider getLocalEventTypes])
        {
            [self showImagePopup:error.message type:EVENT_FAIL];
        }
        
    }];
    
}



- (CGRect)getCurrentViewFrame:(CGRect)bounds
{
    CGRect frame = bounds;
    frame.size.width = sidemenuView.frame.size.width;
    
    return frame;
}

- (void)setGradation
{
    CAGradientLayer *gradientBackGround = [CAGradientLayer layer];
    gradientBackGround.frame = [self getCurrentViewFrame:sidemenuBottonView.bounds];
    gradientBackGround.colors = [NSArray arrayWithObjects:(id)UIColorFromRGB(0x4e3f42).CGColor, (id)UIColorFromRGB(0x342e30).CGColor, nil];
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    gradientBackGround.locations = gradientLocations;
    [sidemenuBottonView.layer insertSublayer:gradientBackGround atIndex:0];
    
}

- (void)setBadgeViewWidth
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:badgeNumberLabel.font, NSFontAttributeName, nil];
    CGFloat width = [[[NSAttributedString alloc] initWithString:badgeNumberLabel.text attributes:attributes] size].width;
    width += 5;
    
    if(badgeNumberLabel.text.length > 2)
    {
        badgeWidthConstraint.constant = width / 2;
    }
    else
    {
        badgeWidthConstraint.constant = 0;
    }
    
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



- (void)loadMyprofile
{
    userName.text = [AuthProvider getLoginUserInfo].name;
    if ([PreferenceProvider isUpperVersion])
    {
        userOperator.text = [AuthProvider getLoginUserInfo].permission.name;
    }
    else
    {
        userOperator.text = [[AuthProvider getLoginUserInfo].roles lastObject].role_description;
    }
    
    
    if (nil != [AuthProvider getLoginUserInfo].photo)
    {
        NSData *imageData = [NSData base64DataFromString:[AuthProvider getLoginUserInfo].photo];
        UIImage *userImage = [UIImage imageWithData:imageData];
        
        UIImage *image = [CommonUtil imageCompress:userImage fileSize:MAX_IMAGE_FILE_SIZE];
        
        userPhoto.image = image;
        
        userPhoto.layer.cornerRadius = userPhoto.frame.size.height /2;
        userPhoto.layer.masksToBounds = YES;
        userPhoto.layer.borderWidth = 0;
    }
    else
    {
        userPhoto.image = [UIImage imageNamed:@"user_photo_bg"];
    }
}

- (void)getMobileCredential
{
    [userProvider getMyMobileCredentials:^(MobileCredentialList *result) {
        
        if (result.mobile_credential_list.count > 0)
        {
            [badgeAlertView setHidden:result.mobile_credential_list[0].is_registered];
            
            if (!result.mobile_credential_list[0].is_registered)
            {
                if (![LocalDataManager getShowHelpViewStatus])
                {
                    if ([self isHomeScreen])
                    {
                        if (isSidemenuOpen)
                        {
                            [self closeSideMenu:10];
                        }
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        HelpViewController *helpController = [storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
                        
                        [self showPopup:helpController parentViewController:self parentView:self.view];
                        helpController.delegate = self;
                    }
                }
            }
        }
        
    } onErrorBlock:^(Response *error) {
        
    }];
}

- (void)addBadgeViewConstraint:(UIButton*)button
{
    [badgeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button addSubview:badgeView];
    
    [badgeView setHidden:NO];
    
    badgeWidthConstraint = [NSLayoutConstraint constraintWithItem:badgeView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:button
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:0.25
                                                         constant:0];
    
    [button addConstraint:badgeWidthConstraint];
    
    [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeView
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:button
                                                       attribute:NSLayoutAttributeHeight
                                                      multiplier:0.25
                                                        constant:0]];
    
    badgeTrailingConstraint = [NSLayoutConstraint constraintWithItem:badgeView
                                                           attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:button
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1
                                                            constant:0];
    [button addConstraint:badgeTrailingConstraint];
    
    [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeView
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:button
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1
                                                        constant:0]];
    
    // 뱃지 이미지 뷰
    [badgeImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [badgeView addConstraint:[NSLayoutConstraint constraintWithItem:badgeImageView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:badgeView
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1
                                                         constant:0]];
    
    
    [badgeView addConstraint:[NSLayoutConstraint constraintWithItem:badgeImageView
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:badgeView
                                                       attribute:NSLayoutAttributeHeight
                                                      multiplier:1
                                                        constant:0]];
    
    
    [badgeView addConstraint:[NSLayoutConstraint constraintWithItem:badgeImageView
                                                       attribute:NSLayoutAttributeTrailing
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:badgeView
                                                       attribute:NSLayoutAttributeTrailing
                                                      multiplier:1
                                                        constant:0]];
    
    [badgeView addConstraint:[NSLayoutConstraint constraintWithItem:badgeImageView
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:badgeView
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1
                                                        constant:0]];
    
    // 뱃지레이블
    [badgeNumberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [badgeView addConstraint:[NSLayoutConstraint constraintWithItem:badgeNumberLabel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:badgeView
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    
    [badgeView addConstraint:[NSLayoutConstraint constraintWithItem:badgeNumberLabel
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:badgeView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:0]];
    
    
    [badgeView addConstraint:[NSLayoutConstraint constraintWithItem:badgeNumberLabel
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:badgeView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    
    [badgeView addConstraint:[NSLayoutConstraint constraintWithItem:badgeNumberLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:badgeView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    
    [self setBadgeViewWidth];
}

- (void)setMenuItems
{
    [buttonDatas removeAllObjects];
    [sideMenuButtons removeAllObjects];
    // 순서대로 my profile, user, door, monitoring, alarm,
    
    ButtonModel *model = [[ButtonModel alloc] init];
    model.title = NSBaseLocalizedString(@"myprofile_upper", nil);
    model.normalImage = [UIImage imageNamed:@"main_myprofile_ic"];
    model.highlightedImage = [UIImage imageNamed:@"main_myprofile_ic_pre"];
    model.type = MYPROFILE_BUTTON;
    
    [buttonDatas addObject:model];
    
    if ([AuthProvider hasReadPermission:USER_PERMISSION])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"user_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_user_id"];
        model.highlightedImage = [UIImage imageNamed:@"main_user_id_pre"];
        model.icon = [UIImage imageNamed:@"list_user_ic"];
        model.type = USER_BUTTON;
        
        NSUInteger count = [LocalDataManager getUserCount];
        if (count != 0)
        {
            model.count = count;
        }
        
        [sideMenuButtons addObject:model];
        [buttonDatas addObject:model];
    }
    
    if ([AuthProvider hasReadPermission:DOOR_PERMISSION])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"door_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_door_ic"];
        model.highlightedImage = [UIImage imageNamed:@"main_door_ic_pre"];
        model.icon = [UIImage imageNamed:@"list_door_ic"];
        model.type = DOOR_BUTTON;
        
        NSUInteger count = [LocalDataManager getDoorCount];
        if (count != 0)
        {
            model.count = count;
        }
        
        [sideMenuButtons addObject:model];
        [buttonDatas addObject:model];
    }
    
    if ([AuthProvider hasReadPermission:MONITORING_PERMISSION])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"monitoring_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_monitor_ic"];
        model.highlightedImage = [UIImage imageNamed:@"main_monitor_ic_pre"];
        model.icon = [UIImage imageNamed:@"list_monitor_ic"];
        model.type = MONITORING_BUTTON;
        
        [sideMenuButtons addObject:model];
        [buttonDatas addObject:model];
    }
    
    if ([AuthProvider hasReadPermission:MONITORING_PERMISSION])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"alarm_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_alarm_ic"];
        model.highlightedImage = [UIImage imageNamed:@"main_alram_ic_pre"];
        model.icon = [UIImage imageNamed:@"list_alram_ic"];
        model.count = [AuthProvider getLoginUserInfo].unread_notification_count;
        model.type = ALARM_BUTTON;
        
        [sideMenuButtons addObject:model];
        [buttonDatas addObject:model];
    }

    if ([PreferenceProvider isSupportMobileCredentialAndFaceTemplate])
    {
        ButtonModel *model = [[ButtonModel alloc] init];
        model.title = NSBaseLocalizedString(@"mobile_card_upper", nil);
        model.normalImage = [UIImage imageNamed:@"main_card_ic"];
        model.highlightedImage = [UIImage imageNamed:@"main_card_ic_pre"];
        model.icon = [UIImage imageNamed:@"list_mobilecard_ic"];
        model.type = MOBILE_CARD_BUTTON;
        
        [sideMenuButtons addObject:model];
        [buttonDatas addObject:model];
    }
    
    if (buttonDatas.count > 3)
    {
        // 두줄 배치
        //bottomConstraint.constant = 0;
        stackViewBottomConstraint.constant = 0;
    }
    else
    {
        // 한줄 배치
        //bottomConstraint.constant = -60;
        stackViewBottomConstraint.constant = -100;
    }
    
    buttonsTouchDown = @selector(buttonsTouchDown:);
    buttonsTouchUpOutside = @selector(buttonsTouchUpOutside:);
    buttonsTouchUpInside = @selector(buttonsTouchUpInside:);
    
    BOOL isFourButtons = NO;
    if (buttonDatas.count < 6)
    {
        if (buttonDatas.count == 4)
        {
            isFourButtons = YES;
        }
        
        NSUInteger emptyButtonCount = 6 - buttonDatas.count;
        for (int i = 0; i < emptyButtonCount; i++)
        {
            ButtonModel *model = [[ButtonModel alloc] init];
            model.title = @"";
            model.normalImage = nil;
            model.highlightedImage = nil;
            model.icon = nil;
            model.type = EMPTY_BUTTON;
            [buttonDatas addObject:model];
        }
    }
    
    
    for (NSInteger i = 0; i < buttonDatas.count; i ++)
    {
//        UILabel *label = [buttonLabels objectAtIndex:i];
//        UIButton *button = [buttons objectAtIndex:i];
        
        UILabel *label = [stackViewLabels objectAtIndex:i];
        UIButton *button = [stackViewButtons objectAtIndex:i];
        button.tag = i;
        label.tag = i;
        
        ButtonModel *model = [buttonDatas objectAtIndex:i];
        [button setImage:model.normalImage forState:UIControlStateNormal];
        [button setImage:model.highlightedImage forState:UIControlStateHighlighted];
        [button addTarget:self action:buttonsTouchDown forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:buttonsTouchUpOutside forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:buttonsTouchUpInside forControlEvents:UIControlEventTouchUpInside];
        
        if (!isFourButtons)
        {
            UIView *buttonView = [buttonViews objectAtIndex:i];
            if (model.type == EMPTY_BUTTON)
            {
                [buttonView setHidden:YES];
            }
            else
            {
                [buttonView setHidden:NO];
            }
        }
        
        if (model.type == ALARM_BUTTON)
        {
            [self addBadgeViewConstraint:button];
            
        }
        
        if (model.type == MOBILE_CARD_BUTTON)
        {
            [button addSubview:badgeAlertView];
            [badgeAlertView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [badgeAlertView setHidden:YES];
            [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeAlertView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:button
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:0.3
                                                                        constant:0]];
            
            [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeAlertView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:button
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:0.3
                                                                        constant:0]];
            
            
            [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeAlertView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:button
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:0]];
            
            [button addConstraint:[NSLayoutConstraint constraintWithItem:badgeAlertView
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:button
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:1
                                                                constant:0]];
        }
        
        [label setText:model.title];

    }
    
    [menuTableView reloadData];
}


- (void)buttonsTouchDown:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    UILabel *label = [buttonLabels objectAtIndex:tag];
    [label setTextColor:[UIColor colorWithRed:255/255.0 green:211/255.0 blue:131/255.0 alpha:1]];
    
}

- (void)buttonsTouchUpOutside:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    UILabel *label = [buttonLabels objectAtIndex:tag];
    [label setTextColor:[UIColor colorWithRed:172/255.0 green:169/255.0 blue:161/255.0 alpha:1]];
    
}

- (void)buttonsTouchUpInside:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    UILabel *label = [buttonLabels objectAtIndex:tag];
    [label setTextColor:[UIColor colorWithRed:172/255.0 green:169/255.0 blue:161/255.0 alpha:1]];
    
    ButtonType buttonType = [buttonDatas objectAtIndex:tag].type;
    
    switch (buttonType) {
        case USER_BUTTON:
            [self moveToUserController];
            break;
            
        case MONITORING_BUTTON:
            [self moveToMonitorController];
            break;
            
        case ALARM_BUTTON:
            [self moveToAlarmController];
            break;
            
        case MYPROFILE_BUTTON:
            [self moveToMyProfile:nil];
            break;
            
        case DOOR_BUTTON:
            [self moveToDoorController];
            break;
            
        case MOBILE_CARD_BUTTON:
            [self moveToMobileCard];
            break;
        case EMPTY_BUTTON:
            break;
    }
}

- (void)updateWatch
{
    NSDate *date = [NSDate date];
    
    transDateFormate = [transDateFormate stringByReplacingOccurrencesOfString:@"yyyy/" withString:@""];
    transDateFormate = [transDateFormate stringByReplacingOccurrencesOfString:@"/yyyy" withString:@""];
    
    NSString *tempTransDateFormate = [NSString stringWithFormat:@"a,hh:mm,%@,EEE", transDateFormate];
    
    NSString *currentTime = [CommonUtil stringFromCurrentLocaleDateString:[date description]
                                                         originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                          transDateFormat:tempTransDateFormate];
    
    NSArray *timeArray = [currentTime componentsSeparatedByString:@","];
    
    NSString* isoCode = [NSLocale currentLocale].languageCode;
    
    AMLabel.text = [timeArray objectAtIndex:0];
    timeLabel.text = [timeArray objectAtIndex:1];
    
    if ([isoCode isEqualToString:@"ko"])
    {
        NSString *day = [NSString stringWithFormat:@"%@요일", [timeArray objectAtIndex:3]];
        day = [day stringByReplacingOccurrencesOfString:@" " withString:@""];
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

- (void)moveToUserController
{
    
    
    if (![AuthProvider hasReadPermission:USER_PERMISSION])
    {
        [self.view makeToast:NSBaseLocalizedString(@"no_permission", nil)
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

- (void)moveToMobileCard
{
    
    
    [self popToRootViewController];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MobileCardViewController *mobileCardViewController = [storyboard instantiateViewControllerWithIdentifier:@"MobileCardViewController"];
    
    [mobileCardViewController setCurrentUser:[AuthProvider getLoginUserInfo]];
    
    [self pushChildViewController:mobileCardViewController
             parentViewController:self
                      contentView:contentView animated:YES];
}

- (void)moveToDoorController
{
    
    
    if (![AuthProvider hasReadPermission:DOOR_PERMISSION])
    {
        [self.view makeToast:NSBaseLocalizedString(@"no_permission", nil)
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

- (void)moveToMonitorController
{
    
    
    if (![AuthProvider hasReadPermission:MONITORING_PERMISSION])
    {
        [self.view makeToast:NSBaseLocalizedString(@"no_permission", nil)
                    duration:2.0
                    position:CSToastPositionBottom
                       image:[UIImage imageNamed:@"toast_popup_i_03"]];
        return;
    }
    
    [self popToRootViewController];
    
    [MonitorFilterViewController setResetFilter:NO];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MonitoringViewController *monitoringViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitoringViewController"];
    monitoringViewController.requestType = EVENT_MONITOR;
    [self pushChildViewController:monitoringViewController
             parentViewController:self
                      contentView:contentView animated:YES];
}

- (void)moveToAlarmController
{
    
    
    [self popToRootViewController];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AlarmViewController *alarmViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlarmViewController"];
    [self pushChildViewController:alarmViewController
             parentViewController:self
                      contentView:contentView animated:YES];
    
}

- (IBAction)showBuildVersion:(id)sender
{
#warning QA 용일때만
//    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
//    NSString* buildversion = [infoDict objectForKey:@"CFBundleVersion"];
//    
//    NSString *builtInfo = [NSString stringWithFormat:@"Build number : %@", buildversion];
//    
//    [self.view makeToast:builtInfo];
}


- (IBAction)closeSideMenuView:(id)sender
{
    [self closeSideMenu:10];
}


- (IBAction)moveToHome:(id)sender
{
    
    [self setMenuItems];
    [self getMobileCredential];
    [[NSNotificationCenter defaultCenter] postNotificationName:MOVING_TO_ALARM object:nil];
    [self closeSideMenu:10];
    [self popToRootViewController];
}



- (IBAction)moveToPreperence:(id)sender
{
    
    
    [self closeSideMenu:10];
    [self popToRootViewController];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingViewController *settingViewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    
    
    [settingViewController setUserID:[AuthProvider getLoginUserInfo].user_id];
    [self pushChildViewController:settingViewController
             parentViewController:self
                      contentView:contentView animated:YES];
}

- (IBAction)profileButtonTouchUpOutside:(UIButton *)sender {
    [infoBackgroundView setBackgroundColor:UIColorFromRGB(0x4c3d40)];
}

- (IBAction)profileButtonTouchDown:(UIButton *)sender {
    
    [infoBackgroundView setBackgroundColor:UIColorFromRGB(0x362c2f)];
}

- (IBAction)moveToMyProfile:(id)sender
{
    
    
    [self closeSideMenu:10];
    [self popToRootViewController];
    
    [infoBackgroundView setBackgroundColor:UIColorFromRGB(0x4c3d40)];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserNewDetailViewController __weak *userDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserNewDetailViewController"];
    userDetailViewController.delegate = self;
    [userDetailViewController getUserInfo:[AuthProvider getLoginUserInfo].user_id];
    [userDetailViewController setType:PROFILE_MODE];
    [self pushChildViewController:userDetailViewController
             parentViewController:self
                      contentView:contentView animated:YES];
}

- (IBAction)logout:(id)sender
{
    [self startLoading:self];
    [authProvider logout:^(Response *error) {
        
        [self finishLoading];
        
        [self backToLoginController];
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        [self closeSideMenu:10];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];

    }];
    
}

- (IBAction)moveToLicense:(id)sender
{
    [self closeSideMenu:10];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LicenseViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LicenseViewController"];
    
    [self pushChildViewController:viewController
             parentViewController:self
                      contentView:contentView animated:YES];
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
    [LocalDataManager deleteLocalCookies];
    
    
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


#pragma mark - NotificationCenter method


- (void)userCountUpdated:(NSNotification*)userInfo
{
    
    NSInteger userCount = [[userInfo.object objectForKey:@"count"] integerValue];
    
    [self setTotalCount:[NSNumber numberWithInteger:userCount] type:USER_BUTTON];
    
}

- (void)doorCountUpdated:(NSNotification*)userInfo
{
    NSInteger doorCount = [[userInfo.object objectForKey:@"count"] integerValue];
    
    [self setTotalCount:[NSNumber numberWithInteger:doorCount] type:DOOR_BUTTON];
    
}

- (void)alarmCountUpdated:(NSNotification*)userInfo
{
    NSInteger deletedNewAlarmCount = [[userInfo.object objectForKey:@"count"] integerValue];
    
    badgeCount = badgeCount - deletedNewAlarmCount;
    if (badgeCount < 0)
    {
        badgeCount = 0;
    }

    badgeNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)badgeCount];
    
    [self setTotalCount:[NSNumber numberWithInteger:badgeCount] type:ALARM_BUTTON];
    [self setBadgeViewWidth];
}

- (void)notificationIsOccured:(NSNotification*)userInfo
{
    badgeCount++;
    
    badgeNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)badgeCount];
    
    [self setTotalCount:[NSNumber numberWithInteger:badgeCount] type:ALARM_BUTTON];
    [self setBadgeViewWidth];
    
    NSDictionary *notiDic = userInfo.object;
    NSString *title = nil;
    NSString *content = nil;
    NSString *toastContent = nil;
    
    if (notiDic)
    {
        if ([[[notiDic objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *alert = [[notiDic objectForKey:@"aps"] objectForKey:@"alert"];
            
            title = NSBaseLocalizedString([alert objectForKey:@"title-loc-key"], nil);
            
            NSArray *args = [alert objectForKey:@"loc-args"];
            
            if (nil != args)
            {
                NSRange range = NSMakeRange(0, [args count]);
                NSMutableData* data = [NSMutableData dataWithLength: sizeof(id) * [args count]];
                [args getObjects: (__unsafe_unretained id *)data.mutableBytes range:range];
                
                content = [[NSString alloc] initWithFormat:NSBaseLocalizedString([alert objectForKey:@"loc-key"], nil) arguments:data.mutableBytes];
            }
            else
            {
                content = NSBaseLocalizedString([alert objectForKey:@"loc-key"], nil);
            }
            
            toastContent = [NSString stringWithFormat:@"%@\n%@",title ,content];
        }
    }
    
    [self.view makeToast:toastContent
                duration:1.0
                position:CSToastPositionTop
                   image:[UIImage imageNamed:@"toast_popup_i_04"]];
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
//    NotiPopupController *notiPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"NotiPopupController"];
//    [notiPopupCtrl setNotiDic:userInfo.object];
//    [self showPopup:notiPopupCtrl parentViewController:self parentView:self.view];
}

- (void)useFaceTemplateForProfilePicture:(NSNotification*)userInfo
{
    NSString *updatedUserID = [userInfo.object objectForKey:@"userID"];
    
    if ([[AuthProvider getLoginUserInfo].user_id isEqualToString:updatedUserID])
    {
        [AuthProvider getLoginUserInfo].photo = [userInfo.object objectForKey:@"photo"];
        [self loadMyprofile];
    }
}

- (void)moveToAlarmByNoti
{
    [self moveToAlarmController];
}

- (void)loggedInUserUpdated
{
    [self loadMyprofile];
}

- (void)settingDidUpdated
{
    transDateFormate = [NSString stringWithFormat:@"%@",[LocalDataManager getDateFormat]];
}

- (void)needToGetMobileCredendial
{
    [self loadMyprofile];
    
    [self setMenuItems];
    
    [self getMobileCredential];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return sideMenuButtons.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuCell" forIndexPath:indexPath];
    SideMenuCell *customCell = (SideMenuCell*)cell;
    
    ButtonModel *button = [sideMenuButtons objectAtIndex:indexPath.row];
    [customCell setContent:button];
    return customCell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    float scaleFactor = [[UIScreen mainScreen] scale];
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat widthInPixel = screen.size.width * scaleFactor;
    
    if (widthInPixel > 640)
    {
        return 63.0;
    }
    else
    {
        return 44.0;
    }
    
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self closeSideMenu:10];
    
    ButtonModel *menuButton = [sideMenuButtons objectAtIndex:indexPath.row];
    
    ButtonType buttonType = menuButton.type;
    
    switch (buttonType) {
        case USER_BUTTON:
            [self moveToUserController];
            break;
            
        case MONITORING_BUTTON:
            [self moveToMonitorController];
            break;
            
        case ALARM_BUTTON:
            [self moveToAlarmController];
            break;
            
        case MYPROFILE_BUTTON:
            [self moveToMyProfile:nil];
            break;
            
        case DOOR_BUTTON:
            [self moveToDoorController];
            break;
            
        case MOBILE_CARD_BUTTON:
            [self moveToMobileCard];
            break;
        default:
            break;
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Add your Colour.
    SideMenuCell *cell = (SideMenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlightColor:UIColorFromRGB(0x362c2f)];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Reset Colour.
    SideMenuCell *cell = (SideMenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlightColor:[UIColor clearColor]];
}

#pragma mark - UserDetailDelegate

- (void)needToReloadUsers
{
    [self startLoading:self];
    
    [userProvider getMyProfile:^(User *userResult) {
        [self finishLoading];
        [self loadMyprofile];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        imagePopupCtrl.type = REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"fail_retry", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self needToReloadUsers];
            }
        }];
        
    }];
    
    
}

#pragma mark - Helpdelegate

- (void)mobileCardWasPressed
{
    [self moveToMobileCard];
}

@end
