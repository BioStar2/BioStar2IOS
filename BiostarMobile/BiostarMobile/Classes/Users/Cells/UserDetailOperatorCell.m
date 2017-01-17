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

#import "UserDetailOperatorCell.h"

@implementation UserDetailOperatorCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setOperatorCellContent:(NSArray*)operators isEditMode:(BOOL)flag
{
    titleLabel.text = NSLocalizedString(@"operator", nil);
    NSString *permission;
    [numberView setHidden:YES];
    UserRole *role;
    switch (operators.count)
    {
        case 0:
            permission = NSLocalizedString(@"none", nil);
            [numberView setHidden:YES];
            if (flag)
            {
                [accImageView setHidden:NO];
                contentTrailConstraint.constant = 40;
                numberTrailConstraint.constant = 40;
            }
            else
            {
                [accImageView setHidden:YES];
                contentTrailConstraint.constant = 20;
                numberTrailConstraint.constant = 20;
            }
            break;
        case 1:
            role = [operators objectAtIndex:0];
            permission = role.role_description;
            [numberView setHidden:YES];
            
            if (flag)
            {
                [accImageView setHidden:NO];
                contentTrailConstraint.constant = 40;
                numberTrailConstraint.constant = 40;
            }
            else
            {
                [accImageView setHidden:YES];
                contentTrailConstraint.constant = 20;
                numberTrailConstraint.constant = 20;
            }
            
            break;
        default:
            role = [operators lastObject];
            permission = role.role_description;
            numberLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)operators.count];
            [numberView setHidden:NO];
            if (flag)
            {
                [accImageView setHidden:NO];
                contentTrailConstraint.constant = 74;
                numberTrailConstraint.constant = 40;
            }
            else
            {
                [accImageView setHidden:YES];
                contentTrailConstraint.constant = 54;
                numberTrailConstraint.constant = 20;
            }
            break;
    }


    contentLabel.text = permission;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:numberLabel.font, NSFontAttributeName, nil];
    CGFloat width = [[[NSAttributedString alloc] initWithString:numberLabel.text attributes:attributes] size].width;
    
    numberViewWidth.constant = width + 16;
}

- (void)setPermission:(NSString*)name isEditMode:(BOOL)flag
{
    titleLabel.text = NSLocalizedString(@"operator", nil);
    [numberView setHidden:YES];
    
    if (nil == name)
    {
        contentLabel.text = NSLocalizedString(@"none", nil);
    }
    else
    {
        contentLabel.text = name;
    }
    
    if (flag)
    {
        [accImageView setHidden:NO];
        contentTrailConstraint.constant = 40;
        numberTrailConstraint.constant = 40;
    }
    else
    {
        [accImageView setHidden:YES];
        contentTrailConstraint.constant = 20;
        numberTrailConstraint.constant = 20;
    }
}

- (NSString*)getTitle
{
    return titleLabel.text;
}

@end
