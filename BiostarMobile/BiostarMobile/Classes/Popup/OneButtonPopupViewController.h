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

typedef enum{
    UPDATE_USER,
    CREATE_USER,
    SESSION_EXPIRED,
    FINGERPRINT_VERIFICATION_FAIL,
    USER_INFO_VERIFICATION_FAIL,
    LOGIN_INFO_LACK,
    FORCE_UPDATE_NEED,
    SETTING,
    CARD_CHANGED,
    PERMISSION_DENIED,
    DOOR_CONTROL,
    SAVE_REQUEST_FAIL,
    BLE_POWER_OFF
} OneButtonPopupType;


@interface OneButtonPopupViewController : BaseViewController
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *contentLabel;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIImageView *notiImage;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UIButton *confirmBtn;
    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    

}

typedef void (^ResponseBlock)(OneButtonPopupType type);

@property (assign, nonatomic) OneButtonPopupType type;
@property (strong, nonatomic) NSString *popupContent;
@property (nonatomic, strong) ResponseBlock responseBlock;
@property (nonatomic, strong) NSString *titleStr;


- (IBAction)closePopup:(id)sender;
- (void)getResponse:(ResponseBlock)responseBlock;

@end
