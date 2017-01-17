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

#import "AlarmCell.h"

@implementation AlarmCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAlarmCell:(GetNotification*)alarmInfo isDeleteMode:(BOOL)isDeleteMode
{
    NSDate *calculatedDate = [CommonUtil dateFromString:alarmInfo.event_datetime  originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    NSString *timeFormat;
    
    if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@",[PreferenceProvider getDateFormat], @"hh:mm:ss a"];
    }
    else
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
    }
    
    alarmDate.text = [CommonUtil stringFromCurrentLocaleDateString:[calculatedDate description]
                                                  originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                   transDateFormat:timeFormat];
    
    if (isDeleteMode)
    {
        [imageAccView setHidden:YES];
    }
    else
    {
        [imageAccView setHidden:NO];
    }
    
    if (alarmInfo.isSelected)
    {
        [self.contentView setBackgroundColor:UIColorFromRGB(0xf7ce86)];
        [checkView setHidden:NO];
    }
    else
    {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [checkView setHidden:YES];
    }
    
    if ([alarmInfo.status isEqualToString:@"UNREAD"])
    {
        [newIconView setHidden:NO];
    }
    else
    {
        [newIconView setHidden:YES];
    }
    
    NotificationType notyType = [alarmInfo.type notificationTypeEnumFromString];
    
    switch (notyType) {
            
        case DOOR_OPEN_REQUEST:
            alarmDec.text = NSLocalizedString(alarmInfo.event.door_open_request.title_loc_key, nil);
            [alarmIcon setImage:[UIImage imageNamed:@"ic_event_door_01"]];
            break;
            
        case DOOR_FORCED_OPEN:
        {
            alarmDec.text = NSLocalizedString(alarmInfo.event.door_forced_open.title_loc_key, nil);
            [alarmIcon setImage:[UIImage imageNamed:@"ic_event_door_02"]];
        }
            break;
            
        case DOOR_HELD_OPEN:
        {
            alarmDec.text = NSLocalizedString(alarmInfo.event.door_held_open.title_loc_key, nil);
            [alarmIcon setImage:[UIImage imageNamed:@"ic_event_door_03"]];
        }
            break;
            
        case DEVICE_TAMPERING:
        {
            alarmDec.text = NSLocalizedString(alarmInfo.event.device_tampering.title_loc_key, nil);
            [alarmIcon setImage:[UIImage imageNamed:@"ic_event_device_03"]];
        }
            break;
            
        case DEVICE_REBOOT:
        {
            alarmDec.text = NSLocalizedString(alarmInfo.event.device_reboot.title_loc_key, nil);
            [alarmIcon setImage:[UIImage imageNamed:@"ic_event_device_01"]];
        }
            break;
            
        case DEVICE_RS485_DISCONNECT:
        {
            alarmDec.text = NSLocalizedString(alarmInfo.event.device_rs485_disconnect.title_loc_key, nil);
            [alarmIcon setImage:[UIImage imageNamed:@"ic_event_device_03"]];
        }
            break;
            
        case ZONE_APB:
        {
            if (alarmInfo.event.zone_apb.door)
            {
                [alarmIcon setImage:[UIImage imageNamed:@"ic_event_door_03"]];
            }
            else
            {
                [alarmIcon setImage:[UIImage imageNamed:@"ic_event_zone_03"]];
            }
            
            alarmDec.text = NSLocalizedString(alarmInfo.event.zone_apb.title_loc_key, nil);
        }
            break;
            
        case ZONE_FIRE:
        {
            alarmDec.text = NSLocalizedString(alarmInfo.event.zone_fire.title_loc_key, nil);
            [alarmIcon setImage:[UIImage imageNamed:@"ic_event_fire_alarm"]];
        }
            break;
    }
}

@end
