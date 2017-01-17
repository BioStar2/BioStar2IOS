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

#import "UserDetailSwitchCell.h"

@implementation UserDetailSwitchCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cellSwitchValueDidChange:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(switchValueDidChange:cell:)])
    {
        [self.delegate switchValueDidChange:cellSwitch cell:self];
    }
}

- (void)setCellContent:(NSString*)status
{
    if ([status isEqualToString:@"AC"])
    {
        [cellSwitch setOn:YES];
        titleLabel.text = NSLocalizedString(@"status_active", nil);
    }
    else
    {
        [cellSwitch setOn:NO];
        titleLabel.text = NSLocalizedString(@"status_inactive", nil);
    }
    
    [password setHidden:YES];
}

- (void)setCellPinContent:(BOOL)flag
{
    [password setHidden:NO];
    titleLabel.text = NSLocalizedString(@"pin_upper", nil);
    [cellSwitch setOn:flag];
    if (flag)
        password.text = @"1234";
    else
        password.text = @"";
}

- (NSString*)getTitle
{
    return titleLabel.text;
}

@end
