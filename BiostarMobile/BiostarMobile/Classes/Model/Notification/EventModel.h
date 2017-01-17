//
//  EventModel.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 11..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleModel.h"
#import "SimpleUser.h"

@interface EventModel : NSObject

@property (nonatomic, strong) NSString *contact_phone_number;
@property (nonatomic, strong) SimpleModel *door;
@property (nonatomic, strong) NSString *request_timestamp;
@property (nonatomic, strong) SimpleUser *request_user;
@property (nonatomic, strong) NSString *datetime;
@property (nonatomic, strong) NSString *title_loc_key;
@property (nonatomic, strong) NSString *loc_key;
@property (nonatomic, strong) NSArray <NSString*> *loc_args;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) SimpleModel *zone;
@property (nonatomic, strong) SimpleModel *device;



@end
