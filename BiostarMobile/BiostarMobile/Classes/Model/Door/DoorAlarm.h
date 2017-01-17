//
//  DoorAlarm.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlarmAction.h"

@interface DoorAlarm : NSObject


@property (nonatomic, strong) AlarmAction *action;
@property (nonatomic, strong) NSString *type;

@end
