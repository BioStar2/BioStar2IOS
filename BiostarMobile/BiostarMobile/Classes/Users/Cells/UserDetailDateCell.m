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

#import "UserDetailDateCell.h"
#import "PreferenceProvider.h"

@implementation UserDetailDateCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStartDate:(NSString*)startDate andExpireDate:(NSString*)expireDate
{
    
    if (nil != startDate)
    {
        NSString *startDateStr =  [CommonUtil stringFromDateString:startDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[PreferenceProvider getDateFormat]];
        
        if (nil != startDateStr)
        {
            _startDate.text = startDateStr;
        }
    }
    
    if (nil != expireDate)
    {
        NSString *expiryDateStr =  [CommonUtil stringFromDateString:expireDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:[PreferenceProvider getDateFormat]];
        
        if (nil != expiryDateStr)
        {
            _expireDate.text = expiryDateStr;
        }
        
    }
}

- (NSString*)getTitle
{
    return self.titleLabel.text;
}

@end
