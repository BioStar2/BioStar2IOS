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
#import "BaseViewController.h"
#import "PinCell.h"
#import "PasswordDecCell.h"
#import "UserProvider.h"
#import "PreferenceProvider.h"
#import "AuthProvider.h"

typedef enum{
    PIN,
    PASSWORD,
} PinPopupType;

@interface PinPopupViewController : BaseViewController <PinCellDelegate>
{
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITableView *pinTableView;
    __weak IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *confirmBtn;
    __weak IBOutlet UIButton *cancelBtn;
    
    NSString *pin;
    NSString *comparisonPin;
}

typedef void (^PinPopupResponseBlock)(PinPopupType type, NSString* pin);

@property (nonatomic, strong) PinPopupResponseBlock responseBlock;
@property (assign, nonatomic) PinPopupType type;

- (IBAction)cancelCurrentPopup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;
- (void)getResponse:(PinPopupResponseBlock)responseBlock;
- (BOOL)checkPasswordStrengthLevel;

@end
