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
    USER_DELETE,
    ALARM_DELETE,
    
} TextType;

@protocol TextPopupDelegate <NSObject>

@optional

- (void)cancelModify;
- (void)confirmDeleteUser;
- (void)confirmDeleteAlarm;

@end

@interface TextPopupViewController : BaseViewController
{
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *contentLabel;
    __weak IBOutlet NSLayoutConstraint *heightConstraint;
    __weak IBOutlet UIView *contentView;
    
    NSString *contentText;
}

@property (assign, nonatomic) TextType type;
@property (assign, nonatomic) id <TextPopupDelegate> delegate;

- (IBAction)cancelCurrentPopup:(id)sender;
- (IBAction)confirmCurrentPopup:(id)sender;
- (void)setContent:(NSString*)content;
@end
