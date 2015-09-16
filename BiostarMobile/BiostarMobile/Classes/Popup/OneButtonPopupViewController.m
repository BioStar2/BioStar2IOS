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
    [containerView setHidden:YES];
    switch (_type)
    {
        case UPDATE_USER:
            titleLabel.text = NSLocalizedString(@"info", nil);
            contentLabel.text = NSLocalizedString(@"user_modify_success", nil);
            break;
        case CREATE_USER:
            titleLabel.text = NSLocalizedString(@"info", nil);
            contentLabel.text = NSLocalizedString(@"user_create_success", nil);
            break;
        case SESSION_EXPIRED:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSLocalizedString(@"notification", nil);
            contentLabel.text = NSLocalizedString(@"login_expire", nil);
            break;
        case FINGERPRINT_VERIFICATION_FAIL:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSLocalizedString(@"notification", nil);
            contentLabel.text = NSLocalizedString(@"fail_verify_finger", nil);
            break;
        case USER_INFO_VERIFICATION_FAIL:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSLocalizedString(@"info", nil);
            contentLabel.text = _popupContent;
            break;
        case LOGIN_INFO_LACK:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSLocalizedString(@"info", nil);
            contentLabel.text = NSLocalizedString(@"login_empty", nil);
            break;
        case FORCE_UPDATE_NEED:
            notiImage.image = [UIImage imageNamed:@"popup_error_ic"];
            titleLabel.text = NSLocalizedString(@"notification", nil);
            contentLabel.text = NSLocalizedString(@"forceUpdate", nil);
            break;
        case SETTING:
            titleLabel.text = NSLocalizedString(@"info", nil);
            contentLabel.text = NSLocalizedString(@"success", nil);
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

- (IBAction)closePopup:(id)sender
{
    switch (_type)
    {
        case FORCE_UPDATE_NEED:
            if ([self.delegate respondsToSelector:@selector(moveToAppstore)])
            {
                [self.delegate moveToAppstore];
            }
            break;
        case UPDATE_USER:
            if ([self.delegate respondsToSelector:@selector(updateComplete)])
            {
                [self.delegate updateComplete];
            }
            [self closePopup:self parentViewController:self.parentViewController];
            break;
        case SETTING:
            if ([self.delegate respondsToSelector:@selector(didComplete)])
            {
                [self.delegate didComplete];
            }
            [self closePopup:self parentViewController:self.parentViewController];
        case CREATE_USER:
            if ([self.delegate respondsToSelector:@selector(createComplete)])
            {
                [self.delegate createComplete];
            }
            [self closePopup:self parentViewController:self.parentViewController];
            break;
        case FINGERPRINT_VERIFICATION_FAIL:
            if ([self.delegate respondsToSelector:@selector(fingerprintVarificationFailed)])
            {
                [self.delegate fingerprintVarificationFailed];
            }
            [self closePopup:self parentViewController:self.parentViewController];
            break;
        default:
            if ([self.delegate respondsToSelector:@selector(didComplete)])
            {
                [self.delegate didComplete];
            }
            [self closePopup:self parentViewController:self.parentViewController];
            break;
    }
}
@end
