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
#import "CommonUtil.h"
#import "BaseViewController.h"
#import "AuthProvider.h"
#import "UserProvider.h"
#import "ImagePopupViewController.h"
#import "OneButtonPopupViewController.h"
#import "PreferenceProvider.h"
#import "QuickStartGuideViewController.h"

typedef enum{
    LOGIN_FAIL,
    MYPROFILE_FAIL,
    UPDATE_CHECK_FAIL,
} ErrorType;

@interface LoginViewController : BaseViewController <UITextFieldDelegate, AuthProviderDelegate, ImagePopupDelegate, UserProviderDelegate, OneButtonPopupDelegate, PreferenceProviderDelegate>
{
    __weak IBOutlet NSLayoutConstraint *scrollViewVerticalConstraint;
    __weak IBOutlet UITextField *userID;
    __weak IBOutlet UITextField *password;
    __weak IBOutlet UITextField *editTextField;
    __weak IBOutlet UIImageView *subdomainTailImageView;
    __weak IBOutlet UIImageView *domainTailImageView;
    __weak IBOutlet UILabel *subDomainLabel;
    __weak IBOutlet UILabel *domainLabel;
    __weak IBOutlet UIImageView *subDomainImageView;
    __weak IBOutlet UIImageView *domainImageView;
    __weak IBOutlet UIButton *refreshButton;
    __weak IBOutlet UIView *editView;
    
    
    UIView *launchView;
    UIColor *normalColor;
    UIColor *highlighitColor;
    NSString *domain;
    NSMutableString *tempDomain;
    
    AuthProvider *loginProvider;
    UserProvider *userProvider;
    PreferenceProvider *preferenceProvoder;
    BOOL isLoginFail;
    BOOL isEditingSubdomain;
    ErrorType errorType;
}

- (IBAction)login:(id)sender;
- (IBAction)showQuickGuide:(id)sender;
- (IBAction)editDomain:(id)sender;
- (IBAction)editSubDomain:(id)sender;
- (IBAction)resetDomain:(id)sender;

- (NSString*)parserDomain:(NSString*)domainName;
- (NSString*)parserIPAddress:(NSString*)domainName;
- (BOOL)checkCookie;
- (void)setDefaultLoginInfo;
- (void)showImagePopup:(NSString*)title content:(NSString*)content needDelegate:(BOOL)needDelegate;
- (void)showOneButtonPopup:(BOOL)needDelegate type:(Popup_Type)type;
- (void)checkUpdate;
- (void)deleteCookie;
@end
