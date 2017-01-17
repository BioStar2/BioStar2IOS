//
//  EventLogResult.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleModel.h"
#import "EventType.h"
#import "SimpleUser.h"

@interface EventLogResult : NSObject


@property (nonatomic, strong) NSString *datetime;
@property (nonatomic, strong) SimpleModel *device;
@property (nonatomic, strong) SimpleModel *door;
@property (nonatomic, strong) EventType *event_type;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *level;
@property (nonatomic, strong) NSString *server_datetime;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) SimpleUser *user;
@property (nonatomic, strong) SimpleModel *user_group;

@end
