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

#import "OneButtonPopupViewController.h"

@interface OneButtonPopupViewController ()

@end

@implementation OneButtonPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [containerView setHidden:YES];
    switch (_type)
    {
        case UPDATE_USER:
            titleLabel.text = NSBaseLocalizedString(@"info", nil);
            contentLabel.text = NSBaseLocalizedString(@"user_modify_success", nil);
            break;
        case CREATE_USER:
            titleLabel.text = NSBaseLocalizedString(@"info", nil);
            contentLabel.text = NSBaseLocalizedString(@"user_create_success", nil);
            break;
        case SESSION_EXPIRED:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSBaseLocalizedString(@"notification", nil);
            contentLabel.text = NSBaseLocalizedString(@"login_expire", nil);
            break;
        case FINGERPRINT_VERIFICATION_FAIL:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSBaseLocalizedString(@"notification", nil);
            contentLabel.text = NSBaseLocalizedString(@"fail_verify_finger", nil);
            break;
        case USER_INFO_VERIFICATION_FAIL:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSBaseLocalizedString(@"info", nil);
            contentLabel.text = _popupContent;
            break;
        case LOGIN_INFO_LACK:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSBaseLocalizedString(@"info", nil);
            contentLabel.text = NSBaseLocalizedString(@"login_empty", nil);
            break;
        case FORCE_UPDATE_NEED:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSBaseLocalizedString(@"notification", nil);
            contentLabel.text = NSBaseLocalizedString(@"forceUpdate", nil);
            break;
        case SETTING:
            titleLabel.text = NSBaseLocalizedString(@"info", nil);
            contentLabel.text = NSBaseLocalizedString(@"success", nil);
            break;
        case CARD_CHANGED:
            titleLabel.text = NSBaseLocalizedString(@"info", nil);
            contentLabel.text = NSBaseLocalizedString(@"success", nil);
            break;
        case PERMISSION_DENIED:
            titleLabel.text = NSBaseLocalizedString(@"info", nil);
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            contentLabel.text = _popupContent;
            break;
        case SAVE_REQUEST_FAIL:
            titleLabel.text = NSBaseLocalizedString(@"fail", nil);
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            heightConstraint.constant = 400;
            contentLabel.text = _popupContent;
            break;
        case DOOR_CONTROL:
            heightConstraint.constant = 400;
            titleLabel.text = _titleStr;
            notiImage.image = [UIImage imageNamed:@"popup_door_ic"];
            contentLabel.text = _popupContent;
            break;
        case BLE_POWER_OFF:
            titleLabel.text = NSBaseLocalizedString(@"info", nil);
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            contentLabel.text = NSBaseLocalizedString(@"need_turn_on_ble", nil);;
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [super popupViewDidAppear:contentView];
    [containerView setHidden:NO];
    [self showPopupAnimation:containerView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getResponse:(ResponseBlock)responseBlock
{
    self.responseBlock = responseBlock;
}

- (IBAction)closePopup:(id)sender
{
    if (self.responseBlock)
    {
        self.responseBlock(_type);
        self.responseBlock = nil;
    }
    [self closePopup:self parentViewController:self.parentViewController];
}
@end
