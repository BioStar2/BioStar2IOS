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
    preferenceProvoder.delegate = self;
    // 업데이트 체크
    [self checkUpdate];
    
}

- (void)checkUpdate
{
    launchView = [[[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil] lastObject];
    [self.view addSubview:launchView];
    [launchView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.view layoutIfNeeded];
    
    [preferenceProvoder checkUpdate];
    [self startLoading:self];
    
}

- (void)setDefaultLoginInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (nil != [userDefaults objectForKey:@"ServerAddress"])
    {
        domain = [userDefaults objectForKey:@"ServerAddress"];
        [tempDomain setString:[userDefaults objectForKey:@"ServerAddress"]];
        domainLabel.text = [self parserDomain:[userDefaults objectForKey:@"ServerAddress"]];
        domainLabel.text = [self parserIPAddress:domainLabel.text];
    }
    else
    {
        domain = @"https://api.biostar2.com/v1";
        [tempDomain setString:domain];
        domainLabel.text = [self parserDomain:domain];
        domainLabel.text = [self parserIPAddress:domainLabel.text];
        [userDefaults setObject:domain forKey:@"ServerAddress"];
    }
    
    [[NetworkController sharedInstance] setServerURL:domain];
    
    if (nil != [userDefaults objectForKey:@"Name"])
    {
        subDomainLabel.text = [userDefaults objectForKey:@"Name"];
    }
    
    if (nil != [userDefaults objectForKey:@"userID"])
    {
        userID.text = [userDefaults objectForKey:@"userID"];
    }
    
    [userDefaults synchronize];
}

- (BOOL)checkCookie
{
    BOOL hasCookie = NO;
    
    NSHTTPCookieStorage * sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray * cookies = [sharedCookieStorage cookies];
    
    for (NSHTTPCookie * cookie in cookies){
        
        NSString *serverDomain = [[NSUserDefaults standardUserDefaults] objectForKey:@"ServerAddress"];
        if ([serverDomain rangeOfString:@"https://"].location != NSNotFound)
        {
            serverDomain = [serverDomain substringFromIndex:8];
        }
        else if([serverDomain rangeOfString:@"http://"].location != NSNotFound)
        {
            serverDomain = [serverDomain substringFromIndex:7];
        }
        
        if ([cookie.domain rangeOfString:serverDomain].location != NSNotFound)
        {
            hasCookie = YES;
            break;
        }
    }
    
    return hasCookie;
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

- (IBAction)login:(id)sender
{
    [self.view endEditing:YES];

    [editView setHidden:YES];
    subDomainImageView.image = [UIImage imageNamed:@"login_nor"];
    domainImageView.image = [UIImage imageNamed:@"login_nor"];
    domainLabel.textColor = normalColor;
    subDomainLabel.textColor = normalColor;
    
    
    [tempDomain setString:[tempDomain stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    domain = tempDomain;
    [[NetworkController sharedInstance] setServerURL:domain];
    
    // name 불러오기
    if ([subDomainLabel.text isEqualToString:@""])
    {
        // 알럿 팝업 띄우기
        [self showOneButtonPopup:NO type:LOGIN_INFO_LACK];
        return;
    }
    
    if ([userID.text isEqualToString:@""])
    {
        [self showOneButtonPopup:NO type:LOGIN_INFO_LACK];
        return;
    }
    
    if ([password.text isEqualToString:@""])
    {
        [self showOneButtonPopup:NO type:LOGIN_INFO_LACK];
        return;
    }
    
    [self startLoading:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    subDomainLabel.text = [subDomainLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    loginProvider = [[AuthProvider alloc] init];
    loginProvider.delegate = self;
    [loginProvider login:userID.text passwork:password.text name:subDomainLabel.text];
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
    domain = @"https://api.biostar2.com/v1";
    editTextField.text = domain;
    [tempDomain setString:domain];
    domainLabel.text = [self parserDomain:domain];
    domainLabel.text = [self parserIPAddress:domainLabel.text];
}


- (void)showImagePopup:(NSString*)title content:(NSString*)content needDelegate:(BOOL)needDelegate
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    ImagePopupViewController *imagePopupCtrl = [storyboard instantiateViewControllerWithIdentifier:@"ImagePopupViewController"];
    
    if (needDelegate)
    {
        imagePopupCtrl.delegate = self;
    }
    
    imagePopupCtrl.type = MAIN_REQUEST_FAIL;
    imagePopupCtrl.titleContent = title;
    [imagePopupCtrl setContent:content];
    
    [self showPopup:imagePopupCtrl parentViewController:self parentView:self.view];
}

- (void)showOneButtonPopup:(BOOL)needDelegate type:(Popup_Type)type
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:nil];
    OneButtonPopupViewController *sessionExpiredPopupController = [storyboard instantiateViewControllerWithIdentifier:@"OneButtonPopupViewController"];
    if (needDelegate)
    {
        sessionExpiredPopupController.delegate = self;
    }
    sessionExpiredPopupController.type = type;
    
    
    [self showPopup:sessionExpiredPopupController parentViewController:self parentView:self.view];
}

- (void)deleteCookie
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
    NSString *abnRegex = @"[A-Za-z0-9/:.]+"; // check for one or more occurrence of string you can also use * instead + for ignoring null value
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
            domainLabel.text = @"";
            [tempDomain setString:@""];
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
            
            if (range.length == 0)
            {
                // append
                if ([self validateSubDomain:string])
                    [content insertString:string atIndex:range.location];
                else
                    return NO;
            }
            else
            {
                //delete
                [content deleteCharactersInRange:range];
            }
            
            if ([self validateSubDomain:content])
                subDomainLabel.text = content;
            
        }
        else
        {
            content = [[NSMutableString alloc] initWithString:tempDomain];
            
            if (range.length == 0)
            {
                // append
                if ([self validateDomain:string])
                {
                    [content insertString:string atIndex:range.location];
                }
                else
                    return NO;
                
            }
            else
            {
                //delete
                [content deleteCharactersInRange:range];
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


#pragma mark - LoginProviderDelegate

- (void)loginDidFinish:(NSDictionary*)userInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"hasCookie"];
    
    [userDefaults setObject:[NSNumber numberWithInteger:0] forKey:@"UserCount"];
    [userDefaults setObject:[NSNumber numberWithInteger:0] forKey:@"DoorCount"];
    [userDefaults setObject:[NSNumber numberWithInteger:0] forKey:@"AlarmCount"];
    
    domain = tempDomain;
    [userDefaults setObject:domain forKey:@"ServerAddress"];
    [userDefaults setObject:subDomainLabel.text forKey:@"Name"];
    [userDefaults setObject:userID.text forKey:@"userID"];
    [userDefaults synchronize];
    
    [self finishLoading];
    
    [preferenceProvoder updateNotificationToken:[PreferenceProvider getDeviceToken]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController __weak *mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    
    [mainViewController setUserDic:userInfo];
    
    [self.navigationController pushViewController:mainViewController animated:YES];
    
}

- (void)loginDidFail:(NSDictionary*)errDic
{
    [self deleteCookie];
    
    isLoginFail = YES;
    errorType = LOGIN_FAIL;
    [self finishLoading];
    
    [self showImagePopup:NSLocalizedString(@"login_fail", nil) content:[errDic objectForKey:@"message"] needDelegate:YES];
    
}

#pragma mark - UserProviderDelegate

- (void)requestDidFinishGettingMyProfile:(NSDictionary*)result
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"hasCookie"];
    [userDefaults synchronize];
    
    [self finishLoading];
    
    [preferenceProvoder updateNotificationToken:[PreferenceProvider getDeviceToken]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController __weak *mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    
    [mainViewController setUserDic:result];
    
    [self.navigationController pushViewController:mainViewController animated:YES];
}

- (void)requestUserProviderDidFail:(NSDictionary*)errDic
{
    isLoginFail = NO;
    
    [self finishLoading];
    
    // 로그인 세션 만료
    if ([[errDic objectForKey:@"responseCode"] integerValue] == 401)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"hasCookie"];
        [userDefaults synchronize];
        
        [self showOneButtonPopup:YES type:SESSION_EXPIRED];
    }
    else
    {
        errorType = MYPROFILE_FAIL;
        [self showImagePopup:NSLocalizedString(@"fail_retry", nil) content:[errDic objectForKey:@"message"] needDelegate:YES];
    }
}

#pragma mark - PreferenceProviderDelegate

- (void)requestUpdateTokenDidFail:(NSDictionary*)errDic
{
    //[preferenceProvoder updateNotificationToken:[PreferenceProvider getDeviceToken]];
}

- (void)requestAppVersionDidFinish:(NSDictionary*)resultdic
{
    // 단말 버전 서버 버전 비교
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* deviceVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString* fouceUpdateVersion = [resultdic objectForKey:@"force_update_version"];
    
    if ([fouceUpdateVersion compare:deviceVersion options:NSNumericSearch] == NSOrderedDescending)
    {
        // 강제 업데이트 팝업
        [self finishLoading];
        [self showOneButtonPopup:YES type:FORCE_UPDATE_NEED];
    }
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL hasCookie = [[userDefaults objectForKey:@"hasCookie"] boolValue];
        if (hasCookie)
        {
            // 자동로그인 가능 해서 my_profile 호출
            userProvider = [[UserProvider alloc] init];
            userProvider.delegate = self;
            [userProvider getMyProfile];
            
        }
        else
            [self finishLoading];
        [launchView removeFromSuperview];
    }
}


- (void)requestPreferenceProviderDidFail:(NSDictionary*)errDic
{
    [self deleteCookie];
    
    errorType = UPDATE_CHECK_FAIL;
    [self showImagePopup:NSLocalizedString(@"fail_retry", nil) content:[errDic objectForKey:@"message"] needDelegate:YES];
}

#pragma mark - ImagePopupDelegate

- (void)confirmImagePopup
{
    switch (errorType)
    {
        case LOGIN_FAIL:
            [self login:nil];
            break;
            
        case MYPROFILE_FAIL:
            [userProvider getMyProfile];
            break;
            
        case UPDATE_CHECK_FAIL:
            [preferenceProvoder checkUpdate];
            break;
    }
    
    [self startLoading:self];
}

- (void)cancelImagePopup
{
    if (errorType == UPDATE_CHECK_FAIL)
    {
        [self finishLoading];
        [launchView removeFromSuperview];
    }
}

#pragma mark - OneButtonPopupDelegate

- (void)moveToAppstore
{
    NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[appName stringByReplacingOccurrencesOfString:@" " withString:@""]]];
    [[UIApplication sharedApplication] openURL:appStoreURL];
}

- (void)didComplete
{
    [self deleteCookie];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
