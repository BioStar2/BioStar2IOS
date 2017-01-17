//
//  Event.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 11..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventModel.h"



@interface Event : NSObject

@property (nonatomic, strong) EventModel *zone_fire;
@property (nonatomic, strong) EventModel *zone_apb;
@property (nonatomic, strong) EventModel *door_open_request;
@property (nonatomic, strong) EventModel *door_held_open;
@property (nonatomic, strong) EventModel *door_forced_open;
@property (nonatomic, strong) EventModel *device_tampering;
@property (nonatomic, strong) EventModel *device_rs485_disconnect;
@property (nonatomic, strong) EventModel *device_reboot;



@end
