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
    [self setSharedViewController:self];
    
    hasOperator = NO;
    isUpdatedOrDeleted = NO;
    [titleView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    
    detailTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    provider = UserProviderInstance;
    preferenceProvoder = [[PreferenceProvider alloc] init];
    switch (_type)
    {
        case VIEW_MODE:
            if (![AuthProvider hasWritePermission:USER_PERMISSION])
            {
                [editButtonView setHidden:YES];
                [doneButton setHidden:YES];
            }
            if (nil != userID)
            {
                [self getUser:userID];
            }
            
            break;
            
        case CREATE_MODE:
            toUpdateUser = [User new];
            toUpdateUser.access_groups = @[];
            [self setDefaultPeriod];
            titleLabel.text = NSLocalizedString(@"new_user", nil);
            [editButtonView setHidden:YES];
            [doneButton setHidden:NO];
            break;
            
        case PROFILE_MODE:
            titleLabel.text = NSLocalizedString(@"myprofile", nil);
            [editButtonView setHidden:YES];
            [doneButton setHidden:NO];
            [self getMyProfile];
            break;
        default:
            break;
    }
}

- (void)getMyProfile
{
    [self startLoading:self];
    [provider getMyProfile:^(User *userResult) {
        [self finishLoading];
        [self loadUserInfo:userResult];
        
    } onError:^(Response *error) {
        [self finishLoading];
        [self showImageButtonPopup:MAIN_REQUEST_FAIL title:NSLocalizedString(@"fail_retry", nil) message:error.message];
        
    }];
    
}

- (void)setDefaultPeriod
{
    toUpdateUser.status = @"AC";
    toUpdateUser.pin_exist = NO;
    
    SimpleModel *defaultUserGroup = [SimpleModel new];
    defaultUserGroup.id = @"1";
    defaultUserGroup.name = @"All users";
    toUpdateUser.user_group = defaultUserGroup;
    
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
    
    NSString *startStr = [CommonUtil stringFromDateString:[startDate description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    toUpdateUser.start_datetime = startStr;
    
    [newComponents setYear:2030];
    [newComponents setMonth:12];
    [newComponents setDay:31];
    [newComponents setHour:23];
    [newComponents setMinute:59];
    [newComponents setSecond:59];
    
    NSDate *expireDate = [calendar dateFromComponents:newComponents];
    
    NSString *expireStr = [CommonUtil stringFromDateString:[expireDate description] originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    toUpdateUser.expiry_datetime = expireStr;
}

- (void)setUserGroup:(UserGroup*)userGroup
{
    
    toUpdateUser.user_group.id = userGroup.id;
    toUpdateUser.user_group.name = userGroup.name;
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
        //hasOperator = NO;
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

- (BOOL)verifyUserIDByNumber:(NSString*)ID
{
    if ([[ID substringToIndex:1] isEqualToString:@"0"])
    {
        [self showOneButtonPopup:USER_INFO_VERIFICATION_FAIL withMessage:NSLocalizedString(@"invalid_userid", nil)];
        return NO;
    }
    long long maxID = 4294967294;
    
    if ([self isAllDigits:ID])
    {
        long long longUserID = [ID longLongValue];
        if (longUserID > maxID)
        {
            [self showOneButtonPopup:USER_INFO_VERIFICATION_FAIL withMessage:NSLocalizedString(@"invalid_userid", nil)];
            return NO;
        }
        else if (longUserID == 0)
        {
            [self showOneButtonPopup:USER_INFO_VERIFICATION_FAIL withMessage:NSLocalizedString(@"user_create_empty", nil)];
            return NO;
        }
    }
    else
    {
        [self showOneButtonPopup:USER_INFO_VERIFICATION_FAIL withMessage:NSLocalizedString(@"invalid_userid", nil)];
        return NO;
    }
    
    
    
    return YES;
}

- (BOOL)isAllDigits:(NSString*)content
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [content rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound && content.length > 0;
}

- (BOOL)verifyUserID
{
    if ([PreferenceProvider isUpperVersion])
    {
        if ([toUpdateUser.user_id isEqualToString:@""] || nil == toUpdateUser.user_id)
        {
            [self showOneButtonPopup:USER_INFO_VERIFICATION_FAIL withMessage:NSLocalizedString(@"user_create_empty", nil)];
            return NO;
        }
        
        if ([PreferenceProvider getBioStarSetting].use_alphanumeric_user_id)
        {
            return YES;
        }
        else
        {
            return [self verifyUserIDByNumber:toUpdateUser.user_id];
        }
    }
    else
    {
        return [self verifyUserIDByNumber:toUpdateUser.user_id];
    }
}

- (BOOL)verifyUserEmail
{
    // operator 이 있으면 이메일 체크
    if (nil == toUpdateUser.email || [toUpdateUser.email isEqualToString:@""])
    {
        return YES;
    }
    if (![CommonUtil matchingByRegex:@"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$" withField:toUpdateUser.email])
    {
        [self showOneButtonPopup:USER_INFO_VERIFICATION_FAIL withMessage:NSLocalizedString(@"invalid_email", nil)];
        return NO;
    }

    return YES;
}

- (BOOL)verifyPeriod
{
    NSString *startDate = toUpdateUser.start_datetime;
    NSString *endDate = toUpdateUser.expiry_datetime;
    
    NSDate *start = [CommonUtil dateFromString:startDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    NSDate *end = [CommonUtil dateFromString:endDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    NSComparisonResult comparing = [start compare:end];
    
    if (comparing == NSOrderedDescending || comparing == NSOrderedSame)
    {
        [self showOneButtonPopup:USER_INFO_VERIFICATION_FAIL withMessage:NSLocalizedString(@"error_set_date", nil)];
        return NO;
    }
    
    return YES;
}

- (BOOL)verifyOperator
{
    if (toUpdateUser.roles.count > 0)
    {
        if (nil == toUpdateUser.login_id || [toUpdateUser.login_id isEqualToString:@""])
        {
            [self showOneButtonPopup:USER_INFO_VERIFICATION_FAIL withMessage:NSLocalizedString(@"user_create_empty_idpassword", nil)];
            return NO;
        }
        
        if (!toUpdateUser.password_exist)
        {
            if (nil == toUpdateUser.password || [toUpdateUser.password isEqualToString:@""])
            {
                [self showOneButtonPopup:USER_INFO_VERIFICATION_FAIL withMessage:NSLocalizedString(@"password_empty", nil)];
                return NO;
            }
        }
        
    }
    
    return YES;
}

- (void)showOneButtonPopup:(OneButtonPopupType)type withMessage:(NSString*)message
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    oneButtonPopupCtrl.type = type;
    
    if (nil != message)
    {
        oneButtonPopupCtrl.popupContent = message;
    }
    
    [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
    
    [oneButtonPopupCtrl getResponse:^(OneButtonPopupType type) {
        if (type == UPDATE_USER)
        {
            if (_type == PROFILE_MODE)
            {
                [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
            }
            else
            {
                [self loadUserInfo:currentUser];
            }
        }
        else if (type == CREATE_USER)
        {
            [self moveToBack:nil];
        }
    }];
 
}

- (void)showImageButtonPopup:(ImagePopupType)type title:(NSString*)title message:(NSString*)message
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    imagePopupCtrl.titleContent = title;
    [imagePopupCtrl setContent:message];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    
    [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
        if (isConfirm)
        {
            switch (provider.type) {
                case MyProfile_Request:
                    [self getMyProfile];
                    break;
                case UserInfo_Request:
                    [self getUser:userID];
                    break;
                case UserModify_Request:
                    [self modifyUser:toUpdateUser];
                    break;
                case UserCreate_Request:
                    [self createUser:toUpdateUser];
                    break;
                case UserDelete_Request:
                    [self deleteUserInfo:currentUser.user_id];
                    break;
                case MyProfileModify_Request:
                    [self updateMyProfile:toUpdateUser];
                    break;
                default:
                    break;
            }
            
        }
        else
        {
            if (provider.type == UserInfo_Request || provider.type == MyProfile_Request)
            {
                [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
            }
        }
    }];
}

- (void)showPinPopup:(PinPopupType)type
{
    [self startLoading:self];
    
    [preferenceProvoder getBiostarACSetting:^(BioStarSetting *result) {
        [self finishLoading];
        
        [self showPinPopupAfterAPICall:type];
    } onError:^(Response *error) {
        [self finishLoading];

        [self showPinPopupAfterAPICall:type];
    }];
    
    
}

- (void)showPinPopupAfterAPICall:(PinPopupType)type
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    PinPopupViewController *pinPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"PinPopupViewController"];
    pinPopupCtrl.type = type;
    
    [self showPopup:pinPopupCtrl parentViewController:self parentView:self.view];
    
    [pinPopupCtrl getResponse:^(PinPopupType type, NSString *pin) {
        if (type == PIN)
        {
            toUpdateUser.pin_exist = YES;
            toUpdateUser.pin = pin;
            [detailTableView reloadData];

        }
        else
        {
            toUpdateUser.password = pin;
            toUpdateUser.password_exist = YES;
            [detailTableView reloadData];

        }
    }];
}

- (void)getUser:(NSString*)ID
{
    [self startLoading:self];
    
    [provider getUser:ID userBlock:^(User *userResult) {
        [self finishLoading];
        [self loadUserInfo:userResult];
    } onError:^(Response *error) {
        // 재시도 할것인지에 대한 팝업 띄워주기
        [self finishLoading];
        [self showImageButtonPopup:MAIN_REQUEST_FAIL title:NSLocalizedString(@"fail_retry", nil) message:error.message];
    }];
    
    
}

- (void)modifyUser:(User*)user
{
    [self startLoading:self];
    [provider modifyUser:user responseBlock:^(Response *error) {
        [self finishLoading];
        
        isUpdatedOrDeleted = YES;
        _type = VIEW_MODE;
        
        [editButtonView setHidden:NO];
        [doneButton setHidden:YES];
        
        if ([toUpdateUser.user_id isEqualToString:[AuthProvider getLoginUserInfo].user_id])
        {
            // 수정한 사용자와 로그인한 사용자가 같을때
            [AuthProvider setLoginUserInfo:toUpdateUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGGED_IN_USER_UPDATEED object:nil];
            
        }
        currentUser = nil;
        currentUser = [toUpdateUser copy];
        
        NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
        
        if (nil != currentUser.photo && ![currentUser.photo isEqualToString:@""])
        {
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:currentUser.photo options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage* scaledImage = [CommonUtil imageCompress:[UIImage imageWithData:imageData] fileSize:MAX_IMAGE_FILE_SIZE];
            [[SDImageCache sharedImageCache] storeImage:scaledImage forKey:userPhotoKey toDisk:YES];
        }
        else
        {
            [[SDImageCache sharedImageCache] removeImageForKey:userPhotoKey fromDisk:YES];
        }
        
        [detailTableView reloadData];
        
    } onErrorBlock:^(Response *error) {
        [self finishLoading];
        // 재시도 할것인지에 대한 팝업 띄워주기
        [self showImageButtonPopup:MAIN_REQUEST_FAIL title:NSLocalizedString(@"fail_retry", nil) message:error.message];
    }];
}


- (void)createUser:(User*)user
{
    [self startLoading:self];
    
    [provider createUser:user responseBlock:^(Response *error) {
        
        [self finishLoading];
        
        isUpdatedOrDeleted = YES;
        _type = VIEW_MODE;
        
        [editButtonView setHidden:NO];
        [doneButton setHidden:YES];
        
        if ([PreferenceProvider isUpperVersion])
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.type = USER_CREATED;
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    _type = MODIFY_MODE;
                    currentUser = [user copy];
                    [detailTableView reloadData];
                    
                    [editButtonView setHidden:YES];
                    [doneButton setHidden:NO];
                    
                }
                else
                {
                    [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
                }
            }];
        }
        else
        {
            [self showOneButtonPopup:CREATE_USER withMessage:nil];
        }
        
        
    } onErrorBlock:^(Response *error) {
        [self finishLoading];
        // 재시도 할것인지에 대한 팝업 띄워주기
        [self showImageButtonPopup:MAIN_REQUEST_FAIL title:NSLocalizedString(@"fail_retry", nil) message:error.message];
        
    }];
    
}

- (void)updateMyProfile:(User*)user
{
    [self startLoading:self];
    
    user.fingerprint_templates = nil;
    
    [provider updateProfile:toUpdateUser responseBlock:^(Response *error) {
        [self finishLoading];
        
        isUpdatedOrDeleted = YES;
        _type = PROFILE_MODE;
        
        [editButtonView setHidden:NO];
        [doneButton setHidden:YES];
        
        currentUser = nil;
        currentUser = [toUpdateUser copy];
        
        NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
        
        if (nil != currentUser.photo && ![currentUser.photo isEqualToString:@""])
        {
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:currentUser.photo options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage* scaledImage = [CommonUtil imageCompress:[UIImage imageWithData:imageData] fileSize:MAX_IMAGE_FILE_SIZE];
            [[SDImageCache sharedImageCache] storeImage:scaledImage forKey:userPhotoKey toDisk:YES];
        }
        else
        {
            [[SDImageCache sharedImageCache] removeImageForKey:userPhotoKey fromDisk:YES];
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        OneButtonPopupViewController *successPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
        successPopupCtrl.type = UPDATE_USER;
        [self showPopup:successPopupCtrl parentViewController:self parentView:self.view];
        
        [successPopupCtrl getResponse:^(OneButtonPopupType type) {
            [self finishLoading];
            [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
        }];
        
    } onErrorBlock:^(Response *error) {
        [self finishLoading];
        // 재시도 할것인지에 대한 팝업 띄워주기
        [self showImageButtonPopup:MAIN_REQUEST_FAIL title:NSLocalizedString(@"fail_retry", nil) message:error.message];
        
    }];
    
    
}

- (void)deleteUserInfo:(NSString*)deleteUserID
{
    [self startLoading:self];
    
    [provider deleteUser:deleteUserID responseBlock:^(Response *error) {
        
        NSString *userPhotoKey = [NSString stringWithFormat:@"%@%@", [NetworkController sharedInstance].serverURL, [NSString stringWithFormat:API_USER_PHOTO, userID]];
        
        [[SDImageCache sharedImageCache] removeImageForKey:userPhotoKey fromDisk:YES withCompletion:^{
            
            isUpdatedOrDeleted = YES;
            [self finishLoading];
            [self popChildViewController:self parentViewController:self.parentViewController animated:YES];
            
        }];
        
    } onErrorBlock:^(Response *error) {
        
        [self finishLoading];
        
        // 재시도 할것인지에 대한 팝업 띄워주기
        [self showImageButtonPopup:MAIN_REQUEST_FAIL title:NSLocalizedString(@"fail_retry", nil) message:error.message];
    }];
    
    
}

- (IBAction)updateUserInfo:(id)sender
{
    [self.view endEditing:YES];
    
    if ([PreferenceProvider isUpperVersion])
    {
        [self startLoading:self];
        [preferenceProvoder getBiostarACSetting:^(BioStarSetting *result) {
            [self finishLoading];
            
            [detailTableView reloadData];
            
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
                    
                    [self modifyUser:toUpdateUser];
                    break;
                    
                case CREATE_MODE:
                    [self createUser:toUpdateUser];
                    break;
                    
                case PROFILE_MODE:
                {
                    [self updateMyProfile:toUpdateUser];
                    break;
                }
                default:
                    break;
            }
            
        } onError:^(Response *error) {
            
            [self finishLoading];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
            imagePopupCtrl.type = REQUEST_FAIL;
            [imagePopupCtrl setContent:error.message];
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                
                if (isConfirm)
                {
                    [self updateUserInfo:nil];
                }
                
            }];
            
        }];
    }
    else
    {
        [self finishLoading];
        
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
                
                [self modifyUser:toUpdateUser];
                break;
                
            case CREATE_MODE:
                [self createUser:toUpdateUser];
                break;
                
            case PROFILE_MODE:
            {
                [self updateMyProfile:toUpdateUser];
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)switchEditMode:(id)sender
{
    if ([PreferenceProvider isUpperVersion])
    {
//        if (![AuthProvider hasReadPermission:@"ACCESS_GROUP"])
//        {
//            NSString *popupContent = [NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"guide_feature_permission", nil) , @"ACCESS_GROUP"];
//            
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
//            OneButtonPopupViewController *oneButtonPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
//            oneButtonPopupCtrl.type = PERMISSION_DENIED;
//            oneButtonPopupCtrl.popupContent = popupContent;
//            [self showPopup:oneButtonPopupCtrl parentViewController:self parentView:self.view];
//            
//            [oneButtonPopupCtrl getResponse:^(OneButtonPopupType type) {
//                
//            }];
//            
//            return;
//        }
        
        [self startLoading:self];
        
        [preferenceProvoder getBiostarACSetting:^(BioStarSetting *result) {
            
            [self finishLoading];
            
            toUpdateUser = nil;
            toUpdateUser = [currentUser copy];
            
            _type = MODIFY_MODE;
            
            [detailTableView reloadData];
            
            [editButtonView setHidden:YES];
            [doneButton setHidden:NO];
            
        } onError:^(Response *error) {
            
            [self finishLoading];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            imagePopupCtrl.titleContent = NSLocalizedString(@"fail_retry", nil);
            imagePopupCtrl.type = REQUEST_FAIL;
            [imagePopupCtrl setContent:error.message];
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                
                if (isConfirm)
                {
                    [self switchEditMode:nil];
                }
                
            }];
            
        }];
    }
    else
    {
        toUpdateUser = nil;
        toUpdateUser = [currentUser copy];
        
        _type = MODIFY_MODE;
        
        [detailTableView reloadData];
        
        [editButtonView setHidden:YES];
        [doneButton setHidden:NO];
    }
    
}


- (IBAction)moveToLog:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MonitoringViewController *mornitorViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonitoringViewController"];
    mornitorViewController.requestType = EVENT_USER;
    
    [MonitorFilterViewController setFilterUsers:@[currentUser]];
    
    [mornitorViewController setUserCondition:@[currentUser.user_id]];
    [self pushChildViewController:mornitorViewController parentViewController:self contentView:self.view animated:YES];
    
}


- (IBAction)showStartDatePopup:(id)sender
{
    if (_type == MODIFY_MODE || _type == CREATE_MODE)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        
        DatePickerPopupViewController *datePickerPopup = [storyboard instantiateViewControllerWithIdentifier:@"DatePickerPopupViewController"];
        [self showPopup:datePickerPopup parentViewController:self parentView:self.view];
        datePickerPopup.isStartDate = YES;
        
        NSString *startStr;
        if (nil == toUpdateUser.start_datetime || [toUpdateUser.start_datetime isEqualToString:@""])
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
            toUpdateUser.start_datetime = startStr;
        }
        else
        {
            startStr = toUpdateUser.start_datetime;
        }
        
        NSDate *startDate = [CommonUtil localDateFromString:startStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        
        [datePickerPopup setIsLocalTime:NO];
        [datePickerPopup setDate:startDate];
        
        [datePickerPopup getResponse:^(NSString *dateString) {
            // 선택한 날짜를 서버 시간으로 바꿔서 딕션어리에 저장
            NSString *startDateStr =  [CommonUtil stringFromDateString:dateString originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
            toUpdateUser.start_datetime = startDateStr;
            [detailTableView reloadData];
        }];
    }
}

- (IBAction)showExpireDatePopup:(id)sender
{
    if (_type == MODIFY_MODE || _type == CREATE_MODE)
    {
     
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        
        DatePickerPopupViewController *datePickerPopup = [storyboard instantiateViewControllerWithIdentifier:@"DatePickerPopupViewController"];
        [self showPopup:datePickerPopup parentViewController:self parentView:self.view];
        
        datePickerPopup.isStartDate = NO;
        
        NSString *expireStr;
        if (nil == toUpdateUser.expiry_datetime || [toUpdateUser.expiry_datetime isEqualToString:@""])
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
            toUpdateUser.expiry_datetime = expireStr;
        }
        else
        {
            expireStr = toUpdateUser.expiry_datetime;
        }
        
        NSDate *expireDate = [CommonUtil dateFromString:expireStr originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
        [datePickerPopup setIsLocalTime:NO];
        [datePickerPopup setDate:expireDate];
        
        [datePickerPopup getResponse:^(NSString *dateString) {
            // 선택한 날짜를 서버 시간으로 바꿔서 딕션어리에 저장
            NSString *expireDateStr =  [CommonUtil stringFromDateString:dateString originDateFormat:@"YYYY-MM-dd HH:mm:ss z" transDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
            toUpdateUser.expiry_datetime = expireDateStr;
            
            [detailTableView reloadData];
        }];
    }
}

- (IBAction)deleteUser:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    TextPopupViewController *textPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"TextPopupViewController"];
    textPopupCtrl.type = USER_DELETE;
    [self showPopup:textPopupCtrl parentViewController:self parentView:self.view];
    
    [textPopupCtrl getResponse:^(TextPopupType type, BOOL isConfirm) {
        if (isConfirm)
        {
            [self deleteUserInfo:currentUser.user_id];
        }
    }];
}

- (IBAction)showPhotoPopup:(id)sender
{
    if (_type == VIEW_MODE)
    {
        return;
    }
    
    [self.view endEditing:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    
    OneButtonTablePopupViewController *oneButtonPopup = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonTablePopupViewController"];
    oneButtonPopup.type = PHOTO;
    [self showPopup:oneButtonPopup parentViewController:self parentView:self.view];
    [oneButtonPopup setContentStringArray:@[NSLocalizedString(@"take_picture", nil), NSLocalizedString(@"from_photo", nil), NSLocalizedString(@"delete_picture", nil)]];
    
    [oneButtonPopup getIndexResponse:^(NSInteger index) {
        switch (index)
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
                toUpdateUser.photo = @"";
                [detailTableView reloadData];
                break;
        }
    }];
}

- (void)loadUserInfo:(User*)user
{
    if ([user.user_id integerValue] == 1)
    {
        [editButtonView setHidden:YES];
    }
    currentUser = user;
    
    if ([PreferenceProvider isUpperVersion])
    {
        hasOperator = user.permission ? YES : NO;
    }
    else
    {
        hasOperator = user.roles.count > 0 ? YES : NO;
    }
    
    if (_type == VIEW_MODE)
    {
        titleLabel.text = user.name;
    }
    toUpdateUser = [user copy];
    
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
        case ACCESS_GROUPS:
            [verificationViewController setAccessGroup:toUpdateUser.access_groups withUserGroup:toUpdateUser.access_groups_in_user_group];
            break;
        case FINGERPRINT:
            [verificationViewController setFingerPrintTemplates:toUpdateUser.fingerprint_templates];
            break;
        case CARD:
            [verificationViewController setCards:toUpdateUser.cards];
            break;
    }
    
    [self pushChildViewController:verificationViewController parentViewController:self contentView:self.view animated:YES];
}

- (void)moveToFingerPrintCredentialViewController
{
    if ([PreferenceProvider isUpperVersion])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserVerificationAddViewController *verificationViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserVerificationAddViewController"];
        verificationViewController.delegate = self;
        
        if (_type == PROFILE_MODE)
        {
            [self moveToVerificationViewController:FINGERPRINT];
            return;
        }
        else
        {
            verificationViewController.isProfileMode = NO;
        }
        
        verificationViewController.type = FINGERPRINT;
        [verificationViewController setUserInfo:currentUser];
        [self pushChildViewController:verificationViewController parentViewController:self contentView:self.view animated:YES];
    }
    else
    {
        [self moveToVerificationViewController:FINGERPRINT];
    }
}

- (void)moveToCardCredentialViewController
{
    if ([PreferenceProvider isUpperVersion])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CardCredentialViewController *credentialViewController = [storyboard instantiateViewControllerWithIdentifier:@"CardCredentialViewController"];
        credentialViewController.delegate = self;
        
        if (_type == PROFILE_MODE)
        {
            credentialViewController.isProfileMode = YES;
        }
        else
        {
            credentialViewController.isProfileMode = NO;
        }
        
        [credentialViewController setUserVeryfications:currentUser];
        
        [self pushChildViewController:credentialViewController parentViewController:self contentView:self.view animated:YES];
    }
    else
    {
        [self moveToVerificationViewController:CARD];
    }
}

- (void)showUserGroupPopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    UserGroupPopupViewController *userGroupPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"UserGroupPopupViewController"];
    [self showPopup:userGroupPopupCtrl parentViewController:self parentView:self.view];
    [userGroupPopupCtrl getSelectedUserGroup:^(UserGroup *userGroup) {
        
        toUpdateUser.user_group = (SimpleModel*)userGroup;
        [detailTableView reloadData];
        
    }];

}

- (void)showPermissionPopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    PermissionPopupViewController *permissionPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"PermissionPopupViewController"];
    
    [self showPopup:permissionPopupCtrl parentViewController:self parentView:self.view];
    
    if ([PreferenceProvider isUpperVersion])
    {
        [permissionPopupCtrl getSelectedPermissionBlock:^(Permission *permission) {
            
            if ([permission.name isEqualToString:NSLocalizedString(@"none", nil)])
            {
                toUpdateUser.permission = nil;
                toUpdateUser.login_id = nil;
                toUpdateUser.password = nil;
                toUpdateUser.password_exist = NO;
                hasOperator = NO;
                [detailTableView reloadData];
            }
            else
            {
                toUpdateUser.permission = permission;
                hasOperator = YES;
                [detailTableView reloadData];
            }
            
        }];
    }
    else
    {
        [permissionPopupCtrl getSelectedRoleBlock:^(CloudRole *role) {
            if ([role.role_description isEqualToString:NSLocalizedString(@"none", nil)])
            {
                NSArray *roles = @[];
                toUpdateUser.roles = roles;
                toUpdateUser.login_id = @"";
                toUpdateUser.password = @"";
                toUpdateUser.password_exist = NO;
                hasOperator = NO;
            }
            else
            {
                NSArray *roles = @[role];
                toUpdateUser.roles = roles;
                hasOperator = YES;
            }
            
            [detailTableView reloadData];
        }];
    }
    
}
- (void)showPeriodPopup
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ListPopupViewController *listPopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ListPopupViewController"];
    listPopupCtrl.type = PEROID;
    
    [self showPopup:listPopupCtrl parentViewController:self parentView:self.view];
    
    [listPopupCtrl addOptions:@[NSLocalizedString(@"start_date", nil),
                                NSLocalizedString(@"end_date", nil)]];
    
    
    [listPopupCtrl getIndexResponseBlock:^(NSInteger index) {
        if (index == 0)
        {
            [self showStartDatePopup:nil];
        }
        else
        {
            [self showExpireDatePopup:nil];
        }
    }];
}

#pragma mark - KeyBoard Noti

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    tableViewConstraint.constant = kbSize.height;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    
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
                if (currentUser.pin_exist)
                {
                    rowCount = 3;
                }
                else
                    rowCount = 2;
            }
            else if(_type == CREATE_MODE)
            {
                if ([PreferenceProvider isUpperVersion])
                {
                    rowCount = 1;
                }
                else
                {
                    rowCount = 3;
                }
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
        // secion 0
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
                        [pictureCell setTopCell:currentUser mode:_type];
                    }
                    else
                    {
                        [pictureCell setTopCell:toUpdateUser mode:_type];
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
                            customCell.contentField.text = currentUser.user_id;
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:toUpdateUser cellType:CELL_USER_ID viewMode:_type];
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
                            customCell.titleLabel.text = NSLocalizedString(@"name", nil);
                            customCell.contentField.text = currentUser.name;
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
                            [customCell setCellContent:toUpdateUser cellType:CELL_USER_NAME viewMode:_type];
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
                        if (nil == currentUser.email || [currentUser.email isEqualToString:@""])
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"email", nil);
                            customCell.contentField.text = currentUser.email;
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                        }
                        else
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:currentUser cellType:CELL_USER_EMAIL viewMode:_type];
                            customCell.delegate = self;
                            
                            return customCell;
                        }
                    }
                    else
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                        UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                        [customCell setCellContent:toUpdateUser cellType:CELL_USER_EMAIL viewMode:_type];
                        customCell.delegate = self;
                        
                        return customCell;
                    }
                    
                    break;
                }
                    
                case 4: // 폰
                {
                    if (_type == VIEW_MODE)
                    {
                        if (nil == currentUser.phone_number || [currentUser.phone_number isEqualToString:@""])
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"telephone", nil);
                            customCell.contentField.text = currentUser.phone_number;
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                        }
                        else
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:currentUser cellType:CELL_USER_TELEPHONE viewMode:_type];
                            customCell.delegate = self;
                            
                            return customCell;
                        }
                    }
                    else
                    {
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                        UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                        [customCell setCellContent:toUpdateUser cellType:CELL_USER_TELEPHONE viewMode:_type];
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
                        case PROFILE_MODE:
                        {
                            if ([PreferenceProvider isUpperVersion])
                            {
                                [customCell setPermission:currentUser.permission.name isEditMode:NO];
                            }
                            else
                            {
                                [customCell setOperatorCellContent:currentUser.roles isEditMode:NO];
                            }
                            
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        {
                            if ([PreferenceProvider isUpperVersion])
                            {
                                if ([userID isEqualToString:@"1"])
                                {
                                    [customCell setPermission:toUpdateUser.permission.name isEditMode:NO];
                                }
                                else
                                {
                                    [customCell setPermission:toUpdateUser.permission.name isEditMode:YES];
                                }
                            }
                            else
                            {
                                if ([userID isEqualToString:@"1"])
                                {
                                    [customCell setOperatorCellContent:toUpdateUser.roles isEditMode:NO];
                                }
                                else
                                {
                                    [customCell setOperatorCellContent:toUpdateUser.roles isEditMode:YES];
                                }
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
                            customCell.contentField.text = currentUser.user_group.name;
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
                                [customCell setCellContent:toUpdateUser cellType:CELL_USER_LOGIN_ID viewMode:_type];
                                customCell.delegate = self;
                                
                                return customCell;
                            }
                            else
                            {
                                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailNormalCell" forIndexPath:indexPath];
                                UserDetailNormalCell *customCell = (UserDetailNormalCell*)cell;
                                customCell.titleLabel.text = NSLocalizedString(@"group", nil);
                                customCell.contentField.text = currentUser.user_group.name;
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
                                [customCell setCellContent:toUpdateUser cellType:CELL_USER_LOGIN_ID viewMode:_type];
                                customCell.delegate = self;
                                
                                return customCell;
                            }
                            else
                            {
                                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                                UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                                [customCell setCellContent:toUpdateUser cellType:CELL_USER_GROUP viewMode:_type hasOperator:hasOperator];
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
                    [customCell setCellContent:toUpdateUser cellType:CELL_USER_PASSWORD viewMode:_type];
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
                            customCell.contentField.text = currentUser.user_group.name;
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
                            [customCell setCellContent:toUpdateUser cellType:CELL_USER_GROUP viewMode:_type];
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
        // secion 1
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
                            customCell.contentField.text = NSLocalizedString(currentUser.status, nil);
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
                            [customCell setCellContent:toUpdateUser.status];
                            
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
                            [customCell setStartDate:currentUser.start_datetime andExpireDate:currentUser.expiry_datetime];
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailDateAccCell" forIndexPath:indexPath];
                            UserDetailDateAccCell *customCell = (UserDetailDateAccCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"period", nil);
                            [customCell setStartDate:toUpdateUser.start_datetime andExpireDate:toUpdateUser.expiry_datetime];
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
                            
                            count += (unsigned long)currentUser.access_groups.count;
                            count += (unsigned long)currentUser.access_groups_in_user_group.count;
                            customCell.contentField.text = [NSString stringWithFormat:@"%lu", (long)count];
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        case MODIFY_MODE:
                        case CREATE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:toUpdateUser cellType:CELL_USER_ACCESS_GROUP viewMode:_type];
                            customCell.delegate = self;
                            
                            return customCell;
                        }
                            break;
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            [customCell setCellContent:currentUser cellType:CELL_USER_ACCESS_GROUP viewMode:_type];
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
        // secion 2
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
                            
                            if ([PreferenceProvider isUpperVersion])
                            {
                                customCell.contentField.text = currentUser.fingerprint_template_count ? currentUser.fingerprint_template_count : @"0";
                            }
                            else
                            {
                                NSString *fingerprintCount = [NSString stringWithFormat:@"%ld", (unsigned long)currentUser.fingerprint_templates.count];
                                customCell.contentField.text = fingerprintCount;
                            }
                            
                            [customCell.contentField setEnabled:NO];
                            [customCell.contentField setSecureTextEntry:NO];
                            return customCell;
                            break;
                        }
                        
                        case CREATE_MODE:
                        {
                            if ([PreferenceProvider isUpperVersion])
                            {
                                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailSwitchCell" forIndexPath:indexPath];
                                UserDetailSwitchCell *customCell = (UserDetailSwitchCell*)cell;
                                customCell.delegate = self;
                                [customCell setCellPinContent:toUpdateUser.pin_exist];
                                
                                return customCell;
                            }
                            else
                            {
                                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                                UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                                customCell.titleLabel.text = NSLocalizedString(@"fingerprint", nil);
                                
                                if ([PreferenceProvider isUpperVersion])
                                {
                                    customCell.contentField.text = currentUser.fingerprint_template_count ? currentUser.fingerprint_template_count : @"0";
                                }
                                else
                                {
                                    NSString *fingerprintCount = [NSString stringWithFormat:@"%ld", (unsigned long)toUpdateUser.fingerprint_templates.count];
                                    customCell.contentField.text = fingerprintCount;
                                }
                                
                                [customCell.contentField setEnabled:NO];
                                [customCell.contentField setSecureTextEntry:NO];
                                return customCell;
                            }
                            
                        }
                            break;
                        case MODIFY_MODE:
                        case PROFILE_MODE:
                        {
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailAcclCell" forIndexPath:indexPath];
                            UserDetailAcclCell *customCell = (UserDetailAcclCell*)cell;
                            customCell.titleLabel.text = NSLocalizedString(@"fingerprint", nil);
                            
                            if ([PreferenceProvider isUpperVersion])
                            {
                                customCell.contentField.text = currentUser.fingerprint_template_count ? currentUser.fingerprint_template_count : @"0";
                            }
                            else
                            {
                                NSString *fingerprintCount = [NSString stringWithFormat:@"%ld", (unsigned long)toUpdateUser.fingerprint_templates.count];
                                customCell.contentField.text = fingerprintCount;
                            }
                            
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
                            if ([PreferenceProvider isUpperVersion])
                            {
                                NSString *cardCount = [NSString stringWithFormat:@"%ld", (unsigned long)toUpdateUser.card_count];
                                customCell.contentField.text = cardCount;
                            }
                            else
                            {
                                NSString *cardCount = [NSString stringWithFormat:@"%ld", (unsigned long)toUpdateUser.cards.count];
                                customCell.contentField.text = cardCount;
                            }
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
                            if ([PreferenceProvider isUpperVersion])
                            {
                                NSString *cardCount = [NSString stringWithFormat:@"%ld", (unsigned long)toUpdateUser.card_count];
                                customCell.contentField.text = cardCount;
                            }
                            else
                            {
                                NSString *cardCount = [NSString stringWithFormat:@"%ld", (unsigned long)toUpdateUser.cards.count];
                                customCell.contentField.text = cardCount;
                            }
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
                            [customCell setCellPinContent:toUpdateUser.pin_exist];
                            
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
    
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *cellTitle;
    
    if ([cell respondsToSelector:@selector(getTitle)])
    {
        cellTitle = [cell getTitle];
    }
    
    if (_type == VIEW_MODE)     // 뷰모드 일때
    {
        if ([cellTitle isEqualToString:NSLocalizedString(@"email", nil)])
        {
            if ([MFMailComposeViewController canSendMail])
            {
                if (nil != currentUser.email)
                {
                    NSArray *recipents = @[currentUser.email];
                    
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
        else if ([cellTitle isEqualToString:NSLocalizedString(@"telephone", nil)])
        {
            if (nil != currentUser.phone_number)
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", currentUser.phone_number]]];
        }
    }
    else
    {
        // 편집, 추가, 프로필
        if ([cellTitle isEqualToString:NSLocalizedString(@"operator", nil)])
        {
            if (_type == PROFILE_MODE) {
                return;
            }
            // 권한
            [self showPermissionPopup];
        }
        else if ([cellTitle isEqualToString:NSLocalizedString(@"password", nil)])
        {
            [self showPinPopup:PASSWORD];
        }
        else if ([cellTitle isEqualToString:NSLocalizedString(@"group", nil)])
        {
            if (_type != PROFILE_MODE)
            {
                [self showUserGroupPopup];
            }
        }
        else if ([cellTitle isEqualToString:NSLocalizedString(@"period", nil)])
        {
            if (_type != PROFILE_MODE)
            {
                [self showPeriodPopup];
            }
        }
        else if ([cellTitle isEqualToString:NSLocalizedString(@"access_group", nil)])
        {
            [self moveToVerificationViewController:ACCESS_GROUPS];
        }
        else if ([cellTitle isEqualToString:NSLocalizedString(@"fingerprint", nil)])
        {
            [self moveToFingerPrintCredentialViewController];
        }
        else if ([cellTitle isEqualToString:NSLocalizedString(@"card", nil)])
        {
            [self moveToCardCredentialViewController];
        }
        else if ([cellTitle isEqualToString:NSLocalizedString(@"pin_upper", nil)])
        {
            [self showPinPopup:PIN];
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



#pragma mark - UserDetailAccCellDelegate

- (void)userEmailDidChange:(NSString*)email
{
    toUpdateUser.email = email;
}

- (void)userTelephoneDidChange:(NSString*)telephone
{
    toUpdateUser.phone_number = telephone;
}

- (void)userNameDidChange:(NSString*)changedName
{
    toUpdateUser.name = changedName;
}

- (void)userIDDidChange:(NSString*)changedUserID
{
    toUpdateUser.user_id = changedUserID;
}

- (void)userLogin_IDDidChange:(NSString*)loginID
{
    toUpdateUser.login_id = loginID;
}

- (void)maxValueIsOver
{
    [self.view makeToast:NSLocalizedString(@"over_value", nil)
           duration:2.0 position:CSToastPositionTop
              image:[UIImage imageNamed:@"toast_popup_i_03"]];
}

#pragma mark - UserVerificationAddViewControllerDelegate

- (void)fingerprintWasChanged:(NSArray<FingerprintTemplate*>*)fingerprintTemplates
{
    if ([PreferenceProvider isUpperVersion])
    {
        isUpdatedOrDeleted = YES;
        toUpdateUser.fingerprint_template_count = [NSString stringWithFormat:@"%ld", fingerprintTemplates.count];
        currentUser.fingerprint_template_count = toUpdateUser.fingerprint_template_count;
    }
    else
    {
        toUpdateUser.fingerprint_templates = fingerprintTemplates;
    }
    
    [detailTableView reloadData];
}

- (void)accessGroupDidChange:(NSArray<UserItemAccessGroup*>*)groups
{
    toUpdateUser.access_groups = groups;
    [detailTableView reloadData];
}

- (void)cardWasChanged:(NSArray<Card*>*)cards
{
    toUpdateUser.cards = cards;
    [detailTableView reloadData];
}

#pragma mark - CardCredentialDelegate

- (void)cardDidChanged:(NSArray<Card*>*)cards
{
    isUpdatedOrDeleted = YES;
    toUpdateUser.card_count = cards.count;
    currentUser.card_count = cards.count;
    
    [detailTableView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 사진 찍었거나 선택후 편집 까지 마치면 호출됨
    NSLog(@"%@", info);
    UIImage *editedImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];

    UIImage* scaledImage = [CommonUtil imageCompress:editedImage fileSize:MAX_IMAGE_FILE_SIZE];
    
    NSData *photoData = [CommonUtil getImageDataCompress:scaledImage fileSize:MAX_IMAGE_FILE_SIZE];

    NSString *photoStr = [photoData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    
    toUpdateUser.photo = photoStr;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [detailTableView reloadData];
    }];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



#pragma mark - SwitchCellDelegate

- (void)switchValueDidChange:(UISwitch*)sender cell:(UITableViewCell*)theCell
{
    NSIndexPath *indexPath = [detailTableView indexPathForCell:theCell];
    
    if (indexPath.section == 1)
    {
        if (sender.isOn)
        {
            toUpdateUser.status = @"AC";
        }
        else
        {
            toUpdateUser.status = @"IN";
        }
    }
    else
    {
        if (sender.isOn)
        {
            [self showPinPopup:PIN];
        }
        else
        {
            toUpdateUser.pin_exist = NO;
            toUpdateUser.pin = @"";
        }
    }
    
    [detailTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end





