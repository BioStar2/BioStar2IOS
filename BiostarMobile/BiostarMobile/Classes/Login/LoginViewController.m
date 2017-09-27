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

#import "LoginViewController.h"
#import "ViewController.h"
#import "NetworkController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSharedViewController:self];
    [loginBtn setTitle:NSBaseLocalizedString(@"login", nil) forState:UIControlStateNormal];
    //loginScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    currentController = self;
    isLoginFail = NO;
    isEditingSubdomain = YES;
    
    tempDomain = [[NSMutableString alloc] initWithString:@""];
    
    normalColor = [CommonUtil colorFromHexString:@"#c6c6c6"];
    highlighitColor = [CommonUtil colorFromHexString:@"#8b43a3"];
    
    domainLabel.textColor = normalColor;
    subDomainLabel.textColor = normalColor;
    
    UIColor *color = [CommonUtil colorFromHexString:@"#8b43a3"];
    
    color = [CommonUtil colorFromHexString:@"#999999"];
    userID.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"User ID" attributes:@{NSForegroundColorAttributeName: color}];
    
    password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    
    
    UIFont *customFont = nil;
    customFont = [UIFont fontWithName:@"Roboto-Bold" size:userID.font.pointSize];
    
    userID.font = customFont;
    password.font = customFont;
    
    [self setDefaultLoginInfo];
    
    preferenceProvoder = [[PreferenceProvider alloc] init];
    userProvider = [[UserProvider alloc] init];
    
    [self checkUpdateForAutoLogin];
    
    
}



- (void)setLaunchView
{
    launchView = [[[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil] lastObject];
    [self.view addSubview:launchView];
    [launchView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.view layoutIfNeeded];
}

- (void)moveToMainViewController:(User *)userInfo
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController __weak *mainViewController;
    mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    //[mainViewController setUser:userInfo];
    
    [self.navigationController pushViewController:mainViewController animated:YES];
    
}

- (void)updatePushNotificationToken:(NSString*)token
{
    if (nil != token)
    {
        [preferenceProvoder updateNotificationToken:token resultBlock:^(Response *response) {
            
        } onError:^(Response *error) {
            [self updatePushNotificationToken:token];
        }];
        
    }
    
    
}


- (void)checkUpdateForAutoLogin
{
    
    if ([subDomainLabel.text isEqualToString:@""])
    {
        [LocalDataManager deleteLocalCookies];
    }
    
    [[NetworkController sharedInstance] setServerURL:domain cloudVersion:@"v2"];
//    if ([PreferenceProvider isUpperVersion])
//    {
//        [[NetworkController sharedInstance] setServerURL:domain cloudVersion:@"v2"];
//    }
//    else
//    {
//        [[NetworkController sharedInstance] setServerURL:domain cloudVersion:@"v1"];
//    }
    
    NSLog(@"[NetworkController sharedInstance] %@", [NetworkController sharedInstance].serverURL);
    
    [self startLoading:self];
    
    [preferenceProvoder checkUpdateWithCompleteHandler:^(AppVersionInfo *versionInfo) {
        
        // 단말 버전 서버 버전 비교
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString* deviceVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
        ;
        
        if ([versionInfo.force_update_version compare:deviceVersion options:NSNumericSearch] == NSOrderedDescending)
        {
            // 강제 업데이트 팝업
            [self finishLoading];
            [self showOneButtonPopupType:FORCE_UPDATE_NEED];
        }
        else
        {
            BOOL hasCookie = [LocalDataManager hasStoredCooikes];
            if (hasCookie)
            {
                // 자동로그인 가능 해서 my_profile 호출
                [self autoLogin];
            }
            else
            {
                [self finishLoading];
            }
        }
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        [LocalDataManager deleteLocalCookies];
        
        errorType = UPDATE_CHECK_FAIL;
        [self showImagePopup:NSBaseLocalizedString(@"fail_retry", nil) content:error.message];
    }];
    
}

- (void)checkUpdate
{
    [self startLoading:self];
    
    [preferenceProvoder checkUpdateWithCompleteHandler:^(AppVersionInfo *versionInfo) {
        
        // 단말 버전 서버 버전 비교
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString* deviceVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
        ;
        
        if ([versionInfo.force_update_version compare:deviceVersion options:NSNumericSearch] == NSOrderedDescending)
        {
            // 강제 업데이트 팝업
            [self finishLoading];
            [self showOneButtonPopupType:FORCE_UPDATE_NEED];
        }
        else
        {
            [self requestLogin];
            
        }
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        [LocalDataManager deleteLocalCookies];
        
        errorType = UPDATE_CHECK_FAIL;
        [self showImagePopup:NSBaseLocalizedString(@"fail_retry", nil) content:error.message];
    }];
    
}

- (void)autoLogin
{
    [self startLoading:self];
    [userProvider getMyProfile:^(User *userResult) {
        [self finishLoading];
        
        [self updatePushNotificationToken:[PreferenceProvider getDeviceToken]];
        
        [self moveToMainViewController:userResult];
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        isLoginFail = NO;

        [LocalDataManager deleteLocalCookies];
        errorType = MYPROFILE_FAIL;
        [self showImagePopup:NSBaseLocalizedString(@"fail_retry", nil) content:error.message];

        
    }];
    
    
}

- (void)setDefaultLoginInfo {
    
    NSString *serverAddress = [LocalDataManager getServerAddress];
    
    if (nil != serverAddress)
    {
        NSLog(@"nil != serverAddress");
        domain = serverAddress;
        [tempDomain setString:serverAddress];
        domainLabel.text = [self parserDomain:serverAddress];
        domainLabel.text = [self parserIPAddress:domainLabel.text];
    }
    else
    {
        NSLog(@"nil == serverAddress");
        domain = @"https://api.biostar2.com";
        [tempDomain setString:domain];
        domainLabel.text = [self parserDomain:domain];
        domainLabel.text = [self parserIPAddress:domainLabel.text];
        [LocalDataManager setServerAddress:domain];
    }
    
    
    if (nil != [LocalDataManager getName])
    {
        subDomainLabel.text = [LocalDataManager getName];
    }
    
    if (nil != [LocalDataManager getUserLoginID])
    {
        userID.text = [LocalDataManager getUserLoginID];
    }
    
#warning 외부 테스트용 코드
//    domain = @"https://apitest.biostar2.com";
//    [tempDomain setString:domain];
//    domainLabel.text = [self parserDomain:domain];
//    domainLabel.text = [self parserIPAddress:domainLabel.text];
//    subDomainLabel.text = @"alphatest2";
//    [LocalDataManager setServerAddress:domain];
}


- (NSString*)parserDomain:(NSString*)domainName
{
    NSString *parsedDomain = domainName;
    if ([domainName rangeOfString:@"https://"].location != NSNotFound)
    {
        parsedDomain = [domainName substringFromIndex:8];
    }
    else if([domainName rangeOfString:@"http://"].location != NSNotFound)
    {
        parsedDomain = [domainName substringFromIndex:7];
    }
    
    NSArray *domainArray = [parsedDomain componentsSeparatedByString:@"/"];
    
    if (domainArray.count > 1)
    {
        NSMutableString *mutableDomain = [[NSMutableString alloc] init];
        for (int i = 0; i < domainArray.count - 1; i++)
        {
            [mutableDomain appendString:[domainArray objectAtIndex:i]];
        }
        
        parsedDomain = mutableDomain;
    }
    
    
    return parsedDomain;
}

- (NSString*)parserIPAddress:(NSString*)domainName
{
    NSString *parsedDomain = domainName;
    
    if (![CommonUtil matchingByRegex:@"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$" withField:domainName])
    {
        NSLog(@"not ip address");
        NSRange range;
        range = [parsedDomain rangeOfString:@"."];
        if (parsedDomain.length > range.location + 1)
        {
            parsedDomain = [parsedDomain substringFromIndex:range.location + 1];
        }
    }

    return parsedDomain;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIFont *maxFont = [UIFont fontWithName:biostarLabel.font.fontName size:19];
    UIFont *middleFont = [UIFont fontWithName:biostarLabel.font.fontName size:12];
    UIFont *smallFont = [UIFont fontWithName:biostarLabel.font.fontName size:11];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString* buildversion = [infoDict objectForKey:@"CFBundleVersion"];
    
    NSString *totalVersion = [NSString stringWithFormat:@"%@.%@",version ,buildversion];
    
    version = [NSString stringWithFormat:@"BioStar 2 Mobile %@", totalVersion];
    
    NSMutableAttributedString *decString= [[NSMutableAttributedString alloc] initWithString:version];
    [decString addAttribute:NSFontAttributeName
                      value:maxFont
                      range:NSMakeRange(0, 8)];
    
    [decString addAttribute:NSFontAttributeName
                      value:middleFont
                      range:NSMakeRange(10, 6)];
    
    [decString addAttribute:NSFontAttributeName
                      value:smallFont
                      range:NSMakeRange(16, version.length - 16)];
    
    biostarLabel.attributedText = decString;
    
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


- (void)requestLogin
{
    [editView setHidden:YES];
    subDomainImageView.image = [UIImage imageNamed:@"login_nor"];
    domainImageView.image = [UIImage imageNamed:@"login_nor"];
    domainLabel.textColor = normalColor;
    subDomainLabel.textColor = normalColor;
    
    
    
    
    [self startLoading:self];
    
    subDomainLabel.text = [subDomainLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    loginProvider = [[AuthProvider alloc] init];
    
    [loginProvider login:userID.text password:password.text name:subDomainLabel.text userBlock:^(User *userResult) {
        [self finishLoading];
        
        password.text = @"";
        
        [LocalDataManager setDoorCount:0];
        [LocalDataManager setUserCount:0];
        
        
        domain = tempDomain;
        [LocalDataManager setServerAddress:domain];
        [LocalDataManager setName:subDomainLabel.text];
        [LocalDataManager setUserLoginID:userID.text];
        
        [self updatePushNotificationToken:[PreferenceProvider getDeviceToken]];
        
        [self autoLogin];
        //[self moveToMainViewController:userResult];
        
    } onError:^(Response *error) {
        [self finishLoading];
        
        [LocalDataManager deleteLocalCookies];
        
        isLoginFail = YES;
        errorType = LOGIN_FAIL;
        
        
        [self showImagePopup:NSBaseLocalizedString(@"login_fail", nil) content:error.message];
    }];
}

- (IBAction)login:(id)sender
{
#warning 2.3.0 테스트용
//    [self.view endEditing:YES];
//    [LocalDataManager setBiostarACVersion:@"2.3.0"];
//    [[NetworkController sharedInstance] setServerURL:domain cloudVersion:@"V1"];
//    [self checkUpdate];
    
    [self.view endEditing:YES];

    if ([subDomainLabel.text isEqualToString:@""])
    {
        // 알럿 팝업 띄우기
        [self showOneButtonPopupType:LOGIN_INFO_LACK];
        return;
    }
    
    // name 불러오기
    if ([subDomainLabel.text isEqualToString:@""])
    {
        // 알럿 팝업 띄우기
        [self showOneButtonPopupType:LOGIN_INFO_LACK];
        return;
    }
    
    if ([userID.text isEqualToString:@""])
    {
        [self showOneButtonPopupType:LOGIN_INFO_LACK];
        return;
    }
    
    if ([password.text isEqualToString:@""])
    {
        [self showOneButtonPopupType:LOGIN_INFO_LACK];
        return;
    }
    
    [LocalDataManager deleteLocalCookies];
    
    [self startLoading:self];
    
    [[NetworkController sharedInstance] setServerURL:tempDomain cloudVersion:@"v2"];
    
    NSLog(@"- (IBAction)login:(id)sender : %@",[NetworkController sharedInstance].serverURL);
    
    [preferenceProvoder getBiostarVersion:subDomainLabel.text onComplete:^(BioStarVersion *result) {
        
        [self finishLoading];
        
        if (result.biostar_ac_version)
        {
            //[LocalDataManager setBiostarACVersion:@"2.4.0.7"];
            [LocalDataManager setBiostarACVersion:result.biostar_ac_version];
            
            [tempDomain setString:[tempDomain stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            domain = tempDomain;
            
            if ([PreferenceProvider isUpperVersion])
            {
                [[NetworkController sharedInstance] setServerURL:domain cloudVersion:@"v2"];
            }
            else
            {
                [[NetworkController sharedInstance] setServerURL:domain cloudVersion:@"v1"];
            }
            
            [self checkUpdate];
        }
        else
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
            ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
            
            imagePopupCtrl.type = MAIN_REQUEST_FAIL;
            imagePopupCtrl.titleContent = NSBaseLocalizedString(@"login_fail", nil);
            [imagePopupCtrl setContent:@"biostar_ac_version invalid"];
            
            [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
            
            [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
                if (isConfirm)
                {
                    [self login:nil];
                }
            }];
        }
        
        
        
    } onError:^(Response *error) {
        
        [self finishLoading];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
        ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
        
        imagePopupCtrl.type = MAIN_REQUEST_FAIL;
        imagePopupCtrl.titleContent = NSBaseLocalizedString(@"login_fail", nil);
        [imagePopupCtrl setContent:error.message];
        
        [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
        
        [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
            if (isConfirm)
            {
                [self login:nil];
            }
        }];
        
    }];
    
}

- (IBAction)showQuickGuide:(id)sender
{
    [self.view endEditing:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QuickStartGuideViewController __weak *guideViewController = [storyboard instantiateViewControllerWithIdentifier:@"QuickStartGuideViewController"];
    
    [self presentViewController:guideViewController animated:YES completion:^{
        
    }];
    
}

- (IBAction)editDomain:(id)sender
{
    domainLabel.textColor = highlighitColor;
    subDomainLabel.textColor = normalColor;
    [editView setHidden:NO];
    isEditingSubdomain = NO;
    [domainTailImageView setHidden:NO];
    [subdomainTailImageView setHidden:YES];
    [editTextField becomeFirstResponder];
    [refreshButton setHidden:NO];
    
    subDomainImageView.image = [UIImage imageNamed:@"login_nor"];
    domainImageView.image = [UIImage imageNamed:@"login_tab"];
    
    editTextField.text = tempDomain;
}

- (IBAction)editSubDomain:(id)sender
{
    domainLabel.textColor = normalColor;
    subDomainLabel.textColor = highlighitColor;
    [editView setHidden:NO];
    isEditingSubdomain = YES;
    [domainTailImageView setHidden:YES];
    [subdomainTailImageView setHidden:NO];
    [editTextField becomeFirstResponder];
    [refreshButton setHidden:YES];
    
    subDomainImageView.image = [UIImage imageNamed:@"login_tab"];
    domainImageView.image = [UIImage imageNamed:@"login_nor"];
    
    editTextField.text = subDomainLabel.text;
}

- (IBAction)resetDomain:(id)sender
{
    editTextField.text = @"";
    domain = @"https://api.biostar2.com";
    editTextField.text = domain;
    [tempDomain setString:domain];
    domainLabel.text = [self parserDomain:domain];
    domainLabel.text = [self parserIPAddress:domainLabel.text];
}


- (void)showImagePopup:(NSString*)title content:(NSString*)content
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    
    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    imagePopupCtrl.titleContent = title;
    [imagePopupCtrl setContent:content];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
    
    [imagePopupCtrl getResponse:^(ImagePopupType type, BOOL isConfirm) {
        if (isConfirm)
        {
            switch (errorType)
            {
                case LOGIN_FAIL:
                    [self login:nil];
                    break;
                    
                case MYPROFILE_FAIL:
                    [self autoLogin];
                    break;
                    
                case UPDATE_CHECK_FAIL:
                    [self checkUpdate];
                    break;
            }
        }
        else
        {
            if (errorType == UPDATE_CHECK_FAIL)
            {
                if (launchView)
                {
                    [launchView removeFromSuperview];
                }
            }
        }
    }];
}

- (void)showOneButtonPopupType:(OneButtonPopupType)type
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *sessionExpiredPopupController = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    sessionExpiredPopupController.type = type;
    [self showPopup:sessionExpiredPopupController parentViewController:self parentView:self.view];
    
    [sessionExpiredPopupController getResponse:^(OneButtonPopupType type) {
        if (type == FORCE_UPDATE_NEED)
        {
            NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
            NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[appName stringByReplacingOccurrencesOfString:@" " withString:@""]]];
            [[UIApplication sharedApplication] openURL:appStoreURL];
        }
        else if(type == SESSION_EXPIRED)
        {
            [LocalDataManager deleteLocalCookies];
            
        }
    }];
}


- (BOOL)validateSubDomain:(NSString*)string
{
    if ([string isEqualToString:@""])
    {
        return YES;
    }
    NSString *abnRegex = @"[a-z0-9-]+"; // check for one or more occurrence of string you can also use * instead + for ignoring null value
    NSPredicate *abnTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", abnRegex];
    BOOL isValid = [abnTest evaluateWithObject:string];
    return isValid;
}

- (BOOL)validateDomain:(NSString*)string
{
    if ([string isEqualToString:@""])
    {
        return YES;
    }
    NSString *abnRegex = @"[A-Za-z0-9/:._]+"; // check for one or more occurrence of string you can also use * instead + for ignoring null value
    NSPredicate *abnTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", abnRegex];
    BOOL isValid = [abnTest evaluateWithObject:string];
    return isValid;
}



#pragma mark - UITExtField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (userID == textField || password == textField)
    {
        [editView setHidden:YES];
        subDomainImageView.image = [UIImage imageNamed:@"login_nor"];
        domainImageView.image = [UIImage imageNamed:@"login_nor"];
        domainLabel.textColor = normalColor;
        subDomainLabel.textColor = normalColor;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    domainLabel.textColor = normalColor;
    subDomainLabel.textColor = normalColor;
    [domainTailImageView setHidden:YES];
    [subdomainTailImageView setHidden:YES];
    [refreshButton setHidden:YES];
    subDomainImageView.image = [UIImage imageNamed:@"login_nor"];
    domainImageView.image = [UIImage imageNamed:@"login_nor"];
    if (editTextField == textField)
    {
        if (isEditingSubdomain)
        {
            domainLabel.textColor = highlighitColor;
            subDomainLabel.textColor = normalColor;
            [refreshButton setHidden:NO];
            [editTextField becomeFirstResponder];
            isEditingSubdomain = NO;
            [domainTailImageView setHidden:NO];
            domainImageView.image = [UIImage imageNamed:@"login_tab"];
        }
        else
        {
            [userID becomeFirstResponder];
            [editView setHidden:YES];
        }
        
    }
    if (userID == textField)
    {
        [password becomeFirstResponder];
    }
    if (password == textField)
    {
        [self login:nil];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == editTextField)
    {
        if (isEditingSubdomain)
        {
            subDomainLabel.text = @"";
        }
        else
        {
            textField.text = @"https://";
            domainLabel.text = @"https://";
            [tempDomain setString:@"https://"];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == editTextField)
    {
        
        NSMutableString *content;
        
        if (isEditingSubdomain)
        {
            content = [[NSMutableString alloc] initWithString:subDomainLabel.text];
            
            if (![string isEqualToString:@""])
            {
                // append
                if ([self validateSubDomain:string])
                    @try {
                        [content insertString:string atIndex:range.location];
                    } @catch (NSException *exception) {
                        NSLog(@"%@ \n %@", exception.description, content);
                    }
                
                else
                    return NO;
            }
            else
            {
                //delete
                @try {
                    [content deleteCharactersInRange:range];
                } @catch (NSException *exception) {
                    NSLog(@"%@ \n %@", exception.description, content);
                }
            }
            
            if ([self validateSubDomain:content])
                subDomainLabel.text = content;
            
        }
        else
        {
            content = [[NSMutableString alloc] initWithString:tempDomain];
            
            if (![string isEqualToString:@""])
            {
                // append
                if ([self validateDomain:string])
                {
                    @try {
                        [content insertString:string atIndex:range.location];
                    } @catch (NSException *exception) {
                        NSLog(@"%@ \n %@", exception.description, content);
                    }
                    
                }
                else
                    return NO;
                
            }
            else
            {
                //delete
                if ([content isEqualToString:@"https://"])
                {
                    return NO;
                }
                @try {
                    [content deleteCharactersInRange:range];
                } @catch (NSException *exception) {
                    NSLog(@"%@ \n %@", exception.description, content);
                }
                
            }
            
            domainLabel.text = [self parserDomain:content];
            domainLabel.text = [self parserIPAddress:domainLabel.text];
            [tempDomain setString:content];
        }
        return YES;
    }
    else
        return YES;
}

#pragma mark - KeyBoard Noti

- (void)keyboardWillShow:(NSNotification*)notification
{
    // 에디트 필드가 활성화 되었을때 이미지 변경
    if (editTextField.isFirstResponder)
    {
        if (isEditingSubdomain)
        {
            [refreshButton setHidden:YES];
            subDomainImageView.image = [UIImage imageNamed:@"login_tab"];
            domainImageView.image = [UIImage imageNamed:@"login_nor"];
            [domainTailImageView setHidden:YES];
            [subdomainTailImageView setHidden:NO];
            
            editTextField.text = subDomainLabel.text;
        }
        else
        {
            [refreshButton setHidden:NO];
            subDomainImageView.image = [UIImage imageNamed:@"login_nor"];
            domainImageView.image = [UIImage imageNamed:@"login_tab"];
            [domainTailImageView setHidden:NO];
            [subdomainTailImageView setHidden:YES];
            
            editTextField.text = tempDomain;
        }
    }
    else
    {
        [refreshButton setHidden:YES];
        subDomainImageView.image = [UIImage imageNamed:@"login_nor"];
        domainImageView.image = [UIImage imageNamed:@"login_nor"];
        [domainTailImageView setHidden:YES];
        [subdomainTailImageView setHidden:YES];
    }
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    scrollViewVerticalConstraint.constant = kbSize.height;
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    scrollViewVerticalConstraint.constant = 0;
}

@end
