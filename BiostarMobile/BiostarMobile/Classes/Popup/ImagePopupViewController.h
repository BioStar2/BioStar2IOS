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


typedef enum
{
    MAIN_REQUEST_FAIL,
    REQUEST_FAIL,
    WARNING,
    DELETE_USERS,
    CARD_BLOCK,
    CARD_RELEASE,
    CARD_REGISTER,
    CARD_REREGISTER,
    USER_CREATED,
    LOW_QUALITY
    
} ImagePopupType;

@interface ImagePopupViewController : BaseViewController
{
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *popupImage;
    __weak IBOutlet UILabel *contentLabel;
    __weak IBOutlet NSLayoutConstraint *containerHeightConstraint;
    __weak IBOutlet UIButton *confirmButton;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *cancelBtn;
    __weak IBOutlet UIButton *confirmBtn;
    
    
}

typedef void (^ImagePopupResponseBlock)(ImagePopupType type, BOOL isConfirm);

@property (assign, nonatomic) ImagePopupType type;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *titleContent;
@property (nonatomic, strong) ImagePopupResponseBlock responseBlock;

- (IBAction)cancelCurrentPupup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;
- (void)getResponse:(ImagePopupResponseBlock)responseBlock;

@end
