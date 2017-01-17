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

#import "MonitoringCell.h"
#import "PreferenceProvider.h"

@implementation MonitoringCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContent:(EventLogResult*)logResult canMoveDetail:(BOOL)canMoveDetail
{
    EventType *eventType = logResult.event_type;
    
    if (nil == eventType.event_type_description)
    {
        NSInteger code = eventType.code;
        if (code > 4095 && code < 4110)
        {
            code = 4096;
        }
        else if (code > 4351 && code < 4360)
        {
            code = 4352;
        }
        else if (code > 4607 && code < 4622)
        {
            code = 4608;
        }
        else if (code > 4863 && code < 4869)
        {
            code = 4864;
        }
        else if (code > 5119 && code < 5128)
        {
            code = 5120;
        }
        
        NSString *detail = [EventProvider convertEventCodeToDescription:code];
        if (nil == detail)
        {
            _eventTitleLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)code];
        }
        else
        {
            _eventTitleLabel.text = detail;
        }
        
    }
    else
    {
        _eventTitleLabel.text = eventType.event_type_description;
    }
    


    NSDate *calculatedDate = [CommonUtil localDateFromString:logResult.datetime originDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SS'Z'"];
    
    NSString *timeFormat;
    
    if ([[PreferenceProvider getTimeFormat] isEqualToString:@"hh:mm a"])
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@",[PreferenceProvider getDateFormat], @"hh:mm:ss a"];
    }
    else
    {
        timeFormat = [NSString stringWithFormat:@"%@ %@:ss",[PreferenceProvider getDateFormat], [PreferenceProvider getTimeFormat]];
    }
    
    NSString *description = [NSString stringWithFormat:@"%@",
                             [CommonUtil stringFromCurrentLocaleDateString:[calculatedDate description]
                                                           originDateFormat:@"YYYY-MM-dd HH:mm:ss z"
                                                            transDateFormat:timeFormat]];
    
    _eventDateLabel.text = description;
    
    
    [self setEventImage:logResult];
    
}

- (void)setEventImage:(EventLogResult*)logResult
{
    EventLevel eventLevel = [logResult.level eventLevelEnumFromString];
    LogType logType = [logResult.type logTypeEnumFromString];
    
    if (logType == USER)
    {
        if ([AuthProvider hasReadPermission:USER_PERMISSION])
        {
            [_accImageView setHidden:NO];
        }
        else
        {
            [_accImageView setHidden:YES];
        }
    }
    else
    {
        [_accImageView setHidden:YES];
    }
    
    switch (eventLevel) {
        case GREEN:
            switch (logType) {
                case DEVICE:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_device_01"];
                    break;
                    
                case DOOR:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_door_01"];
                    break;
                    
                case USER:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_user_01"];
                    break;
                    
                case ZONE:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_zone_01"];
                    break;
                    
                case AUTHENTICATION:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_auth_01"];
                    break;
                    
                default:
                    _eventImageView.image = [UIImage imageNamed:@"monitoring_ic3"];
                    break;
            }
            break;
        case YELLOW:
            switch (logType) {
                case DEVICE:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_device_03"];
                    break;
                    
                case DOOR:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_door_03"];
                    break;
                    
                case USER:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_user_03"];
                    break;
                    
                case ZONE:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_zone_03"];
                    break;
                    
                case AUTHENTICATION:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_auth_03"];
                    break;
                    
                default:
                    _eventImageView.image = [UIImage imageNamed:@"monitoring_ic1"];
                    break;
            }
            break;
            
        case RED:
            switch (logType) {
                case DEVICE:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_device_02"];
                    break;
                    
                case DOOR:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_door_02"];
                    break;
                    
                case USER:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_user_02"];
                    break;
                    
                case ZONE:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_zone_02"];
                    break;
                    
                case AUTHENTICATION:
                    _eventImageView.image = [UIImage imageNamed:@"ic_event_auth_02"];
                    break;
                    
                default:
                    _eventImageView.image = [UIImage imageNamed:@"monitoring_ic7"];
                    break;
            }
            break;
    }
}


- (void)setIcon:(NSDictionary*)eventInfo
{
    NSInteger code = [[eventInfo objectForKey:@"code"] integerValue];
    
    //VERIFY_SUCCESS
    if ([self isInCondition:4096 max:4111 code:code imageName:@"monitoring_ic3"]) {
        return;
    }
    //VERIFY_FAIL
    if ([self isInCondition:4352 max:4359 code:code imageName:@"monitoring_ic3"]) {
        return;
    }
    //VERIFY_DURESS
    if ([self isInCondition:4608 max:4623 code:code imageName:@"monitoring_ic2"]) {
        return;
    }
    //IDENTIFY_SUCCESS
    if ([self isInCondition:4864 max:4868 code:code imageName:@"monitoring_ic3"]) {
        return;
    }
    //IDENTIFY_FAIL
    if ([self isInCondition:5120 max:5127 code:code imageName:@"monitoring_ic3"]) {
        return;
    }
    //IDENTIFY_DURESS
    if ([self isInCondition:5376 max:5380 code:code imageName:@"monitoring_ic2"]) {
        return;
    }
    //AUTH_FAIL
    if ([self isInCondition:5888 max:6147 code:code imageName:@"monitoring_ic1"]) {
        return;
    }
    //ACCESS_DENIED
    if ([self isInCondition:6400 max:6407 code:code imageName:@"monitoring_ic8"]) {
        return;
    }
    //SYSTEM
    if ([self isInCondition:12288 max:17664 code:code imageName:@"monitoring_ic4"]) {
        return;
    }
    if ([self isInCondition:20480 max:21248 code:code imageName:@"monitoring_ic1"]) {
        return;
    }
    //DOOR //TODO icon change
    if ([self isInCondition:21504 max:27648 code:code imageName:@"monitoring_ic6"]) {
        return;
    }
    
    _eventImageView.image = [UIImage imageNamed:@"monitoring_ic3"];
}


- (BOOL)isInCondition:(NSInteger)min max:(NSInteger)max code:(NSInteger)code imageName:(NSString*)imageName
{
    if (code >= min && code <= max)
    {
        _eventImageView.image = [UIImage imageNamed:imageName];
        return YES;
    }
    return NO;
}
@end
