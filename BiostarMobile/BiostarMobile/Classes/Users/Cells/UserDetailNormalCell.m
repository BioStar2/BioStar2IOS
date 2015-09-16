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

#import "UserDetailNormalCell.h"

@implementation UserDetailNormalCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStartDate:(NSString*)_startDate andExpireDate:(NSString*)_expireDate
{
    NSMutableString *period = [[NSMutableString alloc] initWithString:@""];
    
    if (nil != _startDate)
    {
        NSString *startDateStr =  [CommonUtil stringFromDateString:_startDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:@"yyyy/MM/dd"];
        
        if (nil != startDateStr)
        {
            [period setString:startDateStr];
        }
    }
    
    if (nil != _expireDate)
    {
        NSString *expiryDateStr =  [CommonUtil stringFromDateString:_expireDate originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'" transDateFormat:@"yyyy/MM/dd"];
        
        if (nil != expiryDateStr)
        {
            [period appendFormat:@" - %@", expiryDateStr];
        }
        
    }
    
    
    _contentField.text = period;
}

@end
