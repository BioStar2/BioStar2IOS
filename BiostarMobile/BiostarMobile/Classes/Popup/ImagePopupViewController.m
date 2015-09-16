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
    
    if (nil != _content)
    {
        contentLabel.text = _content;
    }
    
    if (nil != _titleContent)
    {
        titleLabel.text = _titleContent;
    }
    
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:titleLabel.font, NSFontAttributeName, nil];
//    CGFloat height = [[[NSAttributedString alloc] initWithString:titleLabel.text attributes:attributes] size].height;
    
    switch (_type)
    {
        case MAIN_REQUEST_FAIL:
        case REQUEST_FAIL:
            [confirmButton setTitle:NSLocalizedString(@"retry", nil) forState:UIControlStateNormal];
            popupImage.image = [UIImage imageNamed:@"popup_error_ic"];
            containerHeightConstraint.constant = 400;
            break;
            
        case WARNING:
        case DELETE_USERS:
            popupImage.image = [UIImage imageNamed:@"popup_error_ic"];
            containerHeightConstraint.constant = 320;
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

- (IBAction)cancelCurrentPupup:(id)sender
{
    if (_type == MAIN_REQUEST_FAIL)
    {
        if ([self.delegate respondsToSelector:@selector(cancelImagePopup)])
        {
            [self.delegate cancelImagePopup];
        }
    }
    [self closePopup:self parentViewController:self.parentViewController];
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(confirmImagePopup)])
    {
        [self.delegate confirmImagePopup];
    }
    [self closePopup:self parentViewController:self.parentViewController];
}
@end
