//
//  GetNotification.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface GetNotification : NSObject

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSString *event_datetime;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *status;


@end
