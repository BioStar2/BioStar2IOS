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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAlarmCell:(NSDictionary*)alarmInfo isDeleteMode:(BOOL)isDeleteMode
{
    NSDate *calculatedDate = [CommonUtil dateFromString:[alarmInfo objectForKey:@"event_datetime"]  originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
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
    
    if ([[alarmInfo objectForKey:@"selected"] boolValue])
    {
        [self.contentView setBackgroundColor:UIColorFromRGB(0xf7ce86)];
        [checkView setHidden:NO];
    }
    else
    {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [checkView setHidden:YES];
    }
    
    if ([[alarmInfo objectForKey:@"status"] isEqualToString:@"UNREAD"])
    {
        [newIconView setHidden:NO];
    }
    else
    {
        [newIconView setHidden:YES];
    }
    
    if ([[alarmInfo objectForKey:@"type"] isEqualToString:@"DOOR_OPEN_REQUEST"])
    {
        alarmDec.text = [[[alarmInfo objectForKey:@"event"] objectForKey:@"door_open_request"] objectForKey:@"title"];
        [alarmIcon setImage:[UIImage imageNamed:@"ic_event_door_01"]];
    }
    else if ([[alarmInfo objectForKey:@"type"] isEqualToString:@"DOOR_FORCED_OPEN"])
    {
        alarmDec.text = [[[alarmInfo objectForKey:@"event"] objectForKey:@"door_forced_open"] objectForKey:@"title"];
        [alarmIcon setImage:[UIImage imageNamed:@"ic_event_door_02"]];
    }
    else if ([[alarmInfo objectForKey:@"type"] isEqualToString:@"DOOR_HELD_OPEN"])
    {
        alarmDec.text = [[[alarmInfo objectForKey:@"event"] objectForKey:@"door_held_open"] objectForKey:@"title"];
        [alarmIcon setImage:[UIImage imageNamed:@"ic_event_door_03"]];
    }
    else if ([[alarmInfo objectForKey:@"type"] isEqualToString:@"DEVICE_TAMPERING"])
    {
        alarmDec.text = [[[alarmInfo objectForKey:@"event"] objectForKey:@"device_tampering"] objectForKey:@"title"];
        [alarmIcon setImage:[UIImage imageNamed:@"ic_event_device_03"]];
    }
    else if ([[alarmInfo objectForKey:@"type"] isEqualToString:@"DEVICE_REBOOT"])
    {
        alarmDec.text = [[[alarmInfo objectForKey:@"event"] objectForKey:@"device_reboot"] objectForKey:@"title"];
        [alarmIcon setImage:[UIImage imageNamed:@"ic_event_device_01"]];
    }
    else if ([[alarmInfo objectForKey:@"type"] isEqualToString:@"DEVICE_RS485_DISCONNECT"])
    {
        // 알림시간 하나밖에 없음
        alarmDec.text = [[[alarmInfo objectForKey:@"event"] objectForKey:@"device_rs485_disconnect"] objectForKey:@"title"];
        [alarmIcon setImage:[UIImage imageNamed:@"ic_event_device_03"]];
    }
    else if ([[alarmInfo objectForKey:@"type"] isEqualToString:@"ZONE_APB"])
    {
        if ([[[alarmInfo objectForKey:@"event"] objectForKey:@"zone_apb"] objectForKey:@"door"])
        {
            [alarmIcon setImage:[UIImage imageNamed:@"ic_event_door_03"]];
        }
        else
        {
            [alarmIcon setImage:[UIImage imageNamed:@"ic_event_zone_02"]];
        }
        alarmDec.text = [[[alarmInfo objectForKey:@"event"] objectForKey:@"zone_apb"] objectForKey:@"title"];
        
    }
    else if ([[alarmInfo objectForKey:@"type"] isEqualToString:@"ZONE_FIRE"])
    {
        alarmDec.text = [[[alarmInfo objectForKey:@"event"] objectForKey:@"zone_fire"] objectForKey:@"title"];
        [alarmIcon setImage:[UIImage imageNamed:@"ic_event_fire_alarm"]];
    }
}

@end
