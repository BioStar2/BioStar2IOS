//
//  ListDoorItem.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import "Response.h"
#import "DoorAlarm.h"
#import "SimpleModel.h"
#import "DoorRelay.h"
#import "DoorSensor.h"
#import "DualAuthentication.h"
#import "DoorExitButton.h"
#import "DoorStatus.h"

@interface ListDoorItem : Response

@property (nonatomic, strong) NSArray <DoorAlarm *> *alarms;
@property (nonatomic, assign) NSInteger apb_reset_time;
@property (nonatomic, strong) NSString *apb_type;
@property (nonatomic, strong) NSString *apb_when_disconnected;
@property (nonatomic, strong) NSString *door_description;
@property (nonatomic, strong) NSArray <SimpleModel*> *door_group;
@property (nonatomic, strong) DoorRelay *door_relay;
@property (nonatomic, strong) DoorSensor *door_sensor;
@property (nonatomic, strong) DualAuthentication *dual_authentication;
@property (nonatomic, strong) SimpleModel *entry_device;
@property (nonatomic, strong) DoorExitButton *exit_button;
@property (nonatomic, strong) SimpleModel *exit_device;
@property (nonatomic, assign) NSInteger held_open_timeout;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger open_duration;
@property (nonatomic, strong) NSString *open_once;
@property (nonatomic, strong) DoorStatus *status;
@property (nonatomic, assign) BOOL isSelected;

@end
