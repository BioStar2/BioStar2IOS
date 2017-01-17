//
//  EventQuery.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventQuery : NSObject

@property (nonatomic, strong) NSArray <NSString*> *datetime;
@property (nonatomic, strong) NSArray <NSString*> *device_id;
@property (nonatomic, strong) NSArray <NSString*> *event_type_code;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSArray <NSString*> *user_id;

@end
