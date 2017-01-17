//
//  Setting.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 11. 1..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationSetting.h"

@interface Setting : NSObject

@property (nonatomic, strong) NSString *date_format;
@property (nonatomic, strong) NSString *time_format;
@property (nonatomic, strong) NSArray <NotificationSetting*> *notifications;
@property (nonatomic, assign) BOOL isSelected;

@end
