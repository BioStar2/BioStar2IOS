//
//  DoorStatus.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoorStatus : NSObject

@property (nonatomic, assign) BOOL apb_failed;
@property (nonatomic, assign) BOOL disconnected;
@property (nonatomic, assign) BOOL emergencyLocked;
@property (nonatomic, assign) BOOL emergencyUnlocked;
@property (nonatomic, assign) BOOL forced_open;
@property (nonatomic, assign) BOOL held_opened;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) BOOL normal;
@property (nonatomic, assign) BOOL operatorLocked;
@property (nonatomic, assign) BOOL operatorUnlocked;
@property (nonatomic, assign) BOOL scheduleLocked;
@property (nonatomic, assign) BOOL scheduleUnlocked;
@property (nonatomic, assign) BOOL unlocked;



@end
