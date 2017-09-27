//
//  EventType.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 10..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventType : NSObject


@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL alertable;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *event_type_description;
@property (nonatomic, assign) BOOL enable_alert;
@property (nonatomic, strong) NSString *message_key;
@property (nonatomic, strong) NSString *name;


@end
