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
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDoorStatus:(ListDoorItem*)door
{
    DoorStatus *status = door.status;
    
    if (status.normal || status.apb_failed)
    {
        // 초록
        self.doorImage.image = [UIImage imageNamed:@"ic_event_door_01"];
    }
    
    if (status.locked || status.unlocked || status.held_opened || status.scheduleLocked ||
        status.scheduleUnlocked || status.operatorLocked || status.operatorUnlocked)
    {
        // 노란
        self.doorImage.image = [UIImage imageNamed:@"ic_event_door_03"];
    }
    
    if (status.disconnected || status.forced_open ||
        status.emergencyLocked || status.emergencyUnlocked)
    {
        // 빨간
        self.doorImage.image = [UIImage imageNamed:@"ic_event_door_02"];
    }
}
@end
