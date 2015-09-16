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

#import "UserNewDetailViewController.h"


@interface UserNewDetailViewController ()

@end

@implementation UserNewDetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isForPopupRequest = NO;
    hasOperator = NO;
    isUpdatedOrDeleted = NO;
    userInfoDic = [[NSMutableDictionary alloc] init];
    toUpdateUserInfoDic = [[NSMutableDictionary alloc] init];
    [titleView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    
    detailTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self setDefaultPeriod];
    //[self setDefaultUserGroup];
    //[self setDefaultUserID];
    provider = UserProviderInstance;
    provider.delegate = self;
    if (nil != userID)
    {
        [provider getUser:userID];
        [self startLoading:self];
    }
    
    switch (_type)
    {
        case VIEW_MODE:
            if (![AuthProvider hasWritePermission:@"USER"])
            {
                [editButtonView setHidden:YES];
                [doneButton setHidden:YES];
            }
            break;
            
        case CREATE_MODE:
            titleLabel.text = NSLocalizedString(@"new_user", nil);
            [editButtonView setHidden:YES];
            [doneButton setHidden:NO];
            break;
            
        case PROFILE_MODE:
            titleLabel.text = NSLocalizedString(@"myprofile", nil);
            [editButtonView setHidden:YES];
            [doneButton setHidden:NO];
            break;
        default:
            break;
    }
}

- (void)setDefaultUserID
{
    [toUpdateUserInfoDic setObject:[CommonUtil getTenRandomNumber] forKey:@"user_id"];
}

- (void)setDefaultPeriod
{
    [toUpdateUserInfoDic setObject:@"AC" forKey:@"status"];
    [toUpdateUserInfoDic setObject:[NSNumber numberWithBool:NO] forKey:@"pin_exist"];
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *newComponents = [[NSDateComponents alloc] init];
    [newComponents setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    //[newComponents setTimeZone:[NSTimeZone localTimeZone]];
    [newComponents setYear:2001];
    [newComponents setMonth:01];
    [newComponents setDay:01];
    [newComponents setHour:0];
    [newComponents setMinute:0];
    [newComponents setSecond:0];
    
    NSDate *startDate = [calendar dateFromComponents:newComponents];
    
    NSString *startStr = [CommonUtil stringFromDateString:[startDate description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    [toUpdateUserInfoDic setObject:startStr forKey:@"start_datetime"];
    
    [newComponents setYear:2030];
    [newComponents setMonth:12];
    [newComponents setDay:31];
    [newComponents setHour:23];
    [newComponents setMinute:59];
    [newComponents setSecond:59];
    
    NSDate *expireDate = [calendar dateFromComponents:newComponents];
    
    NSString *expireStr = [CommonUtil stringFromDateString:[expireDate description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    [toUpdateUserInfoDic setObject:expireStr forKey:@"expiry_datetime"];

}

- (void)setUserGroup:(NSDictionary*)userGroup
{
    [toUpdateUserInfoDic setObject:userGroup forKey:@"user_group"];
}

- (void)setDefaultUserGroup
{
    NSMutableDictionary *userGroupID = [[NSMutableDictionary alloc] init];
    [userGroupID setObject:[NSNumber numberWithInteger:1] forKey:@"id"];
    [userGroupID setObject:@"All User Group" forKey:@"name"];
    [toUpdateUserInfoDic setObject:userGroupID forKey:@"user_group"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (isUpdatedOrDeleted)
    {
        if ([self.delegate respondsToSelector:@selector(needToReloadUsers)])
        {
            [self.delegate needToReloadUsers];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getUserInfo:(NSString*)_userID
{
    userID = _userID;
}

- (IBAction)moveToBack:(id)sender
{
    if (_type == MODIFY_MODE)
    {
        hasOperator = NO;
        _type = VIEW_MODE;
        [doneButton setHidden:YES];
        [editButtonView setHidden:NO];
        [detailTableView reloadData];
    }
    else
    {
        [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
    }
    
}

- (BOOL)verifyUserID
{
    long long tempUserID = [[toUpdateUserInfoDic objectForKey:@"user_id"] longLongValue];
    long long maxID = 4294967294;
    if (tempUserID > maxID)
    {
        [self showVerificationPopup:NSLocalizedString(@"invalid_userid", nil)];
        return NO;
    }
    else if (tempUserID == 0)
    {
        [self showVerificationPopup:NSLocalizedString(@"user_create_empty", nil)];
        return NO;
    }
    
    return YES;
}

- (BOOL)verifyUserEmail
{
    // operator 이 있으면 이메일 체크
    if (nil == [toUpdateUserInfoDic objectForKey:@"email"] || [[toUpdateUserInfoDic objectForKey:@"email"] isEqualToString:@""])
    {
        return YES;
    }
    if (![CommonUtil matchingByRegex:@"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$" withField:[toUpdateUserInfoDic objectForKey:@"email"]])
    {
        [self showVerificationPopup:NSLocalizedString(@"invalid_email", nil)];
        return NO;
    }

    return YES;
}

- (BOOL)verifyPeriod
{
    NSString *startDate = [toUpdateUserInfoDic objectForKey:@"start_datetime"];
    NSString *endDate = [toUpdateUserInfoDic objectForKey:@"expiry_datetime"];
    
    NSDate *start = [CommonUtil dateFromString:startDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    NSDate *end = [CommonUtil dateFromString:endDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    NSComparisonResult comparing = [start compare:end];
    
    if (comparing == NSOrderedDescending || comparing == NSOrderedSame)
    {
        [self showVerificationPopup:NSLocalizedString(@"error_set_date", nil)];
        return NO;
    }
    
    return YES;
}

- (BOOL)verifyOperator
{
//    if (nil != [toUpdateUserInfoDic objectForKey:@"email"] && ![[toUpdateUserInfoDic objectForKey:@"email"] isEqualToString:@""])
//    {
//        if (![toUpdateUserInfoDic objectForKey:@"roles"])
//        {
//            [self showVerificationPopup:NSLocalizedString(@"roles error", nil)];
//            return NO;
//        }
//    }
    
    return YES;
}

- (void)showVerificationPopup:(NSString*)message
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    oneButtonPopupCtrl.type = USER_INFO_VERIFICATION_FAIL;
    oneButtonPopupCtrl.popupContent = message;
    [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
}

- (IBAction)updateUserInfo:(id)sender
{
    [self.view endEditing:YES];
    
    if (![self verifyUserID])
    {
        return;
    }
    
    if (![self verifyUserEmail])
    {
        return;
    }
    
    if (![self verifyPeriod])
    {
        return;
    }
    
    if (![self verifyOperator])
    {
        return;
    }
    
    switch (_type)
    {
        case MODIFY_MODE:
            isForPopupRequest = NO;
            [provider modifyUser:[toUpdateUserInfoDic objectForKey:@"user_id"] userInfo:toUpdateUserInfoDic];
            [self startLoading:self];
            
            break;
        
        case CREATE_MODE:
            isForPopupRequest = NO;
            [provider createUser:toUpdateUserInfoDic];
            [self startLoading:self];
            break;
        
            
        case PROFILE_MODE:
            isForPopupRequest = NO;
            [toUpdateUserInfoDic removeObjectForKey:@"fingerprint_templates"];
            [provider updateProfile:toUpdateUserInfoDic];
            [self startLoading:self];
            break;
        default:
            break;
    }
}

- (IBAction)switchEditMode:(id)sender {
    
    [toUpdateUserInfoDic removeAllObjects];
    [self setDefaultPeriod];
    [toUpdateUserInfoDic setDictionary:userInfoDic];
    _type = MODIFY_MODE;
    
    [detailTableView reloadData];
    
    [editButtonView setHidden:YES];
    [doneButton setHidden:NO];
}


- (IBAction)moveToLog:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MonitoringViewController *mornitorViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitoringViewController"];
    mornitorViewController.requestType = EVENT_USER;
    
    [MonitorFilterViewController setFilterUsers:@[userInfoDic]];
    NSDictionary *condition = @{@"user_id" : @[[userInfoDic objectForKey:@"user_id"]]};
    
    [mornitorViewController setUserCondition:condition];
    [self pushChildViewController:mornitorViewController parentViewController:self contentView:self.view animated:YES];
    
}


- (IBAction)showStartDatePopup:(id)sender
{
    switch (_type)
    {
        case MODIFY_MODE:
        case CREATE_MODE:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            
            DatePickerPopupViewController *datePickerPopup = [storyboard instantiateViewControllerWithIdentifier:@"DatePickerPopupViewController"];
            [self showPopup:datePickerPopup parentViewController:self parentView:self.view];
            datePickerPopup.delegate = self;
            
            datePickerPopup.isStartDate = YES;
            
            NSString *startStr;
            if (nil == [toUpdateUserInfoDic objectForKey:@"start_datetime"] || [[toUpdateUserInfoDic objectForKey:@"start_datetime"] isEqualToString:@""])
            {
                NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                
                NSDateComponents *newComponents = [[NSDateComponents alloc] init];
                [newComponents setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                [newComponents setYear:2001];
                [newComponents setMonth:01];
                [newComponents setDay:01];
                [newComponents setHour:0];
                [newComponents setMinute:0];
                [newComponents setSecond:0];
                
                NSDate *startDate = [calendar dateFromComponents:newComponents];
                
                startStr = [CommonUtil stringFromDateString:[startDate description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
                [toUpdateUserInfoDic setObject:startStr forKey:@"start_datetime"];
            }
            else
            {
                startStr = [toUpdateUserInfoDic objectForKey:@"start_datetime"];
            }
            
            
            NSDate *startDate = [CommonUtil localDateFromString:startStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
            
            
            [datePickerPopup setIsLocalTime:NO];
            [datePickerPopup setDate:startDate];
            break;
        }
        default:
            break;
    }
}

- (IBAction)showExpireDatePopup:(id)sender
{
    switch (_type)
    {
        case MODIFY_MODE:
        case CREATE_MODE:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            
            DatePickerPopupViewController *datePickerPopup = [storyboard instantiateViewControllerWithIdentifier:@"DatePickerPopupViewController"];
            [self showPopup:datePickerPopup parentViewController:self parentView:self.view];
            datePickerPopup.delegate = self;
            
            datePickerPopup.isStartDate = NO;
            
            NSString *expireStr;
            if (nil == [toUpdateUserInfoDic objectForKey:@"expiry_datetime"] || [[toUpdateUserInfoDic objectForKey:@"expiry_datetime"] isEqualToString:@""])
            {
                NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                
                NSDateComponents *newComponents = [[NSDateComponents alloc] init];
                [newComponents setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                
                [newComponents setYear:2030];
                [newComponents setMonth:12];
                [newComponents setDay:31];
                [newComponents setHour:23];
                [newComponents setMinute:59];
                [newComponents setSecond:59];
                
                NSDate *expireDate = [calendar dateFromComponents:newComponents];
                
                expireStr = [CommonUtil stringFromDateString:[expireDate description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
                [toUpdateUserInfoDic setObject:expireStr forKey:@"expiry_datetime"];
            }
            else
            {
                expireStr = [toUpdateUserInfoDic objectForKey:@"expiry_datetime"];
            }
            
            NSDate *expireDate = [CommonUtil dateFromString:expireStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
            [datePickerPopup setIsLocalTime:NO];
            [datePickerPopup setDate:expireDate];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)deleteUser:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    TextPopupViewController *textPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"TextPopupViewController"];
    textPopupCtrl.delegate = self;
    textPopupCtrl.type = USER_DELETE;
    [self showPopup:textPopupCtrl parentViewController:self parentView:self.view];
}

- (IBAction)showPhotoPopup:(id)sender
{
    if (_type == VIEW_MODE)
    {
        return;
    }
    
    NSDictionary *item1 = @{@"name" : NSLocalizedString(@"take_picture", nil)};
    NSDictionary *item2 = @{@"name" : NSLocalizedString(@"from_photo", nil)};
    NSDictionary *item3 = @{@"name" : NSLocalizedString(@"delete_picture", nil)};
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    
    OneButtonTablePopupViewController *oneButtonPopup = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonTablePopupViewController"];
    oneButtonPopup.delegate = self;
    oneButtonPopup.type = PHOTO;
    [self showPopup:oneButtonPopup parentViewController:self parentView:self.view];
    [oneButtonPopup setContentListArray:@[item1, item2, item3]];
}

- (void)loadUserInfo:(NSDictionary *)userInfo
{
    if (nil == userInfoDic)
    {
        userInfoDic = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    }
    else
    {
        [userInfoDic setDictionary:userInfo];
    }
    
    NSArray *roles = [userInfoDic objectForKey:@"roles"];
    if (roles.count > 0)
    {
        hasOperator = YES;
    }
    else
    {
        hasOperator = NO;
    }
    
    if (![[userInfoDic objectForKey:@"photo"] isKindOfClass:[UIImage class]])
    {
        NSString *imageString = [userInfoDic objectForKey:@"photo"];
        if (nil != imageString && ![imageString isEqualToString:@""])
        {
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:imageString options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *serverImage = [UIImage imageWithData:imageData];
            UIImage* scaledImage = [CommonUtil imageWithImage:serverImage scaledToSize:CGSizeMake(200, 200)];
            
            NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
            [[SDImageCache sharedImageCache] storeImage:scaledImage forKey:userPhotoKey toDisk:YES];
            
            imageData = nil;
            imageString = nil;
            
            [userInfoDic setObject:scaledImage forKey:@"photo"];
        }
    }
    if (_type == VIEW_MODE)
    {
        titleLabel.text = [userInfoDic objectForKey:@"name"];
    }
    else if (_type == PROFILE_MODE)
    {
        [toUpdateUserInfoDic setDictionary:userInfoDic];
    }
    
    [detailTableView reloadData];
}

- (void)moveToVerificationViewController:(VerificationType)type
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserVerificationAddViewController *verificationViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserVerificationAddViewController"];
    verificationViewController.delegate = self;
    
    if (_type == PROFILE_MODE)
    {
        verificationViewController.isProfileMode = YES;
    }
    else
    {
        verificationViewController.isProfileMode = NO;
    }
    
    verificationViewController.type = type;
    
    
    switch (type)
    {
        case OPERATOR:
        {
            // userID 1 번이면 이동불가
            if ([userID isEqualToString:@"1"])
            {
                return;
            }
            NSArray *roles = [toUpdateUserInfoDic objectForKey:@"roles"];
            [verificationViewController setOperators:roles];
        }
            break;
        case ACCESS_GROUPS:
            [verificationViewController setAccessGroup:[toUpdateUserInfoDic objectForKey:@"access_groups"] withUserGroup:[toUpdateUserInfoDic objectForKey:@"access_groups_in_user_group"]];
            break;
        case FINGERPRINT:
            [verificationViewController setVerificationInfo:[toUpdateUserInfoDic objectForKey:@"fingerprint_templates"]];
            break;
        case CARD:
            [verificationViewController setVerificationInfo:[toUpdateUserInfoDic objectForKey:@"cards"]];
            break;
    }
    
    [self pushChildViewController:verificationViewController parentViewController:self contentView:self.view animated:YES];
}

- (void)showUserGroupPopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ListSubInfoPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
    listPopupCtrl.delegate = self;
    listPopupCtrl.type = USER_GROUP;
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
}

- (void)showPeriodPopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
    listPopupCtrl.delegate = self;
    listPopupCtrl.isRadioStyle = YES;
    listPopupCtrl.type = PEROID;
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
    [listPopupCtrl addOptions:@[NSLocalizedString(@"start_date", nil),
                                NSLocalizedString(@"end_date", nil)]];
}

#pragma mark - DatePickerDelegate

- (void)confirmDateFilter:(NSString*)date isStartDate:(BOOL)isStartDate
{
    // 선택한 날짜를 서버 시간으로 바꿔서 딕션어리에 저장
    if (isStartDate)
    {
        NSString *startDateStr =  [CommonUtil stringFromDateString:date originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [toUpdateUserInfoDic setObject:startDateStr forKey:@"start_datetime"];
        
    }
    else
    {
        NSString *expireDateStr =  [CommonUtil stringFromDateString:date originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [toUpdateUserInfoDic setObject:expireDateStr forKey:@"expiry_datetime"];
    }
    
    [detailTableView reloadData];
}

#pragma mark - KeyBoard Noti

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //CGFloat deltaHeight = kbSize.height - _currentKeyboardHeight;
    // Write code to adjust views accordingly using deltaHeight
    //_currentKeyboardHeight = kbSize.height;
    
    tableViewConstraint.constant = kbSize.height;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    //NSDictionary *info = [notification userInfo];
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    // Write code to adjust views accordingly using kbSize.height
    //_currentKeyboardHeight = 0.0f;
    
    tableViewConstraint.constant = 0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger rowCount = 0;
    switch (section)
    {
        case 0:
            if (_type == VIEW_MODE)
            {
                rowCount = 7;
            }
            else
            {
                if (hasOperator)    // operator 이 none 이 아닐경우 로그인 아이디 및 패스워드 편집을 위해
                {
                    rowCount = 9;
                }
                else
                {
                    rowCount = 7;
                }
                
            }
            break;
        case 1:
            rowCount = 3;
            break;
        case 2: // 크리덴셜
            if (_type == VIEW_MODE)
            {
                if ([[userInfoDic objectForKey:@"pin_exist"] boolValue])
                {
                    rowCount = 3;
                }
                else
                    rowCount = 2;
            }
            else
                rowCount = 3;
            break;
        
    }

    return rowCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // 폰트 때문에 뷰에서 섹션 타이틀 정해줘야 할 필요 있음.
    if (section == 2)
    {
        return NSLocalizedString(@"credential", nil);
    }
    else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailPictureCell" forIndexPath:indexPath];
                    UserDetailPictureCell *pictureCell = (UserDetailPictureCell*)cell;
                    
                    if (_type == VIEW_MODE)
                    {
                        [pictureCell setTopCell:userInfoDic mode:_type];
                    }
                    else
                    {
                        [pictureCell setTopCell:toUpdateUserInfoDic mode:_type];
                    }
                    
                    
                    
                    return pictureCell;
                    break;
                }
                case 1: // 아이디
                {
                    switch (_type)
                    {
                        case VIEW_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"user_id", nil);
                            customCell.contentField.text = [userInfoDic objectForKey:@"user_id"];
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_ID viewMode:_type];
                            customCell.delegate = self;
                            return customCell;
                        }
                            break;
                        case CREATE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_ID viewMode:_type];
                            customCell.delegate = self;
                            return customCell;
                        }
                            break;
                    }
                    
                    break;
                }
                case 2: // 이름
                {
                    switch (_type)
                    {
                        case VIEW_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"Name", nil);
                            customCell.contentField.text = [userInfoDic objectForKey:@"name"];
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_NAME viewMode:_type];
                            customCell.delegate = self;
                            
                            return customCell;
                        }
                            break;
                    }
                    
                    break;
                }
                case 3: // 이메일
                {
                    if (_type == VIEW_MODE)
                    {
                        if (nil == [userInfoDic objectForKey:@"email"] || [[userInfoDic objectForKey:@"email"] isEqualToString:@""])
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"email", nil);
                            customCell.contentField.text = [userInfoDic objectForKey:@"email"];
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                        }
                        else
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:userInfoDic cellType:CELL_USER_EMAIL viewMode:_type];
                            customCell.delegate = self;
                            
                            return customCell;
                        }
                    }
                    else
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                        UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                        [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_EMAIL viewMode:_type];
                        customCell.delegate = self;
                        
                        return customCell;
                    }
                    
                    break;
                }
                    
                case 4: // 폰
                {
                    if (_type == VIEW_MODE)
                    {
                        if (nil == [userInfoDic objectForKey:@"phone_number"] || [[userInfoDic objectForKey:@"phone_number"] isEqualToString:@""])
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"telephone", nil);
                            customCell.contentField.text = [userInfoDic objectForKey:@"phone_number"];
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                        }
                        else
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:userInfoDic cellType:CELL_USER_TELEPHONE viewMode:_type];
                            customCell.delegate = self;
                            
                            return customCell;
                        }
                    }
                    else
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                        UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                        [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_TELEPHONE viewMode:_type];
                        customCell.delegate = self;
                        
                        return customCell;
                    }
                    
                    
                    break;
                }
                case 5: // Biostar Operator
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailOperatorCell" forIndexPath:indexPath];
                    UserDetailOperatorCell *customCell = (UserDetailOperatorCell*)cell;
                    
                    switch (_type)
                    {
                        case VIEW_MODE:
                        {
                            NSArray *roles = [userInfoDic objectForKey:@"roles"];
                            [customCell setOperatorCellContent:roles isEditMode:NO];

                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        case PROFILE_MODE:
                        {
                            NSArray *roles = [toUpdateUserInfoDic objectForKey:@"roles"];
                            if ([userID isEqualToString:@"1"])
                            {
                                [customCell setOperatorCellContent:roles isEditMode:NO];
                            }
                            else
                            {
                                [customCell setOperatorCellContent:roles isEditMode:YES];
                            }
                            
                            return customCell;
                        }
                            break;
                    }
                    
                    
                    break;
                }
                    
                case 6: // Group or login Id
                {
                    switch (_type)
                    {
                        case VIEW_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"group", nil);
                            customCell.contentField.text = [[userInfoDic objectForKey:@"user_group"] objectForKey:@"name"];
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        case PROFILE_MODE:
                        {
                            if (hasOperator)
                            {
                                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                                UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                                [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_LOGIN_ID viewMode:_type];
                                customCell.delegate = self;
                                
                                return customCell;
                            }
                            else
                            {
                                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                                UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                                customCell.titleLabel.text = NSLocalizedString(@"group", nil);
                                customCell.contentField.text = [[userInfoDic objectForKey:@"user_group"] objectForKey:@"name"];
                                [customCell.contentField setEnabled:NO];
                                [customCell.contentField setSecureTextEntry:NO];
                                return customCell;
                            }
                        }
                            break;
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        {
                            if (hasOperator)
                            {
                                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                                UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                                [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_LOGIN_ID viewMode:_type];
                                customCell.delegate = self;
                                
                                return customCell;
                            }
                            else
                            {
                                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                                UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                                [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_GROUP viewMode:_type hasOperator:hasOperator];
                                customCell.delegate = self;
                                
                                return customCell;
                            }
                            
                        }
                            break;
                    }

                    break;
                }
                    
                case 7: // Password
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                    UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                    [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_PASSWORD viewMode:_type];
                    customCell.delegate = self;
                    
                    return customCell;
                    
                    break;
                }
                    
                case 8: // Group
                {
                    switch (_type)
                    {
                        case VIEW_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"group", nil);
                            customCell.contentField.text = [[userInfoDic objectForKey:@"user_group"] objectForKey:@"name"];
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        
                        case CREATE_MODE:
                        case MODIFY_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_GROUP viewMode:_type];
                            customCell.delegate = self;
                            
                            return customCell;
                        }
                            break;
                    }
                    
                    break;
                }
                default:
                {
                    UITableViewCell *cell = [[UITableViewCell alloc] init];
                    return cell;
                    break;
                }
            }
            break;
        }
            
        case 1:
        {
            switch (indexPath.row)
            {
                case 0: // 상태 활성화
                {
                    switch (_type)
                    {
                        case VIEW_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"status", nil);
                            customCell.contentField.text = NSLocalizedString([userInfoDic objectForKey:@"status"], nil);
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailSwitchCell" forIndexPath:indexPath];
                            UserDetailSwitchCell *customCell = (UserDetailSwitchCell*)cell;
                            customCell.delegate = self;
                            [customCell setCellContent:[toUpdateUserInfoDic objectForKey:@"status"]];
                            
                            return customCell;
                        }
                            break;
                    }
                    break;
                }
                    
                case 1: // Period
                {
                    switch (_type)
                    {
                        case VIEW_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailDateCell" forIndexPath:indexPath];
                            UserDetailDateCell *customCell = (UserDetailDateCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"period", nil);
                            [customCell setStartDate:[userInfoDic objectForKey:@"start_datetime"] andExpireDate:[userInfoDic objectForKey:@"expiry_datetime"]];
                            //[customCell.contentField setEnabled:editMode];
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailDateAccCell" forIndexPath:indexPath];
                            UserDetailDateAccCell *customCell = (UserDetailDateAccCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"period", nil);
                            [customCell setStartDate:[toUpdateUserInfoDic objectForKey:@"start_datetime"] andExpireDate:[toUpdateUserInfoDic objectForKey:@"expiry_datetime"]];
                            return customCell;
                        }
                            break;
                    }
                    break;
                }
                
                case 2: // Access Group
                    switch (_type)
                    {
                        case VIEW_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"access_group", nil);
                            NSInteger count = 0;
                            count += (unsigned long)[[userInfoDic objectForKey:@"access_groups"] count];
                            count += (unsigned long)[[userInfoDic objectForKey:@"access_groups_in_user_group"] count];
                            
                            customCell.contentField.text = [NSString stringWithFormat:@"%lu", (long)count];
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:toUpdateUserInfoDic cellType:CELL_USER_ACCESS_GROUP viewMode:_type];
                            customCell.delegate = self;
                            
                            return customCell;
                        }
                            break;
                    }
                    break;
                default:
                {
                    UITableViewCell *cell = [[UITableViewCell alloc] init];
                    return cell;
                    break;
                }
            }
            
            break;
        }
            
        case 2:
        {
            switch (indexPath.row)
            {
                case 0: // 지문
                {
                    switch (_type)
                    {
                        case VIEW_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"fingerprint", nil);
                            NSString *fingerprintCount = [NSString stringWithFormat:@"%ld", (unsigned long)[[userInfoDic objectForKey:@"fingerprint_templates"] count]];
                            customCell.contentField.text = fingerprintCount;
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"fingerprint", nil);
                            NSString *fingerprintCount = [NSString stringWithFormat:@"%ld", (unsigned long)[[toUpdateUserInfoDic objectForKey:@"fingerprint_templates"] count]];
                            customCell.contentField.text = fingerprintCount;
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                        }
                            break;
                    }
                    
                    break;
                }
                case 1: // 카드
                {
                    switch (_type)
                    {
                        case VIEW_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"card", nil);
                            NSString *cardCount = [NSString stringWithFormat:@"%ld", (unsigned long)[[userInfoDic objectForKey:@"cards"] count]];
                            customCell.contentField.text = cardCount;
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"card", nil);
                            NSString *cardCount = [NSString stringWithFormat:@"%ld", (unsigned long)[[toUpdateUserInfoDic objectForKey:@"cards"] count]];
                            customCell.contentField.text = cardCount;
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                        }
                            break;
                    }
                    
                    break;
                }
                case 2:
                {
                    switch (_type)
                    {
                        case VIEW_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"pin_upper", nil);
                            
                            customCell.contentField.text = @"1234";
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:YES];
                            
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailSwitchCell" forIndexPath:indexPath];
                            UserDetailSwitchCell *customCell = (UserDetailSwitchCell*)cell;
                            customCell.delegate = self;
                            [customCell setCellPinContent:[[toUpdateUserInfoDic objectForKey:@"pin_exist"] boolValue]];
                            
                            return customCell;
                        }
                            break;
                    }
                }
                    break;
                default:
                {
                    UITableViewCell *cell = [[UITableViewCell alloc] init];
                    return cell;
                    break;
                }
            }
            
            break;
        }
            
        default:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
            
            break;
        }
    }
    
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else
    {
        return 30;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            height = 252;
        }
        else
        {
            height = 62;
        }
    }
    else
    {
        height = 62;
    }
    return height;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    if (_type == VIEW_MODE)     // 뷰모드 일때
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 3)
            {
                if ([MFMailComposeViewController canSendMail])
                {
                    NSString *mailAddress = [userInfoDic objectForKey:@"email"];
                    if (nil != mailAddress)
                    {
                        NSArray *recipents = @[mailAddress];
                        
                        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                        [mc setToRecipients:recipents];
                        mc.mailComposeDelegate = self;
                        [self presentViewController:mc animated:YES completion:NULL];
                    }
                    
                }
                else
                {
                    [self.view makeToast:NSLocalizedString(@"email_not_setted", nil)
                                duration:2.0
                                position:CSToastPositionTop
                                   image:[UIImage imageNamed:@"toast_popup_i_03"]];
                }
                
            }
            
            if (indexPath.row == 4)
            {
                NSString *phoneNumber = [userInfoDic objectForKey:@"phone_number"];
                if (nil != phoneNumber)
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];
            }
        }
    }
    else            // 편집, 추가 일때
    {
        switch (indexPath.section)
        {
            case 0:
            {
                if (hasOperator)
                {
                    if (indexPath.row == 5)
                    {
                        // 권한
                        [self moveToVerificationViewController:OPERATOR];
                    }
                    else if(indexPath.row == 7)
                    {
                        // 패스워드 팝업
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                        PinPopupViewController *pinPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"PinPopupViewController"];
                        pinPopupCtrl.type = PASSWORD;
                        pinPopupCtrl.delegate = self;
                        [self showPopup:pinPopupCtrl parentViewController:self parentView:self.view];
                        
                    }
                    else if(indexPath.row == 8)
                    {
                        // 그룹
                        if (_type == CREATE_MODE || _type == MODIFY_MODE)
                        {
                            [self showUserGroupPopup];
                        }
                        
                    }
                }
                else
                {
                    if (indexPath.row == 5)
                    {
                        // 권한
                        [self moveToVerificationViewController:OPERATOR];
                    }
                    else if (indexPath.row == 6)
                    {
                        // 그룹
                        if (_type == CREATE_MODE || _type == MODIFY_MODE)
                        {
                            [self showUserGroupPopup];
                        }
                    }
                }
                
                break;
            }
                
            case 1:
                if (indexPath.row == 1) // Period
                {
                    if (_type == CREATE_MODE || _type == MODIFY_MODE)
                    {
                        [self showPeriodPopup];
                    }
                }
                
                if (indexPath.row == 2) // Access Group
                {
                    [self moveToVerificationViewController:ACCESS_GROUPS];
                }
                break;
            case 2:
            {
                switch (indexPath.row)
                {
                    case 0:
                        // fingerprint
                        [self moveToVerificationViewController:FINGERPRINT];
                        break;
                    case 1:
                        // card
                        [self moveToVerificationViewController:CARD];
                        break;
                    case 2:
                    {
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
                        PinPopupViewController *pinPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"PinPopupViewController"];
                        pinPopupCtrl.delegate = self;
                        [self showPopup:pinPopupCtrl parentViewController:self parentView:self.view];
                    }
                        break;
                }
                
                
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UserProvider delegate



- (void)requestDidFinishGettingUserInfo:(NSDictionary*)userInfo
{
    [self finishLoading];
    [self loadUserInfo:userInfo];
}

- (void)requestDidFinishModifyUserInfo:(NSDictionary*)result
{
    isUpdatedOrDeleted = YES;
    _type = VIEW_MODE;

    [self finishLoading];
    [editButtonView setHidden:NO];
    [doneButton setHidden:YES];
    
    [userInfoDic removeObjectsForKeys:userInfoDic.allKeys];
    [userInfoDic setDictionary:toUpdateUserInfoDic];
    
    NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
    
    if (nil != [userInfoDic objectForKey:@"photo"] && [[userInfoDic objectForKey:@"photo"] isKindOfClass:[UIImage class]])
    {
        [[SDImageCache sharedImageCache] storeImage:[userInfoDic objectForKey:@"photo"] forKey:userPhotoKey toDisk:YES];
    }
    else
    {
        [[SDImageCache sharedImageCache] removeImageForKey:userPhotoKey fromDisk:YES];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *successPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    successPopupCtrl.type = UPDATE_USER;
    successPopupCtrl.delegate = self;
    [self showPopup:successPopupCtrl parentViewController:self parentView:self.view];
}

- (void)requestDidFinishCreateUser:(NSDictionary*)result
{
    isUpdatedOrDeleted = YES;
    [self finishLoading];
    _type = VIEW_MODE;

    [editButtonView setHidden:NO];
    [doneButton setHidden:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *successPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    successPopupCtrl.type = CREATE_USER;
    successPopupCtrl.delegate = self;
    [self showPopup:successPopupCtrl parentViewController:self parentView:self.view];
}


- (void)requestDidFinishDeleteUser:(NSDictionary*)result
{
    NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
    
    [[SDImageCache sharedImageCache] removeImageForKey:userPhotoKey fromDisk:YES withCompletion:^{
        
        isUpdatedOrDeleted = YES;
        [self finishLoading];
        [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
        
    }];
    
}

- (void)requestUserProviderDidFail:(NSDictionary*)errDic
{
    [self finishLoading];
    NSLog(@"requestDidFail : %@", errDic);
    
    // 재시도 할것인지에 대한 팝업 띄워주기
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - UserDetailAccCellDelegate

- (void)userEmailDidChange:(NSString*)email
{
    [toUpdateUserInfoDic setObject:email forKey:@"email"];
}

- (void)userTelephoneDidChange:(NSString*)telephone
{
    [toUpdateUserInfoDic setObject:telephone forKey:@"phone_number"];
}

- (void)userNameDidChange:(NSString*)changedName
{
    [toUpdateUserInfoDic setObject:changedName forKey:@"name"];
}

- (void)userIDDidChange:(NSString*)changedUserID
{
    [toUpdateUserInfoDic setObject:changedUserID forKey:@"user_id"];
}

- (void)userLogin_IDDidChange:(NSString*)loginID
{
    [toUpdateUserInfoDic setObject:loginID forKey:@"login_id"];
}

- (void)userPasswordDidChange:(NSString*)password
{
    //[toUpdateUserInfoDic setObject:password forKey:@"user_id"];
}

#pragma mark - UserVerificationAddViewControllerDelegate

- (void)fingerprintDidAdd:(NSArray*)fingerprintTemplates
{
    [toUpdateUserInfoDic setObject:fingerprintTemplates forKey:@"fingerprint_templates"];

    [detailTableView reloadData];
}

- (void)cardDidAdd:(NSArray*)cards
{
    [toUpdateUserInfoDic setObject:cards forKey:@"cards"];
    
    [detailTableView reloadData];
}

- (void)accessGroupDidChange:(NSArray*)groups
{
    NSMutableArray *tempGroups = [[NSMutableArray alloc] initWithArray:groups];
    
    for (NSDictionary *dic in groups)
    {
        if ([[dic objectForKey:@"type"] isEqualToString:@"access_groups_in_user_group"])
        {
            [tempGroups removeObject:dic];
        }
    }
    
    [toUpdateUserInfoDic setObject:tempGroups forKey:@"access_groups"];
    [detailTableView reloadData];
}

- (void)operatorValueDidChange:(NSArray*)operators
{
    if (operators.count > 0)
    {
        hasOperator = YES;
    }
    else
    {
        hasOperator = NO;
        // 로그인 아이디 password 빈값으로 바꾸기
        [toUpdateUserInfoDic setObject:@"" forKey:@"login_id"];
        [toUpdateUserInfoDic setObject:@"" forKey:@"password"];
        [toUpdateUserInfoDic setObject:[NSNumber numberWithBool:NO] forKey:@"password_exist"];
        
    }
    
    [toUpdateUserInfoDic setObject:operators forKey:@"roles"];
    
    [detailTableView reloadData];
}

#pragma mark - OneButtonTableDelegate

- (void)didSelectIndex:(NSInteger)selectedIndex
{
    
    switch (selectedIndex)
    {
        case 0:
        {
            // 사진찍기
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            
            // Don't forget to add UIImagePickerControllerDelegate in your .h
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:^{
                
            }];
          
        }
            break;
            
        case 1:
        {
            // 사진첩에서 가져오기
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            
            // Don't forget to add UIImagePickerControllerDelegate in your .h
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }
            break;
            
        case 2:
            // 사진 삭제
            //[toUpdateUserInfoDic removeObjectForKey:@"photo"];
            [toUpdateUserInfoDic setObject:@"" forKey:@"photo"];
            [detailTableView reloadData];
            break;
    }
}

#pragma mark - ListPopupViewControllerDelegate

- (void)didSelectDateOption:(NSInteger)optionIndex
{
    if (optionIndex == 0)
    {
        [self showStartDatePopup:nil];
    }
    else
    {
        [self showExpireDatePopup:nil];
    }
}

- (void)cancelListPopupWithError:(NSDictionary*)errDic
{
    isForPopupRequest = YES;
    // 재시도 할것인지에 대한 팝업 띄워주기
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - ListSubInfoPopupDelegate

- (void)confirmUserGroup:(NSDictionary*)userGroup
{
    NSMutableDictionary *userGroupID = [[NSMutableDictionary alloc] init];
    [userGroupID setObject:[userGroup objectForKey:@"id"] forKey:@"id"];
    [userGroupID setObject:[userGroup objectForKey:@"name"] forKey:@"name"];
    [toUpdateUserInfoDic setObject:userGroupID forKey:@"user_group"];
    [detailTableView reloadData];
}

- (void)cancelListSubInfoPopupWithError:(NSDictionary*)errDic
{
    isForPopupRequest = YES;
    // 재시도 할것인지에 대한 팝업 띄워주기
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.delegate = self;
    imagePopupCtrl.type = REQUEST_FAIL;
    imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
    [imagePopupCtrl setContent:[errDic objectForKey:@"message"]];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

#pragma mark - TextPopupDelegate

- (void)cancelModify
{
    _type = VIEW_MODE;
    [doneButton setHidden:YES];
    [editButtonView setHidden:NO];
    [detailTableView reloadData];
}

- (void)confirmDeleteUser
{
    isForPopupRequest = NO;
    [provider deleteUser:[userInfoDic objectForKey:@"user_id"]];
    [self startLoading:self];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 사진 찍었거나 선택후 편집 까지 마치면 호출됨
    NSLog(@"%@", info);
    UIImage *editedImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];

    UIImage* scaledImage = [CommonUtil imageWithImage:editedImage scaledToSize:CGSizeMake(200, 200)];
    
    NSData *imgData = UIImageJPEGRepresentation(scaledImage, 0);
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imgData length]);
    
    [toUpdateUserInfoDic setObject:scaledImage forKey:@"photo"];
    [self dismissViewControllerAnimated:YES completion:^{
        [detailTableView reloadData];
    }];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - ImagePopupDelegate

- (void)confirmImagePopup
{
    if (isForPopupRequest)
    {
        // 팝업창에서 API 호출하는 방식일 경우 그 팝업 다시 띄워주기
        // 그룹
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ListSubInfoPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListSubInfoPopupViewController"];
        listPopupCtrl.delegate = self;
        listPopupCtrl.type = USER_GROUP;
        [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
    }
    else
    {
        switch (provider.type)
        {
            case UserInfo:
                isForPopupRequest = NO;
                [provider getUser:userID];
                [self startLoading:self];
                break;
            case UserModify:
                isForPopupRequest = NO;
                [provider modifyUser:[toUpdateUserInfoDic objectForKey:@"user_id"] userInfo:toUpdateUserInfoDic];
                [self startLoading:self];
                break;
            case UserCreate:
                isForPopupRequest = NO;
                [provider createUser:toUpdateUserInfoDic];
                [self startLoading:self];
                break;
            case UserDelete:
                isForPopupRequest = NO;
                [provider deleteUser:[userInfoDic objectForKey:@"user_id"]];
                [self startLoading:self];
                break;
            default:
                break;
        }
    }
}

- (void)cancelImagePopup
{
    if (provider.type == UserInfo)
    {
        [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
    }
}

#pragma mark - OneButtonPopupDelegate

- (void)updateComplete
{
    [self loadUserInfo:userInfoDic];
}

- (void)createComplete
{
    [self moveToBack:nil];
}

#pragma mark - SwitchCellDelegate

- (void)switchValueDidChange:(UISwitch*)sender cell:(UITableViewCell*)theCell
{
    NSIndexPath *indexPath = [detailTableView indexPathForCell:theCell];
    
    if (indexPath.section == 1)
    {
        if (sender.isOn)
        {
            [toUpdateUserInfoDic setObject:@"AC" forKey:@"status"];
        }
        else
        {
            [toUpdateUserInfoDic setObject:@"IN" forKey:@"status"];
        }
    }
    else
    {
        if (sender.isOn)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            PinPopupViewController *pinPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"PinPopupViewController"];
            pinPopupCtrl.type = PIN;
            pinPopupCtrl.delegate = self;
            [self showPopup:pinPopupCtrl parentViewController:self parentView:self.view];
        }
        else
        {
            [toUpdateUserInfoDic setObject:[NSNumber numberWithBool:NO] forKey:@"pin_exist"];
            [toUpdateUserInfoDic setObject:@"" forKey:@"pin"];
            [toUpdateUserInfoDic removeObjectForKey:@"pin_exist"];
        }
    }
    
    [detailTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - PinPopupDelegate

- (void)confirmPin:(NSString*)pin
{
    [toUpdateUserInfoDic setObject:[NSNumber numberWithBool:YES] forKey:@"pin_exist"];
    [toUpdateUserInfoDic setObject:pin forKey:@"pin"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:2];
    
    [detailTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)confirmPassword:(NSString*)password
{
    [toUpdateUserInfoDic setObject:password forKey:@"password"];
    [toUpdateUserInfoDic setObject:[NSNumber numberWithBool:YES] forKey:@"password_exist"];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:7 inSection:0];
    
    [detailTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end





