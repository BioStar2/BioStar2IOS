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

#import "DoorCell.h"

@implementation DoorCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDoorStatus:(NSDictionary*)doorDic
{
    NSDictionary *status = [doorDic objectForKey:@"status"];
    
    if ([[status objectForKey:@"normal"] boolValue] || [[status objectForKey:@"apb_failed"] boolValue])
    {
        // 초록
        self.doorImage.image = [UIImage imageNamed:@"ic_event_door_01"];
    }
    
    if ([[status objectForKey:@"locked"] boolValue] || [[status objectForKey:@"unlocked"] boolValue] ||
        [[status objectForKey:@"held_opened"] boolValue] || [[status objectForKey:@"scheduleLocked"] boolValue] ||
        [[status objectForKey:@"scheduleUnlocked"] boolValue] || [[status objectForKey:@"operatorLocked"] boolValue] ||
        [[status objectForKey:@"operatorUnlocked"] boolValue])
    {
        // 노란
        self.doorImage.image = [UIImage imageNamed:@"ic_event_door_03"];
    }
    
    if ([[status objectForKey:@"disconnected"] boolValue] || [[status objectForKey:@"forced_open"] boolValue] ||
        [[status objectForKey:@"emergencyLocked"] boolValue] || [[status objectForKey:@"emergencyUnlocked"] boolValue])
    {
        // 빨간
        self.doorImage.image = [UIImage imageNamed:@"ic_event_door_02"];
    }
}
@end
