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

#import "VerificationCell.h"

@implementation VerificationCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCardAndFingerprintCell:(NSDictionary*)dic
{
    if ([[dic objectForKey:@"selected"] boolValue])
    {
        [self.contentView setBackgroundColor:UIColorFromRGB(0xf7ce86)];
        [_checkImage setHidden:NO];
        [_accImage setHidden:YES];
    }
    else
    {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [_checkImage setHidden:YES];
        [_accImage setHidden:NO];
    }
}

- (void)setCellDictionary:(NSDictionary*)dic
{
    
    if ([dic objectForKey:@"name"])
    {
        _titleLabel.text = [dic objectForKey:@"name"];
    }
    
    if([[dic objectForKey:@"included_by_user_group"] isEqualToString:@"YES"])
    {
        [_accImage setHidden:YES];
        [self.contentView setBackgroundColor:[UIColor lightGrayColor]];
    }
    else
    {
        
        if ([[dic objectForKey:@"selected"] boolValue])
        {
            [self.contentView setBackgroundColor:UIColorFromRGB(0xf7ce86)];
            [_checkImage setHidden:NO];
            [_accImage setHidden:YES];
        }
        else
        {
            [self.contentView setBackgroundColor:[UIColor whiteColor]];
            [_checkImage setHidden:YES];
            [_accImage setHidden:NO];
        }
    }
    
    
}

@end
