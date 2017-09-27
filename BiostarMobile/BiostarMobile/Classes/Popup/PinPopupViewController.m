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

#import "PinPopupViewController.h"


@interface PinPopupViewController ()

@end

@implementation PinPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [cancelBtn setTitle:NSBaseLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [confirmBtn setTitle:NSBaseLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    
    switch (_type)
    {
        case PIN:
            titleLabel.text = NSBaseLocalizedString(@"pin_upper", nil);
            break;
            
        case PASSWORD:
            titleLabel.text = NSBaseLocalizedString(@"password", nil);
            contentViewHeightConstraint.constant = 320;
            break;
    }
    
    [containerView setHidden:YES];
    pinTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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


- (IBAction)cancelCurrentPopup:(id)sender
{
    [self.view endEditing:YES];
    [self closePopup:self parentViewController:self.parentViewController];
}

- (BOOL)checkPasswordStrengthLevel
{
    NSString *password_strength_level;
    if ([PreferenceProvider isUpperVersion])
    {
        password_strength_level = [PreferenceProvider getBioStarSetting].password_strength_level;
    }
    else
    {
        password_strength_level = [AuthProvider getLoginUserInfo].password_strength_level;
    }
    
    if ([password_strength_level isEqualToString:@"MEDIUM"])
    {
        if (![CommonUtil matchingByRegex:@"(?=.*[A-z])(?=.*[0-9])(?!.*[ ]).{8,}" withField:pin])
        {
            [self.view makeToast:NSBaseLocalizedString(@"password_guide", nil)
                        duration:2.0
                        position:CSToastPositionTop
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
            return NO;
        }
        if (![CommonUtil matchingByRegex:@"(?=.*[A-z])(?=.*[0-9])(?!.*[ ]).{8,}" withField:comparisonPin])
        {
            [self.view makeToast:NSBaseLocalizedString(@"password_guide", nil)
                        duration:2.0
                        position:CSToastPositionTop
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
            return NO;
        }
    }
    else
    {
        if (![CommonUtil matchingByRegex:@"(?=.*[A-Z])(?=.*[^\\w\\s\\d])(?=.*[a-z])(?=.*[0-9])(?!.*[ ]).{8,}" withField:pin])
        {
            [self.view makeToast:NSBaseLocalizedString(@"password_guide_strong", nil)
                        duration:2.0
                        position:CSToastPositionTop
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
            return NO;
        }
        if (![CommonUtil matchingByRegex:@"(?=.*[A-Z])(?=.*[^\\w\\s\\d])(?=.*[a-z])(?=.*[0-9])(?!.*[ ]).{8,}" withField:comparisonPin])
        {
            [self.view makeToast:NSBaseLocalizedString(@"password_guide_strong", nil)
                        duration:2.0
                        position:CSToastPositionTop
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
            return NO;
        }
    }
    
    return YES;
}

- (IBAction)confirmCurrentPopup:(id)sender
{
    if (_type == PIN)
    {
        if (nil != pin && nil != comparisonPin && [pin isEqualToString:comparisonPin] && pin.length > 3)
        {
            [self.view endEditing:YES];
            
            if (self.responseBlock)
            {
                self.responseBlock(_type, pin);
                self.responseBlock = nil;
            }
            
            [self closePopup:self parentViewController:self.parentViewController];
        }
        else
        {
            if (nil == pin || nil == comparisonPin)
            {
                [self.view makeToast:NSBaseLocalizedString(@"password_empty", nil)
                            duration:2.0
                            position:CSToastPositionTop
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                return;
            }
            
            if (pin.length < 4 || comparisonPin.length < 4)
            {
                [self.view makeToast:NSBaseLocalizedString(@"pincount", nil)
                            duration:2.0
                            position:CSToastPositionTop
                               image:[UIImage imageNamed:@"toast_popup_i_03"]];
                return;
            }
            
            [self.view makeToast:NSBaseLocalizedString(@"password_invalid", nil)
                        duration:2.0
                        position:CSToastPositionTop
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
        }
    }
    else
    {
        // 정규식 비교 필요
        if(![self checkPasswordStrengthLevel])
            return;
        
        if (![pin isEqualToString:comparisonPin])
        {
            [self.view makeToast:NSBaseLocalizedString(@"password_invalid", nil)
                        duration:2.0
                        position:CSToastPositionTop
                           image:[UIImage imageNamed:@"toast_popup_i_03"]];
            return;
        }
        
        [self.view endEditing:YES];
        
        if (self.responseBlock)
        {
            self.responseBlock(_type, pin);
            self.responseBlock = nil;
        }
        [self closePopup:self parentViewController:self.parentViewController];
    }
    
    
}

- (void)getResponse:(PinPopupResponseBlock)responseBlock
{
    self.responseBlock = responseBlock;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    switch (_type)
    {
        case PIN:
            return 2;
            break;
            
        case PASSWORD:
            return 3;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_type == PIN)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PinCell" forIndexPath:indexPath];
        PinCell *customCell = (PinCell*)cell;
        customCell.delegate = self;
        [customCell setCellContent:indexPath.row content:nil isPin:YES];
        
        return customCell;
    }
    else
    {
        if (indexPath.row == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PasswordDecCell" forIndexPath:indexPath];
            PasswordDecCell *customCell = (PasswordDecCell*)cell;
            [customCell setContentLabel];
            return customCell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PinCell" forIndexPath:indexPath];
            PinCell *customCell = (PinCell*)cell;
            customCell.delegate = self;
            [customCell setCellContent:indexPath.row content:nil isPin:NO];
            
            return customCell;
        }
        
    }
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_type == PASSWORD)
        if (indexPath.row == 0)
            return;
    
    UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
    PinCell *customCell = (PinCell*)theCell;
    [customCell setFirstResponder];
}


#pragma mark - PinPopupDelegate

- (void)textFieldValueChanged:(NSString*)value cell:(UITableViewCell*)theCell
{
    NSIndexPath *indexPath = [pinTableView indexPathForCell:theCell];
    
    if (_type == PIN)
    {
        if (indexPath.row == 0)
        {
            pin = value;
        }
        else
        {
            comparisonPin = value;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 1:
                 pin = value;
                break;
                
            case 2:
                comparisonPin = value;
                break;
        }
    }
    
}


@end
