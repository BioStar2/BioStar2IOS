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

#import "ImagePopupViewController.h"

@interface ImagePopupViewController ()

@end

@implementation ImagePopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [containerView setHidden:YES];
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    if (nil != _content)
    {
        contentLabel.text = _content;
    }
    
    if (nil != _titleContent)
    {
        titleLabel.text = _titleContent;
    }
    
    switch (_type)
    {
        case MAIN_REQUEST_FAIL:
        case REQUEST_FAIL:
            [confirmButton setTitle:NSLocalizedString(@"retry", nil) forState:UIControlStateNormal];
            popupImage.image = [UIImage imageNamed:@"popup_error_ic"];
            containerHeightConstraint.constant = 400;
            break;
        case LOW_QUALITY:
            [confirmButton setTitle:NSLocalizedString(@"retry", nil) forState:UIControlStateNormal];
            popupImage.image = [UIImage imageNamed:@"popup_error_ic"];
            containerHeightConstraint.constant = 400;
            break;
        case WARNING:
        case DELETE_USERS:
            popupImage.image = [UIImage imageNamed:@"popup_error_ic"];
            containerHeightConstraint.constant = 320;
            break;
        case CARD_BLOCK:
            titleLabel.text = NSLocalizedString(@"block", nil);
            contentLabel.text = NSLocalizedString(@"question_block_card", nil);
            popupImage.image = [UIImage imageNamed:@"user_card_number_ic"];
            containerHeightConstraint.constant = 360;
            break;
        case CARD_RELEASE:
            titleLabel.text = NSLocalizedString(@"unblock", nil);
            contentLabel.text = NSLocalizedString(@"question_unblock_card", nil);
            popupImage.image = [UIImage imageNamed:@"user_card_number_ic"];
            containerHeightConstraint.constant = 360;
            break;
        case CARD_REGISTER:
            titleLabel.text = NSLocalizedString(@"mobile_card_upper", nil);
            contentLabel.text = NSLocalizedString(@"question_reregister_card", nil);
            popupImage.image = [UIImage imageNamed:@"user_card_number_ic"];
            containerHeightConstraint.constant = 360;
            break;
        case CARD_REREGISTER:
            titleLabel.text = NSLocalizedString(@"mobile_card_upper", nil);
            contentLabel.text = NSLocalizedString(@"question_reregister_card", nil);
            popupImage.image = [UIImage imageNamed:@"user_card_number_ic"];
            containerHeightConstraint.constant = 360;
            break;
        case USER_CREATED:
            titleLabel.text = NSLocalizedString(@"info", nil);
            contentLabel.text = NSLocalizedString(@"add_credential", nil);
            popupImage.image = [UIImage imageNamed:@"popup_check_ic"];
            containerHeightConstraint.constant = 400;
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

- (void)getResponse:(ImagePopupResponseBlock)responseBlock
{
    self.responseBlock = responseBlock;
}

- (IBAction)cancelCurrentPupup:(id)sender
{
    if (self.responseBlock)
    {
        self.responseBlock(_type, NO);
        self.responseBlock = nil;
    }
    [self closePopup:self parentViewController:self.parentViewController];

}

- (IBAction)confirmCurrentPopup:(id)sender
{
    if (self.responseBlock)
    {
        self.responseBlock(_type, YES);
        self.responseBlock = nil;
    }
    [self closePopup:self parentViewController:self.parentViewController];

}
@end
