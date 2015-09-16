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
#import "CommonUtil.h"
#import "PreferenceProvider.h"
#import "Common.h"

@interface AlarmCell : UITableViewCell
{
    __weak IBOutlet UIImageView *alarmIcon;
    __weak IBOutlet UILabel *alarmDec;
    __weak IBOutlet UILabel *alarmDate;
    __weak IBOutlet UIView *newIconView;
    __weak IBOutlet UIImageView *imageAccView;
    __weak IBOutlet UIImageView *checkView;
    
}

- (void)setAlarmCell:(NSDictionary*)alarmInfo isDeleteMode:(BOOL)isDeleteMode;
@end
