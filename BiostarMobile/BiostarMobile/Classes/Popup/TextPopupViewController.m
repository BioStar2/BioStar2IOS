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

#import "TextPopupViewController.h"

@interface TextPopupViewController ()

@end

@implementation TextPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [containerView setHidden:YES];
    
    [cancelBtn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    switch (_type)
    {
        case USER_DELETE:
            titleLabel.text = NSLocalizedString(@"delete_user", nil);
            contentLabel.text = NSLocalizedString(@"delete_confirm_question", nil);
            break;
            
        case ALARM_DELETE:
            titleLabel.text = NSLocalizedString(@"delete_alarm", nil);
            contentLabel.text = NSLocalizedString(@"delete_confirm_question", nil);
            heightConstraint.constant = 200;
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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


- (void)getResponse:(TextPopupResponseBlock)responseBlock
{
    self.responseBlock = responseBlock;
}

- (void)setContent:(NSString*)content
{
    contentText = content;
}

- (IBAction)cancelCurrentPopup:(id)sender
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
