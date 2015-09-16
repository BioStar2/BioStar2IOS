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

@protocol SwitchCellDelegate <NSObject>

@optional

- (void)switchValueDidChange:(UISwitch*)sender cell:(UITableViewCell*)theCell;

@end

@interface UserDetailSwitchCell : UITableViewCell
{
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UITextField *password;
    __weak IBOutlet UISwitch *cellSwitch;
    
}

@property (assign, nonatomic) id <SwitchCellDelegate> delegate;

- (void)setCellContent:(NSString*)status;
- (void)setCellPinContent:(BOOL)flag;
- (IBAction)cellSwitchValueDidChange:(UISwitch *)sender;

@end
